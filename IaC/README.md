# IaC with Terraform

In this directory, you can find the terraform files used for deploy the infrastructure in AWS.

## Files

- main.tf
    - It contains the code for deploying the infrastructure required.
        - S3, Fargate, Lambda
- variables.tf
    - This file contains the variables that are applied on `main.tf`

## Adittional

You have to create a file called `vars.tfvars` and provide the values for `credentials` & `project`. Also, you can change the default value of `bq_dataset_name` & `gcs_bucket_name`.

Example

```sh
AWS_ACCESS_KEY_ID="Your AWS_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="Your AWS_SECRET_ACCESS_KEY"
AWS_REGION="Your AWS_REGION, default is us-east-1"
gcs_bucket_name="victims-cdmx-bucket"
```

## Execution steps

1. Be sure you have installed [terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform).
2. Creates `vars.tfvars`
3. Runs `terraform init`.
4. Runs `terraform plan -var-file="var.tfvars"`.
4. Runs `terraform apply -var-file="var.tfvars"`

If you run well all steps, terraform will deploy all the infrastructure.