# Kubernetes Workshop


<!-- vim-markdown-toc GFM -->

* [Preparation](#preparation)
* [Reference](#reference)
* [Lab 1: Getting to know the environment](#lab-1-getting-to-know-the-environment)
  * [Creating your own namespace.](#creating-your-own-namespace)
  * [1.1 Accessing the cluster](#11-accessing-the-cluster)
    * [kubectl](#kubectl)
  * [1.2 Accessing the dashboard.](#12-accessing-the-dashboard)
* [Lab 2: Deploy your BookInfo application using Helm](#lab-2-deploy-your-bookinfo-application-using-helm)
  * [What is Helm?](#what-is-helm)
  * [2.1 Install Bookinfo the usual way (without Helm)](#21-install-bookinfo-the-usual-way-without-helm)
    * [2.1.1 Deploy using the manifest](#211-deploy-using-the-manifest)
    * [2.1.2 Check the status of the pods from the dashboard](#212-check-the-status-of-the-pods-from-the-dashboard)
    * [2.1.3 Access your Bookinfo application](#213-access-your-bookinfo-application)
    * [2.1.4 Upgrade Details to version 2](#214-upgrade-details-to-version-2)
  * [2.2 Install Bookinfo with Helm](#22-install-bookinfo-with-helm)
    * [2.2.1 Install tiller into your own namespace](#221-install-tiller-into-your-own-namespace)
    * [2.2.2 Install Bookinfo as 4 services](#222-install-bookinfo-as-4-services)
    * [2.2.3 Upgrade Reviews service to version 2](#223-upgrade-reviews-service-to-version-2)
    * [2.2.4 Install Reviews service version 3 along side version 2](#224-install-reviews-service-version-3-along-side-version-2)
* [Lab 3: Checking the application](#lab-3-checking-the-application)
  * [What is Prometheus?](#what-is-prometheus)
  * [3.1 Application Logs](#31-application-logs)
  * [3.2 Metrics](#32-metrics)
* [Lab 4: Trace with Jaegar](#lab-4-trace-with-jaegar)
  * [What is Jaegar?](#what-is-jaegar)
  * [4.1 Access Jaegar](#41-access-jaegar)
* [Lab 5: Clean up](#lab-5-clean-up)

<!-- vim-markdown-toc -->

## Preparation

The Kubernetes cluster should be created prior to this workshop with the following addons:

- Helm (with a tiller pod)
- Kubernetes dashboard
- Prometheus + Grafana (through `prometheus-operator`)
- Istio

You should have the following installed on your local machine:

- `bash`
  * Any shell/terminal that has `bash`, since there will be some bash
    scripts that need to be run.
- `kubectl`
  * Ensure that `kubectl` is in the $PATH of `bash`.
- `helm`

## Reference

- _username_ - The user that is created for you by the organiser for this
  workshop. Should be your first name appended with the first letter of your
  last name.
- _your_namespace_ - The namespace that is created for you by the organiser for
  this workshop. Should be the same as your username.

# Lab 1: Getting to know the environment

Since everyone will be working in the same Kubernetes cluster, it is important
that everyone works in their own namespace. This isolation prevents
interference from others.

## Creating your own namespace.
This should be created for you by the organiser prior to this workshop.

## 1.1 Accessing the cluster

### kubectl
The interaction with the cluster is done through `kubectl`.

1. Execute the provided script to enrol as a **service account**.

2. Run `kubectl cluster-info` to check that you can access the cluster.

## 1.2 Accessing the dashboard.

1. Run `kubectl config view`.

2. Copy the token.

3. Run `kubectl proxy`, do not close the terminal.

4. Open your web browser and navigate to: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/)

5. Log in using the `token` method (paste the token that you retrieved from the
   first step).

# Lab 2: Deploy your BookInfo application using Helm

[NOTE]
Disclaimer:
The code for this lab is taken from [Istio's BookInfo
Application Tutorial](https://istio.io/docs/examples/bookinfo/).

Run the helm charts that will deploy the BookInfo application into your
namespace. The BookInfo application is 

## What is Helm?

## 2.1 Install Bookinfo the usual way (without Helm)

### 2.1.1 Deploy using the manifest

Run the commands below from the `lab-2` directory.

1. Replace the `namespace` in the _Deployment_ and _Service_ resources in
   `bookinfo.yml`
   to use _your_namespace_.

    ```yaml
    namespace: your_namespace
    ```

2. Deploy Bookinfo into your namespace

    ```bash
    kubectl apply -f bookinfo.yml
    ```

### 2.1.2 Check the status of the pods from the dashboard

1. Run the proxy to the cluster

    ```bash
    kubectl proxy
    ```
2. Access the dashboard: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/)

3. Navigate to your namespace and check if all 4 pods are running.

4. Then check if the 4 services associated with the 4 pods are created correctly.

### 2.1.3 Access your Bookinfo application

1. Run the proxy to the cluster

    ```bash
    kubectl proxy
    ```

2. Access the Productpage service

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/productpage:9080/proxy/
    ```

3. You should be able to see the Productpage.

### 2.1.4 Upgrade Details to version 2

1. Replace the container image with version 2 on line 47 of `bookinfo.yml`

    ```yaml
    spec:
      containers:
      - name: details
        image: istio/examples-bookinfo-details-v2:1.8.0
    ```

2. Deploy the new version of Details

    ```bash
    kubectl apply -f bookinfo.yml
    ```

3. Access the Productpage service to see the new version

## 2.2 Install Bookinfo with Helm

### 2.2.1 Install tiller into your own namespace

For more info on this approach: [Deploy Tiller in a namespace, restricted to deploying resources only in that namespace](https://docs.helm.sh/using_helm/#example-deploy-tiller-in-a-namespace-restricted-to-deploying-resources-only-in-that-namespace)

```bash
helm init --service-account tiller --tiller-namespace your_namespace
```

### 2.2.2 Install Bookinfo as 4 services

Run the commands below from the `helm-charts` directory.

```bash
helm install productpage --namespace _your_namespace_ \
--set service.enabled=true \
productpage --debug
```

```bash
helm install reviews --namespace _your_namespace_ \
--set service.enabled=true \
reviews --debug
```

```bash
helm install details --namespace _your_namespace_ \
--set service.enabled=true \
details --debug
```

```bash
helm install ratings --namespace _your_namespace_ \
--set service.enabled=true \
ratings --debug
```

### 2.2.3 Upgrade Reviews service to version 2

```bash
helm upgrade --namespace _your_namespace_ \
--set service.enabled=true \
--set image.repository=istio/examples-bookinfo-reviews-v2 \
reviews reviews --debug
```

### 2.2.4 Install Reviews service version 3 along side version 2

```bash
helm install reviews-v3 --namespace _your_namespace_ \
--set image.repository=istio/examples-bookinfo-reviews-v2 \
reviews --debug
```

# Lab 3: Checking the application
Now your application is deployed. Let's see how it's doing.

## What is Prometheus?

## 3.1 Application Logs
We can access the logs of pods from the Kubernetes dashboard.

1. Access the dashboard and select your namespace.


## 3.2 Metrics
The Bookinfo services have been instrumented with Prometheus.


# Lab 4: Trace with Jaegar

## What is Jaegar?
Tracing to see how the applications are doing.

## 4.1 Access Jaegar


# Lab 5: Clean up

Delete all created resources in your namespace.
