This project is part of the nanodegree program from Udacity titled "DevOps Engineer for Microsoft Azure". 

## Objective 
In this project we will deploy a scalable web server in Azure platform using packer and terraform templates. We will also create a policy to disallow resources from being created without a tag.


## Pre-requisites
1. Create an Azure account
2. Install the Azure CLI
3. Install Packer
4. Install Terraform

## Steps

### Create and assign the tagging policy

Create the policy definition:
```
az policy definition create --name tagging-policy --mode indexed --rules tagging-policy.json
```
Assign the policy definition:
```
az policy assignment create --policy tagging-policy --name tagging-policy
```
### Deploy the packer image

The following tasks are performed:

- Create a policy to deny resources without a tag from being created and assign it to the subscription.
- Using packer, create a virtual machine template
- Using terraform, provision the following resources:
  - Availability set


  
