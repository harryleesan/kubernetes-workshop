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
* [Lab 4: Trace with Jaeger [5 minutes]](#lab-4-trace-with-jaeger-5-minutes)
  * [What is Istio?](#what-is-istio)
  * [What is Jaeger?](#what-is-jaeger)
  * [4.1 Enable Istio](#41-enable-istio)
  * [4.2 Access Jaeger](#42-access-jaeger)
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

- _username_ - The user that is created for you by the organiser of this
  workshop. This should be your first name appended with the first letter of your
  last name.
- _your_namespace_ - The namespace that is created for you by the organiser for
  this workshop. This should be the same as your username.

# Lab 1: Getting to know the environment [5 minutes]

Since everyone will be working in the same Kubernetes cluster, it is important
that everyone works in their own namespace. This isolation prevents
interference from others.

## Creating your own namespace.
This should be created for you by the organiser prior to this workshop.

## 1.1 Accessing the cluster
The interaction with the cluster is done through `kubectl`. This is the
Kubernetes client installed on your local machine that makes API calls to the Kubernetes cluster.

1. Execute the provided script to enroll as a **service account**.

    ```bash
    chmod +x username-enroll.sh
    ./username-enroll.sh <token>
    ```

2. Run `kubectl get all --namespace your_namespace` to verify that you can access the cluster.
Don't worry, it's working if you see _No resources found_.

## 1.2 Accessing the dashboard
The Kubernetes dashboard is a powerful tool which provides a GUI for you to
visualise the internal workings of the Kubernetes cluster.

1. Run `kubectl config view`.

2. Copy the _token_.

3. Run `kubectl proxy`, do not close the terminal.

4. Open your web browser and navigate to: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/).

5. Log in using the `token` method (paste the token that you retrieved from 
   step 2).

6. Now you can view resources in your `namespace`.

# Lab 2: Deploy your BookInfo application [10 minutes]
[NOTE]
Disclaimer: The code for this lab is taken from [Istio's BookInfo
Application Tutorial](https://istio.io/docs/examples/bookinfo/).

## 2.1 Deploy using the manifest (without Helm)

1. Replace all occurrence of `namespace` in the _Deployment_ and _Service_ resources in
   `bookinfo.yml` with _your_namespace_.

    ```yaml
    # replace namespace: 111 with
    namespace: your_namespace
    ```

2. Deploy Bookinfo into your namespace

    ```bash
    kubectl apply -f bookinfo.yml
    ```

## 2.2 Check the status of the pods from the dashboard

1. From the Kubernetes dashboard, navigate to your namespace and check if all 4 pods are running.

2. Verify that the 4 services associated with the 6 pods are created correctly.
   They should be named, _productpage-v1_, _details-v1_, _reviews-v1_, _reviews-v2_, _reviews-v3_ and _ratings-v1_.

## 2.3 View the application Logs
We can access the logs of pods from the Kubernetes dashboard.

1. Select `pods` and view the logs of your pods. Productpage does not log to
   _stdout, so you won't be able to view any logs for this pod.

## 2.4 Access your BookInfo application

1. Access the Productpage service (ensure that the proxy is still running)

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/productpage:9080/proxy/productpage
    ```

2. You should be able to see the Productpage.

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

3. From the Kubernetes dashboard, verify that the image for `details-v1` pod is updated.

4. Access the Productpage service to see the new changes for the Details
   service. You should see two new fields in the Details section.


# Lab 3: Metrics with Prometheus [5 minutes]
Now your application is deployed. Let's see how it's doing.

## What is Prometheus?

## 3.1 Container Metrics
The Kubernetes cluster natively exposes metrics in the Prometheus format. We can view the
metrics using Grafana.

1. Accessing Grafana through port forwarding.

    ```bash
    kubectl -n monitoring port-forward svc/grafana 3000
    ```

2. Login using username: `user` password: `user`.

3. Click **Home** on the top left. You should see a list of dashboards. You can
   now go and explore what each dashboard does.

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

Ensure tiller is running: `helm --tiller-namespace your_namespace list`

## 5.3 Install Bookinfo as 4 services

1. Run the commands below from the `helm-charts` directory.

    ```bash
    helm --tiller-namespace your_namespace install \
    --namespace your_namespace \
    --name productpage \
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

2. Verify your Productpage service is running (ensure that `kubectl proxy` is still running)

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/productpage:9080/proxy/productpage
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

1. Have a look at the new revision for Reviews that you have created in 5.4

    ```bash
    helm --tiller-namespace your_namespace list
    ```

    - You should see two revisions for the `reviews` release.

2. Rollback to a previous version

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


# Lab 6: Clean up [5 minutes]

Delete all created resources in your namespace.

## 6.1 Delete helm releases

    ```bash
    helm --tiller-namespace your_namespace delete productpage
    helm --tiller-namespace your_namespace delete reviews
    helm --tiller-namespace your_namespace delete reviews-v3
    helm --tiller-namespace your_namespace delete details
    helm --tiller-namespace your_namespace delete ratings
    ```
