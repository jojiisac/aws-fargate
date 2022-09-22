

# Exporting   cloud watch logs to logz.io

1. create an s3 bucket in aws  
2. create folder 'cloudwatch-auto-deployment'

3. create folder '0.0.3'  inside 'cloudwatch-auto-deployment'
4. edit  file 'export-function-template.yaml' in line number 69 to reflect newly created folder name 
         
    Bucket: S3_BUCKET_NAME

5. upload the file export-function-template.yaml and 'logzio-cloudwatch.zip' into s3 folder '0.0.3' craeted in step 1  

6. Open aws connsole, go to cloud formation >> stack 

7. press "create  stack "
8. select option "with new resources"
9. select the follwing options in the page 
        
    1. "Template is ready"

    2. Amazon S3 URL 
    



10. Enter  s3 URL of file "" in text box "Amazon S3 URL" 
11.  Press  next 
12.  Enter the parameters
        
        Note  :   logzio token   & URL has to get from logz io  
13. press next annd complete the creation of the function 

end 
    