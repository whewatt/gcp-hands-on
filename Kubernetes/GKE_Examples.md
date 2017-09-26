# Google Container Engine Getting Started
 Google Cloud Platform (GCP) provides fully managed services for several open source projects, including Kubernetes, Hadoop, and MySQL.  These services allow one to skip the installation steps. Of course, this also means that dev, test and production environments can be created just as easily. Marketing folks call that "faster time to value". Being "fully managed" also means that GCP takes care of patches and updates going forward. Google Container Engine, often abbreviated GKE, is a fully managed Kubernetes service.  One of the best features about GKE, is that once things are up and running, all of the power and flexibility of Kubernetes is available just as if we had done a manual install.

## Prerequisites

You'll need a Google Cloud account and a Google Cloud project.  Visit https://cloud.google.com/free/ and take care of that. The easiest way to follow along is to use the Cloud Shell included in the console.  You can also do the work on a local machine.  To use a local machine, you'll need to install the Google Cloud SDK and Docker.

## Step 1:  Create the cluster

This requires one command, executed from a shell. 

`$ gcloud container clusters create tomcat-cluster --num-nodes=3`

This command will create a Kubernetes cluster, named "tomcat-cluster", with an initial size of 3 nodes.  That will take a few minutes to complete, so we can open another terminal window and work on other things while it runs.

## Step 2: Push a container to GCP

Google Cloud Platform has its own container registry. The containers that run on our Kubernetes cluster will be deployed from there. We need a Docker image to deploy.  Any Docker image is fine for our purposes.  I just wanted something basic, so I copied the Dockerfile from https://github.com/docker-library/tomcat/blob/master/9.0/jre8/Dockerfile. 

NOTE: If you are using this Tomcat Dockerfile in the cloud shell, you'll need to make a small change due to security restrictions in the cloud shell. Change the string "ha.pool.sks-keyservers.net" to "hkp://h.pool.sks-keyservers.net:80".  

We need to build the container locally, with a tag specific to the Google Container Registry, and we need to push it to GCP. 

`$ docker build -t gcr.io/{Your_GCP_Project_Id}/{YourTag}:{VersionNumber} . 
$ gcloud docker -- push gcr.io/{Your_GCP_Project_Id}/{YourTag}:{VersionNumber} 
The push refers to a repository [gcr.io/{Your_GCP_Project}/{YourTag}] 
2059f6dd4cfe: Pushed 
85ad90303d66: Pushed 
d92e35341467: Pushed 
5ff35ab4677f: Pushed 
79af0697ecad: Pushed 
450191d1bc48: Pushed 
7c4b0bc8ce5c: Pushed 
b25af04c555a: Pushed 
ecd6fc67f321: Pushed 
beac600910c5: Pushed 
3a2b128b60f6: Pushed 
596280599f68: Layer already exists 
5d6cbe0dbcf9: Layer already exists 
9.0: digest: sha256:b2c01eda943d340d5f4c41f760d66e7924ce7ccdeee89349455eb603c3d5d6fa size: 3043`

Note that in the "gcloud docker" command, there is a space after the two dashes.

## Step 3:  Verify the cluster

Before going any further, we need to know that the cluster from Step 1 is up and running. When the "create cluster" command returns, we should see output similar to this: 

`Creating cluster tomcat-cluster...done. 
Created [https://container.googleapis.com/v1/projects/{Your_GCP_Project}/zones/us-east1-c/clusters/tomcat-cluster]. 
kubeconfig entry generated for tomcat-cluster. 
NAME ZONE MASTER_VERSION MASTER_IP MACHINE_TYPE NODE_VERSION NUM_NODES STATUS 
tomcat-cluster us-east1-c 1.5.7 xxx.xxx.xxx.xxx n1-standard-1 1.5.7 3 RUNNING`

If everything is good, we can also see the 3 VMs that were created as the nodes. 

'$ gcloud compute instances list NAME ZONE MACHINE_TYPE PREEMPTIBLE INTERNAL_IP EXTERNAL_IP STATUS gke-tomcat-cluster-default-pool-ab304fb6-068d us-east1-c n1-standard-1 10.142.0.5 x.x.x.x RUNNING gke-tomcat-cluster-default-pool-ab304fb6-gfs9 us-east1-c n1-standard-1 10.142.0.6 x.x.x.x RUNNING gke-tomcat-cluster-default-pool-ab304fb6-ks33 us-east1-c n1-standard-1 10.142.0.4 x.x.x.x RUNNING'

## Step 4: Deploy the container

Now that the Kubernetes cluster is up, GKE gets out of the way. We can manage Kubernetes with the same utilities as if we had done the install manually. Let's get the Docker image deployed on the cluster.  Note that we're switching from the GCP specific commands to the normal kubectl commands. 

`$ kubectl run tomcat-cluster --image=gcr.io/{Your_GCP_Project}/{YourTag}:{VersionNumber} --port 8080 
deployment "tomcat-cluster" created`

Kubernetes will now show us the pod. 

`$ kubectl get pods 
NAME READY STATUS RESTARTS AGE 
tomcat-cluster-599838105-2f7x7 1/1 Running 0 1m` 

We need to put a load balancer in front of the cluster and get the external IP address. [

`$ kubectl expose deployment tomcat-cluster --type=LoadBalancer --port 8080
service "tomcat-cluster" exposed 
$ kubectl get service 
NAME CLUSTER-IP EXTERNAL-IP PORT(S) AGE 
kubernetes 10.27.240.1 443/TCP 1h 
tomcat-cluster 10.27.241.99 xx.xxx.xx.xxx 8080:30636/TCP 1m`

Taking the EXTERNAL-IP address from the previous output, we should now be able to reach Tomcat at http://xx.xxx.xx.xxx:8080.

Awesome! Eight commands and we've got a container running on Kubernetes! But...wait. This all got started under GKE. Can we really access everything as if we had done the Kubernetes install myself? Absolutely. Let's try to bring up the Kubernetes dashboard. We just need one extra step for Google Cloud security. 

`$ gcloud container clusters get-credentials tomcat-cluster --zone={Your_GCP_Zone} --project={Your_GCP_Project} 
Fetching cluster endpoint and auth data. 
kubeconfig entry generated for tomcat-cluster. 
$ kubectl proxy`

The kubectl proxy command will set up port forwarding from the local machine to the remote Kubernetes dashboard. Accessing http://localhost:8001/ui brings up the Kubernetes dashboard.