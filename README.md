# Google Cloud Platform Hands On

Google Cloud Free Trial Signup - https://cloud.google.com/free/

Google Cloud Console - https://console.cloud.google.com

The commands below can be executed in the Google Cloud Shell (recommended) or on a machine with the Cloud SDK.

Cloud SDK install and documentation is at https://cloud.google.com/sdk/

## Compute Engine Command Line

Create a VM:

`gcloud compute instances create new_vm_name`	

List VMs:

`gcloud compute instances list`

Delete a VM:

`gcloud compute instances delete vm_name`


## BigQuery

### BigQuery Console 

https://bigquery.cloud.google.com

### BigQuery Command Line

Query the sampe natality table:

`bq query 'SELECT * FROM [bigquery-public-data:samples.natality] LIMIT 10'`

Show table info:

`bq show publicdata:samples.natality`

Preview the first ten rows:

`bq head -n 10 publicdata:samples.natality`

Create a dataset:

`bq mk new_dataset`

Create a table:

`bq mk new_dataset.new_table`

## Machine Learning

API Demo Pages:

https://cloud.google.com/vision/

https://cloud.google.com/speech/

https://cloud.google.com/translate/

https://cloud.google.com/natural-language/
