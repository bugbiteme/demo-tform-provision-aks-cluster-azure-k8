# Learn Terraform - Provision AKS Cluster

This repo is a companion repo to the [Provision an AKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-aks-cluster), containing
Terraform configuration files to provision an AKS cluster on
Azure.

After installing the Azure CLI and logging in. Create an Active Directory service
principal account.

```shell
$ az ad sp create-for-rbac --skip-assignment
{
  "appId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "displayName": "azure-cli-2019-04-11-00-46-05",
  "name": "http://azure-cli-2019-04-11-00-46-05",
  "password": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "tenant": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
}
```

Then, replace `terraform.tfvars` values with your `appId` and `password`. 
Terraform will use these values to provision resources on Azure.

After you've done this, initalize your Terraform workspace, which will download 
the provider and initialize it with the values provided in the `terraform.tfvars` file.

```shell
$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.27.0)...

Terraform has been successfully initialized!
```


Then, provision your AKS cluster by running `terraform apply`. This will 
take approximately 10 minutes.

```shell
$ terraform apply

# Output truncated...

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

# Output truncated...

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kubernetes_cluster_name = light-eagle-aks
resource_group_name = light-eagle-rg
```

## Configure kubectl

To configure kubetcl run the following command:

```shell
$ az aks get-credentials --resource-group light-eagle-rg --name light-eagle-aks;
```

The
[resource group name](https://github.com/hashicorp/learn-terraform-provision-aks-cluster/blob/master/aks-cluster.tf#L16)
and [AKS name](https://github.com/hashicorp/learn-terraform-provision-aks-cluster/blob/master/aks-cluster.tf#L25)
 correspond to the output variables showed after the successful Terraform run.

You can view these outputs again by running:

```shell
$ terraform output
```

## Configure Kubernetes Dashboard

To use the Kubernetes dashboard, we need to create a `ClusterRoleBinding`. This
gives the `cluster-admin` permission to access the `kubernetes-dashboard`.

```shell
$ kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
```

Finally, to access the Kubernetes dashboard, run the following command:

```shell
$ az aks browse --resource-group light-eagle-rg --name light-eagle-aks
Merged "light-eagle-aks" as current context in /var/folders/s6/m22_k3p11z104k2vx1jkqr2c0000gp/T/tmpcrh3pjs_
Proxy running on http://127.0.0.1:8001/
Press CTRL+C to close the tunnel...
```

 You should be able to access the Kubernetes dashboard at [http://127.0.0.1:8001/](http://127.0.0.1:8001/).

## Additional notes

Once `terraform apply` completes, run the shell script `sh config-launch-k8-dashboard.sh` to enable and run the k8 dashboard

Authenticate to the Kubernetes Dashbaord via `Kubeconfig` and select the file `~/.kube/config`.

In a separate console, you can run the following commands to launch a multi-tiered application:
Source: https://k8s.camp/workshop/intro/#257

```shell
kubectl apply -f ./dockercoins.yaml

kubectl get pods

NAME                      READY   STATUS    RESTARTS   AGE
hasher-99d4fdc78-27fnj    1/1     Running   0          52s
redis-65fd448c9b-bjvhv    1/1     Running   0          52s
rng-6979b4858b-zffvg      1/1     Running   0          52s
webui-97d9f77cf-bl664     1/1     Running   0          52s
worker-598788db65-nf65w   1/1     Running   0          52s

kubectl get svc

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
hasher       ClusterIP   10.0.128.6     <none>        80/TCP         103s
kubernetes   ClusterIP   10.0.0.1       <none>        443/TCP        11m
redis        ClusterIP   10.0.160.51    <none>        6379/TCP       103s
rng          ClusterIP   10.0.107.153   <none>        80/TCP         103s
webui        NodePort    10.0.14.108    40.64.104.3   80:31242/TCP   103s
```

To follow the logs of the worker pod

`kubectl logs deploy/worker --follow`


To connect to the webui, copy/past the `EXTERNAL-IP` into your web browser (give it a few seconds)

Have fun increasing replicas of the services (via CLI or YAML)

To clean up you k8 deployment

`kubectl delete -f dockercoins.yaml`

To destroy this k8 cluster

`terraform destroy`