

# set env variales 

#export ACCOUNT_ID="<your_account_Id>"

export CLUSTER_NAME=test-cluster
export AWS_REGION=ap-south-1



echo "createing cluster" 
eksctl create cluster --name $CLUSTER_NAME --region ap-south-1  --fargate 
aws eks --region ap-south-1 update-kubeconfig --name $CLUSTER_NAME


# creates fargate profile for work amespaces   prodcatalog-ns,appmesh-system,aws-observability
eksctl create fargateprofile -f ./clusterconfig.yaml

###  installing app mesh  







# eksctl delete cluster  $CLUSTER_NAME



