  # create  ns 
  kubectl apply -f ./namespace.yml
  # create CM to enable logging 
  kubectl apply -f ./cm.yaml     
  

# craete policy 
  aws iam create-policy --policy-name eks-fargate-logging-policy --policy-document file://permissions.json


  # attachpolicy to pod excecuion role 
  ## NOTE : --- role name will change each time, get it by the follwing script 
  aws iam list-roles | grep FargatePodExecutionRole

  # find the   role name and from a ove command
  # Replace the  elow rolename 'eksctl-test-cluster-cluste-FargatePodExecutionRole-U7DZRO74NV9I' with   newwly found role name  from aove command  

   
   # ru bbelow command to attach the policy with role 
  aws iam attach-role-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/eks-fargate-logging-policy \
  --role-name eksctl-test-cluster-cluste-FargatePodExecutionRole-U7DZRO74NV9I       ## replace this role name 



#run below command to create an app 

kubectl apply -f ./log-creating-app.yml 
