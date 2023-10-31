#!/bin/bash

## exporting module name
export MODULE=${1}
## exporting the datetime
export DATE=$(date +%d%m%Y%H%M%S)
## exporting vars to tf_vars
shift
for ARGUMENT in "${@}"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"
   export "TF_VAR_$KEY"="$VALUE"
done

export GITMODULE="https://git.zulu.house/zulunity/$MODULE.git"
## acquiring state bucket
export BUCKET="$(aws s3api list-buckets --query 'Buckets[?starts_with(Name, `zulunity-remote-state`)].{Name:Name, CreationDate:CreationDate}' | jq -r 'sort_by(.CreationDate)|reverse|.[0].Name')"
## acquiring account
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity  | jq -r .Account)"
## echo summary
echo "========== Script to install AWS $MODULE on $AWS_ACCOUNT_ID ========"
## Asking for required packages
if [ -z `which tofu` ]
then
    # Install tofu
    wget https://github.com/opentofu/opentofu/releases/download/v1.6.0-alpha3/tofu_1.6.0-alpha3_linux_amd64.zip
    unzip tofu_1.6.0-alpha3_linux_amd64.zip
    chmod +x tofu
    sudo mv tofu /usr/local/bin/tofu

fi

# Clone MODULE
git clone $GITMODULE
# Enter into the repo 
cd $MODULE
# Terraform 
echo -en 'terraform {\n  backend "s3" {}\n}' > backend.tf
export TF_VAR_account_id="$AWS_ACCOUNT_ID"
export TF_VAR_description="AWS $MODULE"
export TF_VAR_region="$AWS_REGION"
tofu init \
    -backend-config="bucket=$BUCKET" \
    -backend-config="key=$MODULE" \
    -backend-config="region=$AWS_REGION"
tofu apply -auto-approve
