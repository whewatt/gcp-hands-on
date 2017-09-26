#!/bin/bash
#See instructions at https://cloud.google.com/dlp/docs/quickstart-json to get a private key file
#May need to get a fresh access token
#  gcloud auth activate-service-account --key-file=JSON key file
#  gcloud auth print-access-token
#Then insert the access token into the command below
curl -s -k -H "Authorization: Bearer {Your Access Token Here}"  -H "Content-Type: application/json"   https://dlp.googleapis.com/v2beta1/content:inspect -d @dlp-request.json

