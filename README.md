# Kubernetes Workshop

<!-- vim-markdown-toc GFM -->

  * [Preparation](#preparation)
  * [Reference](#reference)
* [Lab 1: Getting to know the environment [5 minutes]](#lab-1-getting-to-know-the-environment-5-minutes)
  * [Creating your own namespace.](#creating-your-own-namespace)
  * [1.1 Accessing the cluster](#11-accessing-the-cluster)
  * [1.2 Accessing the dashboard](#12-accessing-the-dashboard)
* [Lab 2: Deploy your BookInfo application [10 minutes]](#lab-2-deploy-your-bookinfo-application-10-minutes)
  * [2.1 Deploy using the manifest (without Helm)](#21-deploy-using-the-manifest-without-helm)
  * [2.2 Check the status of the pods from the dashboard](#22-check-the-status-of-the-pods-from-the-dashboard)
  * [2.3 View Application Logs](#23-view-application-logs)
  * [2.4 Access your Bookinfo application](#24-access-your-bookinfo-application)
  * [2.5 Upgrade Details to version 2](#25-upgrade-details-to-version-2)
* [Lab 3: Metrics with Prometheus [5 minutes]](#lab-3-metrics-with-prometheus-5-minutes)
  * [What is Prometheus?](#what-is-prometheus)
  * [3.1 Container Metrics](#31-container-metrics)
* [Lab 4: Trace with Jaegar [5 minutes]](#lab-4-trace-with-jaegar-5-minutes)
  * [What is Istio?](#what-is-istio)
  * [What is Jaegar?](#what-is-jaegar)
  * [4.1 Enable Istio](#41-enable-istio)
  * [4.2 Access Jaegar](#42-access-jaegar)
* [Lab 5: Deploy your BookInfo application using Helm [30 minutes]](#lab-5-deploy-your-bookinfo-application-using-helm-30-minutes)
  * [What is Helm?](#what-is-helm)
  * [5.1 Clean up your BookInfo services](#51-clean-up-your-bookinfo-services)
  * [5.2 Install tiller into your own namespace](#52-install-tiller-into-your-own-namespace)
  * [5.3 Install Bookinfo as 4 services](#53-install-bookinfo-as-4-services)
  * [5.4 Upgrade Reviews service to version 2](#54-upgrade-reviews-service-to-version-2)
  * [5.5 Rollback Review service to version 1](#55-rollback-review-service-to-version-1)
  * [5.6 Install Reviews service version 3 along side version 1](#56-install-reviews-service-version-3-along-side-version-1)
* [Lab 6: Clean up [10 minutes]](#lab-6-clean-up-10-minutes)

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

# Lab 1: Getting to know the environment [5 minutes]

Since everyone will be working in the same Kubernetes cluster, it is important
that everyone works in their own namespace. This isolation prevents
interference from others.

## Creating your own namespace.
This should be created for you by the organiser prior to this workshop.

## 1.1 Accessing the cluster

The interaction with the cluster is done through `kubectl`.

1. Execute the provided script to enrol as a **service account**.

2. Run `kubectl get all --namespace your_namespace` to check that you can access the cluster.

## 1.2 Accessing the dashboard

1. Run `kubectl config view`.

2. Copy the token.

3. Run `kubectl proxy`, do not close the terminal.

4. Open your web browser and navigate to: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/)

5. Log in using the `token` method (paste the token that you retrieved from the
   first step).

6. View resources in your `namespace` (_your_namespace_).

# Lab 2: Deploy your BookInfo application [10 minutes]
[NOTE]
Disclaimer:
The code for this lab is taken from [Istio's BookInfo
Application Tutorial](https://istio.io/docs/examples/bookinfo/).

## 2.1 Deploy using the manifest (without Helm)

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

## 2.2 Check the status of the pods from the dashboard

1. Run the proxy to the cluster

    ```bash
    kubectl proxy
    ```
2. Access the dashboard: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/)

3. Navigate to your namespace and check if all 4 pods are running.

4. Then check if the 4 services associated with the 4 pods are created correctly.

## 2.3 View Application Logs
We can access the logs of pods from the Kubernetes dashboard.

1. Access the dashboard and select your namespace.

2. Select `pods` and view the logs of your pods.

## 2.4 Access your Bookinfo application

1. Run the proxy to the cluster

    ```bash
    kubectl proxy
    ```

2. Access the Productpage service

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/productpage:9080/proxy/
    ```

3. You should be able to see the Productpage.

## 2.5 Upgrade Details to version 2

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

3. From the dashboard, verify that the image for `details-v1` pod is updated.

4. Access the Productpage service to see the new changes for the Details
   service. You should see two new fields in the Details section.


# Lab 3: Metrics with Prometheus [5 minutes]
Now your application is deployed. Let's see how it's doing.

## What is Prometheus?

## 3.1 Container Metrics
The Kubernetes cluster exposes native metrics in the Prometheus format. We can view the
metrics using Grafana.

1. Accessing Grafana through port forward.

    ```bash
    kubectl -n monitoring port-forward svc/grafana 3000
    ```

2. Login using username: `user` password: `user`.

3. Click **Home** on the top left. You should see a list of dashboards. You can
   go explore what each dashboard shows.

# Lab 4: Trace with Jaeger [5 minutes]

## What is Istio?
## What is Jaeger?
Tracing to see how the applications are doing.

## 4.1 Enable Istio

1. Istio needs to be enabled for your namespace. Please ask any member of the workshop
committee to enable Istio for you.

2. After you have confirmation that Istio has been enabled for your namespace,
   head over to your Kubernetes dashboard and delete all the pods.

3. Your pods (4 Bookinfo services) will start up again. This time, you will see
   every pod now has an `istio-proxy` sidecar container.

## 4.2 Access Jaeger

1. Use port-forward to access Jaeger:

    ```bash
    kubectl -n istio-system port-forward svc/jaeger-query 16686
    ```

2. Access Jaeger UI from your web browser: [http://localhost:16686](http://localhost:16686)

# Lab 5: Deploy your BookInfo application using Helm [30 minutes]

Run the helm charts that will deploy the BookInfo application into your
namespace. The BookInfo application is..

## What is Helm?

## 5.1 Clean up your BookInfo services

1. Delete the manifest

    ```bash
    kubectl delete -f bookinfo.yml
    ```
2. Verify that all deployments and services are deleted from the dashboard.

## 5.2 Install tiller into your own namespace

For more info on this approach: [Deploy Tiller in a namespace, restricted to deploying resources only in that namespace](https://docs.helm.sh/using_helm/#example-deploy-tiller-in-a-namespace-restricted-to-deploying-resources-only-in-that-namespace)

```bash
helm init --service-account tiller --tiller-namespace your_namespace
```

## 5.3 Install Bookinfo as 4 services

1. Run the commands below from the `helm-charts` directory.

    ```bash
    helm --tiller-namespace your_namespace install \
    --namespace your_namespace \
    --name productpage \
    --set fullnameOverride=your_namespace-productpage \
    --set service.enabled=true \
    productpage --debug
    ```

2. Now do the same for the other 3 services.

    ```bash
    helm --tiller-namespace your_namespace install \
    --namespace your_namespace \
    --name reviews \
    --set service.enabled=true \
    reviews --debug
    ```

    ```bash
    helm --tiller-namespace your_namespace install \
    --namespace your_namespace \
    --name details \
    --set service.enabled=true \
    details --debug
    ```

    ```bash
    helm --tiller-namespace your_namespace install \
    --namespace your_namespace \
    --name ratings \
    --set service.enabled=true \
    ratings --debug
    ```

3. View the status of all 4 helm releases

    ```bash
    helm --tiller-namespace your_namespace list
    ```

2. Verify your Productpage service is running (ensure that `kubectl proxy` is running)

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/your_namespace-productpage:9080/proxy/
    ```

## 5.4 Upgrade Reviews service to version 2
We have only a single version of Reviews exist, let's bump up to version
2.

1. We have pushed a new image with a new version, let's upgrade our release.

    ```bash
    helm --tiller-namespace your_namespace upgrade \
    --namespace your_namespace \
    --set service.enabled=true \
    --set image.repository=istio/examples-bookinfo-reviews-v2 \
    reviews reviews --debug
    ```

2. Check the Product page to now see stars under the Reviews section.

## 5.5 Rollback Review service to version 1
We realised that no one likes black stars for ratings! We have to revert back to
version 1.

1. Rollback to a previous version

    ```bash
    helm --tiller-namespace your_namespace rollback \
    reviews 1 --debug
    ```

## 5.6 Install Reviews service version 3 along side version 1

1. Install another helm release, but without a service since we are using the
   same service as Reviews version 1.

    ```bash
    helm --tiller-namespace your_namespace install \
    --namespace your_namespace \
    --name reviews-v3 \
    --set image.repository=istio/examples-bookinfo-reviews-v3 \
    reviews --debug
    ```

2. Refresh Productpage a few times to see the Reviews section alternate between
   version 1 and version 3.


# Lab 6: Clean up [10 minutes]

Delete all created resources in your namespace.
