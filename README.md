This project is part of the nanodegree program from Udacity titled "DevOps Engineer for Microsoft Azure". 

## Objective 
In this project we will deploy a scalable web server in Azure platform using packer and terraform templates. We will also create a policy to disallow resources from being created without a tag.


## Pre-requisites
1. Create an Azure account
2. Install the latest version of Azure CLI
3. Install the latest version of Packer
4. Install the latest version of Terraform

## Steps
- Create a policy to deny resources without a tag from being created and assign it to the subscription.
- Using packer, create a virtual machine template
- Using terraform, provision the resources:

### Create and assign the tagging policy

Create the policy definition:
```
az policy definition create --name tagging-policy --mode indexed --rules tagging-policy.json
```
Assign the policy definition:
```
az policy assignment create --policy tagging-policy --name tagging-policy
```

To verify if the policy has been assigned, run the following command
```
az policy assignment list
```

### Build a Server image
- Get the environment variables from the Azure portal - CLIENT_ID, CLIENT_SECRET, SUBSCRIPTION_ID and populate the variables section of the server.json.
- Ensure that the builders and provisioners are configured properly.

#### Build image using the packer template
```
packer build server.json
```
### Deploy the infrastructure resource
- Ensure that all the variables including node_count and location are configured in variables.tf

#### Plan the infrastructure
```
terraform plan -out solution.plan
```
#### Provision the infrastructure resource
```
terraform apply "solution.plan"
```

##### ** Destroy the resource

- Destroy the resource if you do not require it.
```
terraform destroy
```


  
