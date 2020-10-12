az aks get-credentials --resource-group $(terraform output resource_group_name) --name $(terraform output kubernetes_cluster_name)

kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --user=clusterUser

az aks enable-addons --addons kube-dashboard --resource-group $(terraform output resource_group_name) --name $(terraform output kubernetes_cluster_name)

az aks browse --resource-group $(terraform output resource_group_name) --name $(terraform output kubernetes_cluster_name)
