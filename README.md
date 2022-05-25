# Lacework Kubernetes Admission Controller

## Purpose

Provide a quick workshop to understand how to use the K8s AC with the Lacework platform.

> :warning: **This is not intended for production use as the generated certificates only live in the terraform state file.**

## Prerequisites

1. Functioning K8s Cluster
2. Active Lacework Account

## Steps

1. Create a Lacework Proxy scanner token

https://docs.lacework.com/integrate-proxy-scanner#create-a-proxy-scanner-integration-in-lacework

2. In your lacework account, enable the Critical CVE (LW_CONTAINER_POLICY_4) and apt-get caches are not cleared in Dockerfile (LW_CONTAINER_POLICY_10) policies and associate them to the proxy scanner you created.

https://docs.lacework.com/container-vulnerability-policies#default-policies

https://docs.lacework.com/container-vulnerability-policies#associate-policies-with-a-registry-integration

3. Run Terraform apply to setup the certs & helm chart for the admission controller + proxy scanner

```bash
$ terraform apply -var "account=<youraccount>" -var "int_token=<proxyscannertoken>"
```

4. Validate that the proxy scanner & admission controller is running in your cluster

```bash
$ kubectl get pods -n lacework
...
lacework      lacework-admission-controller...   Running
lacework      lacework-proxy-scanner...          Running
...
```

5. Tail the logs of the admission controller in a separate terminal

```bash
$ kubectl logs $(kubectl get pods -n lacework -l app=lacework-admission-controller -o name) -n lacework -f
...
[INFO]:   2022-05-25 01:24:23 - Starting server..
[INFO]:   2022-05-25 01:24:23 - Listener started..
...
```

6. While logs are tailing, create a deployment file with an older image of nginx

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.11.9
        ports:
        - containerPort: 80
```

7. Attempt to create the deployment, you should be stopped by the admission controller noting that the image failed the policies you configured in your Lacework tenant.

```bash
➜  ~ kubectl apply -f deployment.yaml
Error from server: error when creating "deployment.yaml": admission webhook "validate.lacework.net" denied the request: Violations the following policies:
LW_CONTAINER_POLICY_10 - apt-get caches are not cleared in Dockerfile - fail on violation: true
LW_CONTAINER_POLICY_4 - Critical CVEs - fail on violation: true
```

8. Enjoy a tasty beverage :beer:
