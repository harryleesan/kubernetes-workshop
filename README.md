# Kubernetes Workshop

## Workshop Register:

[2019-02-04 CNCJ Meetup: The Kubernetes Playground](https://goo.gl/forms/nJla7fHRbjFzP9E92)

## Table of Contents

<!-- vim-markdown-toc GFM -->

  * [Preparation](#preparation)
  * [Reference](#reference)
* [Lab 1: Getting to know the environment [5 minutes]](#lab-1-getting-to-know-the-environment-5-minutes)
  * [Accessing the Kubernetes cluster](#accessing-the-kubernetes-cluster)
  * [1.1 Accessing the cluster](#11-accessing-the-cluster)
  * [1.2 Accessing the dashboard](#12-accessing-the-dashboard)
* [Lab 2: Deploy your BookInfo application [10 minutes]](#lab-2-deploy-your-bookinfo-application-10-minutes)
  * [2.1 Deploy using the manifest (without Helm)](#21-deploy-using-the-manifest-without-helm)
  * [2.2 Check the status of the pods from the dashboard](#22-check-the-status-of-the-pods-from-the-dashboard)
  * [2.3 View the application logs](#23-view-the-application-logs)
  * [2.4 Access your BookInfo application](#24-access-your-bookinfo-application)
  * [2.5 Update Details to version 2](#25-update-details-to-version-2)
  * [2.6 Deploying reviews-v2 and reviews-v3 alongside reviews-v1](#26-deploying-reviews-v2-and-reviews-v3-alongside-reviews-v1)
* [Lab 3: Cluster metrics with Prometheus [5 minutes]](#lab-3-cluster-metrics-with-prometheus-5-minutes)
  * [3.1 Cluster Metrics](#31-cluster-metrics)
    * [Advanced](#advanced)
* [Lab 4: Trace with Jaeger [5 minutes]](#lab-4-trace-with-jaeger-5-minutes)
  * [4.1 Enable Istio](#41-enable-istio)
  * [4.2 Access Jaeger](#42-access-jaeger)
* [Lab 5: Deploy BookInfo using Helm [30 minutes]](#lab-5-deploy-bookinfo-using-helm-30-minutes)
  * [5.1 Clean up your BookInfo services](#51-clean-up-your-bookinfo-services)
  * [5.2 Install tiller into your own namespace](#52-install-tiller-into-your-own-namespace)
  * [5.3 Install BookInfo using 4 helm charts](#53-install-bookinfo-using-4-helm-charts)
  * [5.4 Upgrade Reviews service to version 2](#54-upgrade-reviews-service-to-version-2)
  * [5.5 Rollback Review service to version 1](#55-rollback-review-service-to-version-1)
  * [5.6 Install Reviews service version 3 alongside version 1](#56-install-reviews-service-version-3-alongside-version-1)
    * [Advanced](#advanced-1)
* [Lab 6: Assign a hostname to BookInfo [5 minutes]](#lab-6-assign-a-hostname-to-bookinfo-5-minutes)
  * [6.1 Installing Istio's VirtualService](#61-installing-istios-virtualservice)
    * [Advanced](#advanced-2)
* [Lab 7: Clean up [5 minutes]](#lab-7-clean-up-5-minutes)
  * [7.1 Delete the helm releases](#71-delete-the-helm-releases)

<!-- vim-markdown-toc -->

## Preparation

The Kubernetes cluster should be created prior to this workshop with the following addons:

* Kubernetes Dashboard
* Prometheus + Grafana (through `prometheus-operator`)
* Istio + Jaeger

You should have the following installed on your local machine:

* `bash`
  * Any shell/terminal that has `bash`, since there will be some bash
    scripts that need to be run.
* `kubectl`
  * Ensure that `kubectl` is in the $PATH of `bash`.
* `helm`

## Reference

* _username_ - The user that is created for you by the organiser of this
  workshop. This should be your first name appended with the first letter of your
  last name.
* _your_namespace_ - The namespace that is created for you by the organiser for
  this workshop. This should be the same as your username.

# Lab 1: Getting to know the environment [5 minutes]

Since everyone will be working in the same Kubernetes cluster, it is important
that everyone works in their own namespace without interfering others.

## Accessing the Kubernetes cluster

Your **namespace** should have been created for you by the organiser prior the workshop.

## 1.1 Accessing the cluster

The interaction with the cluster is done through `kubectl`. This is the
Kubernetes client installed on your local machine that interacts with the Kubernetes cluster.

1. A bash script (`enroll.sh`) is provided in the repo root directory. Execute the provided script to
   enroll as a **service account**.

    ```bash
    chmod +x enroll.sh
    ./enroll.sh <token>
    ```

    * Your namespace/user name and \<token\> will be emailed to the email address
      that you entered in the Workshop Register.

2. Run `kubectl get all --namespace your_namespace` to verify that you can access the cluster.
   Don't worry, it's working if you see _No resources found_.

## 1.2 Accessing the dashboard

The Kubernetes dashboard is a powerful tool which provides a GUI for you to
visualise the internal workings of the Kubernetes cluster.

1. Run `kubectl config view`.

2. Copy the _token_.

3. Run `kubectl proxy`, leave it running and do not close the terminal.

4. Open your web browser and navigate to: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/).

5. Log in using the `token` method (paste the token that you retrieved from
   step 2).

6. Now you can view resources in your `namespace`.

# Lab 2: Deploy your BookInfo application [10 minutes]

Disclaimer: The code for this lab is taken from [Istio's BookInfo
Application Tutorial](https://istio.io/docs/examples/bookinfo/).

We have a BookInfo application that is composed of 4 microservices. They have
been "dockerised" and the docker images are stored on Docker Hub (public
repository). Let's see how we can deploy these 4 services into our Kubernetes
cluster.

## 2.1 Deploy using the manifest (without Helm)

1. Replace all `namespace` in the _Deployment_ and _Service_ resources in
   `bookinfo.yml` with _your_namespace_.

    ```yaml
    # replace namespace: your_namespace with the namespace that is assigned to you.
    # e.g.
    namespace: harryl
    ```

2. Deploy the 4 services of BookInfo into your namespace

    ```bash
    kubectl apply -f bookinfo.yml
    ```

## 2.2 Check the status of the pods from the dashboard

We have just deployed our BookInfo application (as 4 separate services) into our
cluster. Let's see how they are doing.

1. From the Kubernetes dashboard, navigate to your namespace.

2. Verify that the 4 services associated with the 6 pods are created correctly.
   They should be named, _productpage-v1_, _details-v1_, _reviews-v1_, _reviews-v2_, _reviews-v3_ and _ratings-v1_.

## 2.3 View the application logs

We can access the logs of the pods from the Kubernetes dashboard.

1. Select `pods` and view the logs of your pods (try and find where they are). Productpage does not log to
   _stdout_, so you won't be able to view any logs for this pod.

## 2.4 Access your BookInfo application

Now our services and pods are running fine. Let's access Productpage and see it
in action.

1. Access the Productpage service (ensure that the proxy is still running)

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/productpage:9080/proxy/productpage
    ```

    * Replace _your_namespace_

2. Voila, You should be able to see your Productpage with a details section
   (Details service) and reviews section (Reviews service).

## 2.5 Update Details to version 2

So we realised that the information displayed in the details section is missing
a Publisher field. We quickly made the changes to the Details service, build the
docker image and pushed. Now let's see how we can swap out the old version.

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

3. From the Kubernetes Dashboard, verify that the image for `details-v1` pod is updated.

4. Access the Productpage service to see the new changes for the Details
   service. You should now see two new fields in the details section.

## 2.6 Deploying reviews-v2 and reviews-v3 alongside reviews-v1

You can route traffic between multiple pods by attaching them to a single
service.

1. You will notice that under **Reviews service** in `bookinfo.yml`, there are
   two deployments (v2 and v3) that are commented out. Remove the comments and
   apply the manifest file again.

   ```bash
   # After you have uncommented the two reviews deployments
   kubctl apply -f bookinfo.yml
   ```

2. Refresh Productpage in your web browser. You will see that each time you
   refresh, the reviews section is different (no stars, black stars and red
   stars.)

# Lab 3: Cluster metrics with Prometheus [5 minutes]

Now your application is deployed. Let's see how it's doing from the cluster's
perspective.

## 3.1 Cluster Metrics

The Kubernetes cluster natively exposes metrics in the Prometheus format. We can view the
metrics through Grafana.

1. Accessing Grafana through port forwarding.

    ```bash
    kubectl -n monitoring port-forward svc/grafana 3000
    ```

2. Login with username: `user` password: `user`.

3. Click **Home** on the top left. You should see a list of dashboards. You can
   now go and explore what each dashboard does.

### Advanced

Prometheus can also be integrated with your application to expose any type of
metrics you want. This requires you to instrument your code
(this part does not come for free). The source code for the 4 microservices can
be found at [Bookinfo Sample](https://github.com/istio/istio/tree/master/samples/bookinfo).
You can look at how you can instrument the code at [Prometheus Client
Libraries](https://prometheus.io/docs/instrumenting/clientlibs/).

# Lab 4: Trace with Jaeger [5 minutes]

Let's take a look at how a request to Productpage triggers a chain of events to the other 3 services.
We can do this through tracing with Jaeger (integrated with Istio).

## 4.1 Enable Istio

1. Istio needs to be enabled for your namespace. Please ask any member of the workshop
committee to enable Istio for your namespace.

2. After you have confirmation that Istio has been enabled for your namespace,
   head over to your Kubernetes Dashboard and delete all the pods (don't delete
   the deployments).

3. Your pods (the 4 Bookinfo services) will start up again. This time, you will see that
   every pod now has an `istio-proxy` sidecar container. This is the container
   that will monitor traffic to and from your pod.

## 4.2 Access Jaeger

1. Use port-forwarding to access Jaeger:

    ```bash
    kubectl -n istio-system port-forward svc/jaeger-query 16686
    ```

2. Now you can access the Jaeger UI from your web browser: [http://localhost:16686](http://localhost:16686)

3. Note that you are viewing the requests coming in to the service mesh of the
   entire cluster, so you will see traffic to the other namespaces, not just
   yours.

# Lab 5: Deploy BookInfo using Helm [30 minutes]
Let's install the BookInfo services using Helm charts. The helm charts for the
services have already been created for you in the `helm-charts` directory.

## 5.1 Clean up your BookInfo services

1. Delete the deployments and services that we created before through
   a manifest.

    ```bash
    kubectl delete -f bookinfo.yml
    ```
2. Verify that all deployments and services are deleted by making use of the
   Kubernetes Dashboard.

## 5.2 Install tiller into your own namespace

For more info on this approach: [Deploy Tiller in a namespace, restricted to deploying resources only in that namespace](https://docs.helm.sh/using_helm/#example-deploy-tiller-in-a-namespace-restricted-to-deploying-resources-only-in-that-namespace)

1. Simply run:

    ```bash
    helm init --service-account tiller --tiller-namespace your_namespace
    ```

2. Ensure tiller is running:

    ```bash
    helm --tiller-namespace your_namespace list
    ```

## 5.3 Install BookInfo using 4 helm charts

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

2. Verify that your Productpage services is running from the Kubernetes Dashboard

## 5.4 Upgrade Reviews service to version 2

You will notice that we only have reviews-v1 deployed as a helm release. We have
just added a new feature to display ratings as black stars as part of the
Reviews service (reviews-v2). Let's upgrade our Reviews service to version 2.

1. We have already pushed a new image with the new feature, let's upgrade our release.

    ```bash
    helm --tiller-namespace your_namespace upgrade \
    --namespace your_namespace \
    --set service.enabled=true \
    --set image.repository=istio/examples-bookinfo-reviews-v2 \
    reviews reviews --debug
    ```

2. Check Productpage to see black stars under the Reviews section.

## 5.5 Rollback Review service to version 1

We realised that no one likes black stars for ratings! We have to revert back to
version 1.

1. Have a look at the new revision for Reviews that you have created in 5.4

    ```bash
    helm --tiller-namespace your_namespace list
    ```

    * You should see two revisions for the `reviews` release.

2. Rollback to a previous version

    ```bash
    helm --tiller-namespace your_namespace rollback \
    reviews 1 --debug
    ```

## 5.6 Install Reviews service version 3 alongside version 1

Let's try using stars for ratings again. This time, we will use red stars instead
of black stars. Let's deploy version 3 with version 1 so that we can do some A/B
testing.

1. Install another helm release, but without enabling an extra _service_ since we are using the
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

### Advanced

Istio has advanced traffic management which includes [Traffic Shifting](https://istio.io/docs/tasks/traffic-management/traffic-shifting/).
This is particularly useful if you want to do canary or A/B testing on your
application. After you have completed Lab 6 you can experiment with this.

# Lab 6: Assign a hostname to BookInfo [5 minutes]

We can access our BookInfo via `kubectl proxy`. But surely this is not how our
users will access our application! Let's create an URL for our BookInfo.

## 6.1 Installing Istio's VirtualService

Istio has its own _gateway_ and _virtualservice_ custom resources that we can
use to create a public facing endpoint. [Configuring ingress using an Istio Gateway](https://istio.io/docs/tasks/traffic-management/ingress/#configuring-ingress-using-an-istio-gateway)

A Gateway has been created for you in the `default` namespace. For the sake of
simplicity and ease of management, you will deploy your own virtualservice to
the `default` namespace as well.

The Gateway is integrated with [cert-manager](https://github.com/jetstack/cert-manager)
which provides a wild card certificate for our domain (*.library.yun.technology)
via LetsEncrypt.

Let's install a [Virtual Service](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService) for BookInfo.

1. Replace all occurrence of _your_namespace_ in `bookinfo-virtualservice.yml`
   with your namespace.

2. Apply the manifest and wait about 3 minutes.

    ```bash
    kubectl apply -f bookinfo-virtualservice.yml
    ```

3. Access your Productpage service at
   `https://your_namespace.library.yun.technology/productpage`

### Advanced

You can explore the different routing methods/strategies that virtualservice
enables you to do with your application such as [Traffic Shifting](https://istio.io/docs/tasks/traffic-management/traffic-shifting/).

# Lab 7: Clean up [5 minutes]

Delete all resources that you have created in your namespace.

## 7.1 Delete the helm releases

  ```bash
  helm --tiller-namespace your_namespace delete productpage
  helm --tiller-namespace your_namespace delete reviews
  helm --tiller-namespace your_namespace delete reviews-v3
  helm --tiller-namespace your_namespace delete details
  helm --tiller-namespace your_namespace delete ratings
  ```

