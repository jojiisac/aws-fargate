
#  Exporting application logs into Cloud watch  

This method export the cpnsole logs craeted by application containers into  AWS cloud watch



## Create Name spaces  
Tow names spaces will be created 
 1. aws-observability   for keeking log exporting configurartion 
 2. prodcatalog-ns    for running the application  



    `

    kubectl apply -f ./namespace.yml
  
    #create CM to enable logging 
  
    kubectl apply -f ./cm.yaml     
    `

NOTE:  
see the label  below , if ay namescapce  lebelled like this, the console logs from pods runing inside the namaspce  will be exported  
    
        labels:
            aws-observability: enabled


 

## create policy  and attach to excecution role  
 
 This  allows fargate excecution role to create logs streams  groups and export logs into cloud ewatch 
 
     aws iam create-policy --policy-name eks-fargate-logging-policy --policy-document file://permissions.json


  
   NOTE : --- role name may be dyamic, read it by the follwing script 
  aws iam list-roles | grep FargatePodExecutionRole

    #find the   role name and from a ove command
Replace the  elow rolename 

'eksctl-test-cluster-cluste-FargatePodExecutionRole-U7DZRO74NV9I' with   newwly found role name  from aove command  

   
 Run bbelow command to attach the policy with role 
    
    aws iam attach-role-policy \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/eks-fargate-logging-policy \
    --role-name eksctl-test-cluster-cluste-FargatePodExecutionRole-U7DZRO74NV9I       ## replace this role name 



#run below command to create an app 

    kubectl apply -f ./log-creating-app.yml 
