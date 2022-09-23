
## Exporting container insights

###  updating cluster name and region in config file
Run the script below  to update the region and cluster name 

 
    sed -i "s/ClusterName=YOUR-EKS-CLUSTER-NAME/ClusterName=${CLUSTER_NAME}/" otel-fargate-container-insights.yaml 
    sed -i "s/region: us-east-1/region: ${AWS_REGION}/" otel-fargate-container-insights.yaml 


###  Deploying the aws-otel-collector
Run the scripts below  

    export REGION=${AWS_REGION}
    export SERVICE_ACCOUNT_NAMESPACE=amazon-cloudwatch
    export SERVICE_ACCOUNT_NAME=adot-collector
    export SERVICE_ACCOUNT_IAM_ROLE=EKS-Fargate-ADOT-ServiceAccount-Role
    export SERVICE_ACCOUNT_IAM_POLICY=arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

  
    eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster ${CLUSTER_NAME} \
    --approve

    eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --name=$SERVICE_ACCOUNT_NAME \
    --namespace=$SERVICE_ACCOUNT_NAMESPACE \
    --role-name=$SERVICE_ACCOUNT_IAM_ROLE \
    --attach-policy-arn=$SERVICE_ACCOUNT_IAM_POLICY \
    --approve

    #deploy exporter 

    kubectl apply -f ./otel-fargate-container-insights.yaml





### Testing
* Deploy some sample application into cluster,
* Wait till the pods are running
* Log into amazone cloud watch console  
* Select "All metrics"  unnder "Metrics"
* You will see the perfomance Metrics there.




### References

1. https://aws-otel.github.io/docs/getting-started/container-insights/eks-fargate
1. https://docs.aws.amazon.com/eks/latest/userguide/monitoring-fargate-usage.html


