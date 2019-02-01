 #

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
- `docker`

## Lab 1: Getting to know the environment

Since everyone will be working in the same Kubernetes cluster, it is important
that everyone works in their own namespace. This isolation prevents
interference from others.

### Creating your own namespace.
This should be created for you by the organiser prior to this workshop.

### Accessing the cluster

#### kubectl
The interaction with the cluster is done through `kubectl`.

1. Execute the provided script to enrol as a **service account**.
2. Run `kubectl cluster-info` to check that you can access the cluster.

### Accessing the dashboard.

1. Run `kubectl config view`.
2. Copy the token.
3. Run `kubectl proxy` in a terminal.
4. Open web browser and navigate to
   `http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy/`.
5. Log in using the token method (paste the token that you retrieved from the
   first step).

## Lab 2: Deploy the applications

Run the helm charts that will deploy the applications into your namespace.

## Lab 3: Play and Observe

Tracing to see how the applications are doing.

## Lab 4: Clean up

Delete all created resources in your namespace.
