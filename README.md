# aws-apply
AWS apply

# Description

This script will allow zulunity to apply infrastructure modules on AWS using a cloud shell session.

## Execution

- Log into your AWS CloudShell and execute(Replacing MODULE with the zulunity module desired) 

```sh
bash -c "$(curl https://raw.githubusercontent.com/zulunity/aws-apply/main/script.sh)" -s MODULE
```