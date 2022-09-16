



## Steps
### 1. create    cluster and fargate profile as in  root of the project  
### 2.  set up an OIDC provider with the cluster as follwos 
  
  

    eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster ${CLUSTER_NAME} \
    --approve


### 3. Create namepace service account  and enable logging 


    k apply -f ./namespaces.yaml
    k apply -f ./cm.yaml


    aws iam create-policy \
        --policy-name ProdEnvoyNamespaceIAMPolicy \
        --policy-document file://envoy-iam-policy.json

    eksctl create iamserviceaccount --cluster ${CLUSTER_NAME} \
    --namespace prodcatalog-ns \
    --name prodcatalog-envoy-proxies \
    --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/ProdEnvoyNamespaceIAMPolicy \
    --override-existing-serviceaccounts \
    --approve 



### 4. Set up observability 
    eksctl create iamserviceaccount \
  --cluster ${CLUSTER_NAME} \
  --namespace amazon-cloudwatch \
  --name cloudwatch-agent \
  --attach-policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --override-existing-serviceaccounts \
  --approve


eksctl create iamserviceaccount \
  --cluster ${CLUSTER_NAME} \
  --namespace amazon-cloudwatch \
  --name fluentd \
  --attach-policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --override-existing-serviceaccounts \
  --approve


kubectl apply -f ./cwagent-fluentd-quickstart.yaml 

eksctl create iamserviceaccount \
  --cluster ${CLUSTER_NAME}  \
  --namespace amazon-cloudwatch \
  --name cwagent-prometheus \
  --attach-policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --override-existing-serviceaccounts \
  --approve

curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/service/cwagent-prometheus/prometheus-eks.yaml   -o ./prometheus-eks.yaml
kubectl apply -f ./prometheus-eks.yaml


 aws iam create-policy \
        --policy-name FluentBitEKSFargate \
        --policy-document file://logging-permissions.json

export PodRole=$(aws eks describe-fargate-profile --cluster-name ${CLUSTER_NAME} --fargate-profile-name fp-custom --query 'fargateProfile.podExecutionRoleArn' | sed -n 's/^.*role\/\(.*\)".*$/\1/ p')
echo $PodRole

aws iam attach-role-policy \
        --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/FluentBitEKSFargate \
        --role-name ${PodRole}


######
    (Optional) Enable Amazon EKS Control Plane logs
    <!-- eksctl utils update-cluster-logging \
    --enable-types all \
    --region ${AWS_REGION} \
    --cluster ${CLUSTER_NAME} \
    --approve -->
#####


  ###  deploye the basic apps 
  
      kubectl apply -f  base_app.yaml 


  ###  6.  test the apps 

  Run the follwing scrit so that that you ts into a cotainer 

    export FE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=frontend-node -o jsonpath='{.items[].metadata.name}') 

    kubectl -n prodcatalog-ns exec  ${FE_POD_NAME} -c frontend-node -- curl -s  http://prodcatalog.prodcatalog-ns.svc.cluster.local:5000/products/

  you hould see the follwing output  

    {
        "products": {},
        "details": {
            "version": "1",
            "vendors": [
                "ABC.com"
            ]
        }
    }

  


  ###  Add app mesh  controller

  


    kubectl  apply -f crds.yml  
    
    kubectl create ns appmesh-system
    
    # Create an IAM policy called AWSAppMeshK8sControllerIAMPolicy
    
    aws iam create-policy \
    --policy-name AWSAppMeshK8sControllerIAMPolicy \
    --policy-document file://controller-iam-policy.json

    #Create an IAM role for the appmesh-controller service account
    eksctl create iamserviceaccount --cluster $CLUSTER_NAME \
    --namespace appmesh-system \
    --name appmesh-controller \
    --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSAppMeshK8sControllerIAMPolicy  \
    --override-existing-serviceaccounts \
    --approve

    # install mesh via helm 
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm upgrade -i appmesh-controller eks/appmesh-controller \
    --namespace appmesh-system \
    --set region=$AWS_REGION \
    --set serviceAccount.create=false \
    --set serviceAccount.name=appmesh-controller \
    --set tracing.enabled=true \
    --set tracing.provider=x-ray

    


### Istall mesh  

    kubectl apply -f mesh.yaml


    

    kubectl apply -f meshed_app.yaml





### Restart  deployment  

    kubectl get pods -n prodcatalog-ns -o wide
    
    kubectl -n prodcatalog-ns rollout restart deployment prodcatalog

    kubectl -n prodcatalog-ns rollout restart deployment proddetail 

    kubectl -n prodcatalog-ns rollout restart deployment frontend-node
    
    kubectl get pods -n prodcatalog-ns -o wide

Note :   you can see diff in the results of command  "kubectl get pods -n prodcatalog-ns -o wide" before and after restart , after rollout  there will be 2 conianers in each pod  

### test the pods again 

    Run the follwing scrit so that that you ts into a cotainer 

    export FE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=frontend-node -o jsonpath='{.items[].metadata.name}') 

    kubectl -n prodcatalog-ns exec  ${FE_POD_NAME} -c frontend-node -- curl -s  http://prodcatalog.prodcatalog-ns.svc.cluster.local:5000/products/

  you hould see the follwing output  

    {
        "products": {},
        "details": {
            "version": "1",
            "vendors": [
                "ABC.com"
            ]
        }
    }

### Intall the Virtual gateway 
    kubectl apply -f virtual_gateway.yaml 

    export LB_NAME=$(kubectl get svc ingress-gw -n prodcatalog-ns -o jsonpath="{.status.loadBalancer.ingress[*].hostname}") 
    
    curl -v --silent ${LB_NAME}/products/
    
    echo $LB_NAME


### deploy the v2  app and route for  it 
    
     kubectl apply -f canary.yaml 
