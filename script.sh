#!/bin/bash
export MODULE=${1}
export GITMODULE="https://nrepo.nextia.space/GiteaAdmin/$MODULE.git"
## acquiring state bucket
export BUCKET="$(aws s3api list-buckets --query 'Buckets[?starts_with(Name, `zulunity-remote-state`)].{Name:Name, CreationDate:CreationDate}' | jq -r 'sort_by(.CreationDate)|reverse|.[0].Name')"
## acquiring account
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity  | jq -r .Account)"
## echo summary
echo "========== Script to install AWS $MODULE on $AWS_ACCOUNT_ID ========"
## Asking for required packages
if [ -z `which terraform` ]
then
    # Install yum-utils
    sudo yum install -y yum-utils
    # Use yum-config-manager to add the official HashiCorp Linux repository.
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    # Install terraform 
    sudo yum -y install terraform 1.5.6-1
fi

# Clone MODULE
git clone $GITMODULE
# Enter into the repo 
cd $MODULE
# Terraform 
echo -en 'terraform {\n  backend "s3" {}\n}' > backend.tf
export TF_VAR_account_id="$AWS_ACCOUNT_ID"
export TF_VAR_description="AWS $MODULE"
terraform init \
    -backend-config="bucket=$BUCKET" \
    -backend-config="key=state" \
    -backend-config="region=$AWS_REGION"
terraform apply -auto-approve