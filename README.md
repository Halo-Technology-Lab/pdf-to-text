# pdf-to-text

## Installing packages

1. Create and activate the virtual environment
```bash
python3 -m venv venv
source venv/bin/activate # Mac
venv\Scripts\activate # Windows
```

2. **Install dependencies into a Local Directory**: Use the `--target` option to install dependencies into a directory called python (this is necessary for AWS Lambda deployment):
```bash
pip install --target ./python -r requirements.txt
```

## Deployment

This project will deploy an `AWS Lambda Function` with an `API Gateway` endpoint.

1. **Install Required Tools**:
    - Install AWS CLI, Terraform, and zip utility if not already installed.

2. Sign in with the correct AWS CLI IAM credentials:
```bash
aws configure
```

3. **Create a Deployment Package**: Combine the dependencies and and Lambda function into a single ZIP file:
```bash
cd python
zip -r ../lambda_function.zip .
cd ..
zip -g lambda_function.zip lambda_function.py
rm -rf python
```

4. **Initialize Terraform**: Run the following command to initialize Terraform:
```bash
terraform init
```

5. **Review the Plan**
```bash
TF_LOG=DEBUG terraform plan -out=tfplan
```

6. **Apply the Terraform Configuration**: Deploy the resources using:
```bash
TF_LOG=DEBUG terraform apply
```
Confirm the changes when prompted. After the deployment is complete, Terraform will output the API Gateway endpoint.

7. **Test the API Endpoint**: Use curl or any HTTP client to send a POST request:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' <API_ENDPOINT>
# Replace <API_ENDPOINT> with the output from Terraform.
```

8. **Run the Destroy Command**: Use the following command to destroy all resources managed by Terraform:
```bash
terraform destroy
```

## Optional commands

1. If you no longer need Terraform files or the deployment package, you can delete them:
```bash
rm -rf .terraform terraform.tfstate* lambda_function.zip python
```

2. Refresh the state:
```bash
terraform refresh
```

3. If the problem persists, try deleting the `.terraform` directory and reinitializing:
```bash
rm -rf .terraform
terraform init
```