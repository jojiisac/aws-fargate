# aws-fargate
This repo shows  
    
1. How to export  logs from  aws-fargate-eks cluster
    


## Pre-Requisists 
### tools 
     eksctl    -  https://eksctl.io/
     kubectl v1.22   
     awscli 
     git 
     jq
     helm
     
### Access
 AWS account  
 Iam user created with enoughf permission to  create update  delete the following 
    eks 
    fargate profiles  
    IAM policy/roles/users   
###  Configure aws account
configure aws cli as follows

    ~
    aws configure 
    AWS Access Key ID [None]: **********   #put the actual Acces Key ID here 
    AWS Secret Access Key [None]: ***********  #put the actual Secret Acces key here 
    Default region name [None]: ap-south-1 
    Default output format [None]: 
    ~


## Creating a cluster  
    ~
    #set env variales 
    export ACCOUNT_ID="<your_account_Id>"    # put the actual account id here
    export CLUSTER_NAME=test-cluster
    export AWS_REGION=ap-south-1
    
    # Craete the cluster 
    eksctl create cluster --name $CLUSTER_NAME --region ap-south-1  --fargate 
    aws eks --region ap-south-1 update-kubeconfig --name $CLUSTER_NAME


    eksctl create fargateprofile -f ./clusterconfig.yaml




    # eksctl delete cluster  $CLUSTER_NAME




