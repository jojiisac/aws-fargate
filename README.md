# aws-fargate
This repo shows  
    
1. How to export  logs from  aws-fargate-eks cluster  to cloud watch 
2. How to set up App mesh and route reqests via app mesh
3. How to allow ingress traffic from outside eks/vpc via appmesh and virtual gateways 
4. How to enable tracing using xrays 
    


## Pre-Requisists 
### Tools 
   


     eksctl    -  https://eksctl.io/
     kubectl v1.22   
     awscli 
     git 
     jq
     helm

### Access

  AWS account  

  IAM user created with enoughf permission to  create update  delete the following 
    eks,fargate profiles,IAM policy/roles/users   


### Configure aws account
Configure aws cli as follows

    aws configure 
    AWS Access Key ID [None]: **********   #put the actual Acces Key ID here 
    AWS Secret Access Key [None]: ***********  #put the actual Secret Acces key here 
    Default region name [None]: ap-south-1 
    Default output format [None]: 
    


## Creating a cluster  and fargate profile
    
    #set env variales 
    export ACCOUNT_ID="<your_account_Id>"    # put the actual account id here
    export CLUSTER_NAME=test-cluster
    export AWS_REGION=ap-south-1
    
    # Create the cluster 
    eksctl create cluster --name $CLUSTER_NAME --region ap-south-1  --fargate 
    aws eks --region ap-south-1 update-kubeconfig --name $CLUSTER_NAME

    eksctl create fargateprofile -f ./clusterconfig.yaml
  

## Configuring the apps and cluster

Now the cluster  will be created   aprox 15-25 minutes 

Go to [appMesh](./appMesh/)  and follow instructions there  for setting up mesh,  ingress,  log shipping, trace, x-ray  using a sample app 

Go to [](./logshipping/bycloudwatch/)  and follow instructions there  for setting   log shipping using a sample app 

## Deleting and clean up 


1. Run the script 

        eksctl delete cluster  $CLUSTER_NAME
2. Sign into aws console,   go to "cloudformation" within that choose "stack" 
3. Delete stack 'eksctl-test-cluster-cluster'   from the stack list


