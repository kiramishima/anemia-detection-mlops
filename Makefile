build_lambda:
	./scripts/build_local_lambda_image.sh

build_mage:
	./scripts/build_local_mage_image.sh

build_evidently:
	./scripts/build_local_evidently_image.sh

build_mlflow:
	./scripts/build_local_mlflow_image.sh

deploy_local:
	cd Workflow && ../scripts/start_local.sh

deploy_local_no_docker:
	cd Workflow && ../scripts/local_without_docker.sh

deploy_aws:
	cd IaC && terraform init && terraform plan -var-file="variables.tfvars"