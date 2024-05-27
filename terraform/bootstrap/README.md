# Bottstrap TF backend resources
Initialize S3 bucket and service account for managing Terraform state files.

```
terraform init -var-file=../../env/dev/env.tfvars
terraform plan -var-file=../../env/dev/env.tfvars -var "yc_oauth_token=${YC_TOKEN}" -out=tf-infra.tfplan
terraform -input=false -auto-approve tf-infra.tfplan
```

To see access key values:
```
terraform output -raw  sa-s3tf-access-key
terraform output -json | jq -r '.["sa-s3tf-access-key"].value'
terraform output -raw  sa-s3tf-secret-key
terraform output -json | jq -r '.["sa-s3tf-secret-key"].value'
```

To manage objects in a bucket install [s3cmd](https://yandex.cloud/ru/docs/storage/tools/s3cmd) tool: `pip3 install s3cmd`

Configure: `s3cmd --configure`
* Access key: `$(yc iam access-key list --service-account-name sa-s3-tfstate --format json | jq -r ".[0].key_id")`
* Secret key: значение доступно только в момент создания access key (`$(terraform output -json | jq -r '.["sa-s3tf-secret-key"].value')`)
* region: `ru-central1`
* S3 endpoint: `https://storage.yandexcloud.net`
* DNS-style bucket+hostname: `%(bucket)s.storage.yandexcloud.net`
* bucket: `s3tfstate`
Edit `$HOME/.s3cfg` and fix `website_endpoint = http://%(bucket)s.website.yandexcloud.net`

Push bootstrap state to bucket:
```
s3cmd put terraform.tfstate s3://s3tfstate/bootstrap.tfstate
```

Pull bootstrap state from bucket for subsequent run:
```
s3cmd get s3://s3tfstate/bootstrap.tfstate terraform.tfstate 
```