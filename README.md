# Kubernetes Workshop

# Preparation

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

# Reference

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

## Accessing the cluster

### kubectl
The interaction with the cluster is done through `kubectl`.

1. Execute the provided script to enrol as a **service account**.

2. Run `kubectl cluster-info` to check that you can access the cluster.

## Accessing the dashboard.

1. Run `kubectl config view`.

2. Copy the token.

3. Run `kubectl proxy`, do not close the terminal.

4. Open web browser and navigate to:

  [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/)

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

## Install tiller into your own namespace

For more info on this approach: [Deploy Tiller in a namespace, restricted to deploying resources only in that namespace](https://docs.helm.sh/using_helm/#example-deploy-tiller-in-a-namespace-restricted-to-deploying-resources-only-in-that-namespace)

```bash
helm init --service-account tiller --tiller-namespace your_namespace
```

## Deploying the BookInfo application

### Install Bookinfo the usual way (without Helm)

#### Deploy using the manifest

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

#### Check the status of the pods from the dashboard

1. Run the proxy to the cluster

    ```bash
    kubectl proxy
    ```
2. Access the dashboard

    [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/)

3. Navigate to your namespace and check if all 4 pods are up.

4. Then check if the 4 services associated with the 4 pods are created correctly.

#### Access your Bookinfo application

1. Run the proxy to the cluster

    ```bash
    kubectl proxy
    ```

2. Access the Productpage service

    ```bash
    http://localhost:8001/api/v1/namespaces/your_namespace/services/productpage:9080/proxy/
    ```

3. You should be able to see the Productpage.

#### Upgrade Details to version 2

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

### Install Bookinfo as 4 services using helm

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

### Upgrade Reviews service to version 2

```bash
helm upgrade --namespace _your_namespace_ \
--set service.enabled=true \
--set image.repository=istio/examples-bookinfo-reviews-v2 \
reviews reviews --debug
```

### Install Reviews service version 3 along side version 2

```bash
helm install reviews-v3 --namespace _your_namespace_ \
--set image.repository=istio/examples-bookinfo-reviews-v2 \
reviews --debug
```

# Lab 3: Access the application


# Lab 4: Trace with Jaegar

Tracing to see how the applications are doing.

# Lab 5: Clean up

Delete all created resources in your namespace.
