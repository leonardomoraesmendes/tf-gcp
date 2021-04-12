# Terraform - Google Cloud Platform
Project created to provide compute instance with bootstrapping.

The requisites to running this jobs is:
- [Google Cloud Account](https://cloud.google.com/), with billing account configured and associated to a project.
- [CLI gcloud configured](https://cloud.google.com/sdk/docs/install)
- [tfenv installed and configured](https://github.com/tfutils/tfenv)

The initials steps to running this project is create a new Service Account to running terraform jobs, to do that you could use GCP Console but you can follow the steps above using gcloud CLI.

```
gcloud init
export TF_VAR_project_name='fiap-handson-leonardom'

##
## Create Service Account and key to execute Terraform
##

gcloud iam service-accounts create terraform --display-name "Terraform admin account"
gcloud iam service-accounts keys create ~/.config/gcloud/terraform-admin.json --iam-account terraform@${TF_VAR_project_name}.iam.gserviceaccount.com

##
## Grant permissions to terraform user
##

gcloud projects add-iam-policy-binding ${TF_VAR_project_name} --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com --role roles/viewer
gcloud projects add-iam-policy-binding ${TF_VAR_project_name} --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com --role roles/storage.admin
gcloud projects add-iam-policy-binding ${TF_VAR_project_name} --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com --role roles/compute.admin

##
## Export variables used by Terraform to GCP Authentication
##

export GOOGLE_APPLICATION_CREDENTIALS='~/.config/gcloud/terraform-admin.json'
export GOOGLE_PROJECT=${TF_VAR_project_name}


##
## Enable the API called by remotely Service Account 
##

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com
```

The first best practice recommends by Google and Terraform when you will use Terraform as an IaC solution is, configure your `backend` to save your state remotely. To provide this feature you can follow the next steps to create a GCS and pointing your state to use that.

```
gsutil mb -p ${TF_VAR_project_name} gs://${TF_VAR_project_name}

cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_project_name}"
   prefix  = "terraform/state"
 }
}
EOF

terraform refresh
terraform plan
```

```
terraform delete
```


References:
https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform