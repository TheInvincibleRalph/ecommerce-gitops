# ecommerce-gitops

Terraform builds the cloud, authenticates into the cluster, installs the platform (ArgoCD), and connects the GitOps bridge.

Without the resources-finalizer.argocd.argoproj.io finalizer, deleting an application will not delete the resources it manages. To perform a cascading delete, you must add the finalizer. See App Deletion. (https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#about-the-deletion-finalizer)


This command tells Terraform to only build the VPC and the EKS cluster, completely ignoring the kubernetes_manifest and helm_release blocks at the bottom of your file.

The kubernetes_manifest resource needs access to the API server of the cluster during planning. This is because, in order to support CRDs in Terraform ecosystem, we need to pull the schema information for each manifest resource at runtime (during planing). You can achieve this as simply as using the -target CLI argument to Terraform to limit the scope of the first apply to just the cluster and it's direct dependencies. Then you follow up with a second apply without a -target argument and this constructs the rest of the resources (manifest & others). You will end up with a single state file and subsequent updates no longer require this two-step approach as long as the cluster resource is present.


This resource requires API access during planning time. This means the cluster has to be accessible at plan time and thus cannot be created in the same apply operation. We recommend only using this resource for custom resources or resources not yet fully supported by the provider. (https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest#before-you-use-this-resource)

terraform apply -target=module.vpc -target=module.eks -var-file="prod.tfvars"


╷
│ Error: API did not recognize GroupVersionKind from manifest (CRD may not be installed)
│ 
│   with kubernetes_manifest.root_app,
│   on main.tf line 57, in resource "kubernetes_manifest" "root_app":
│   57: resource "kubernetes_manifest" "root_app" {
│ 
│ no matches for kind "Application" in group "argoproj.io"
╵

Run a targeted apply to specifically deploy the Helm release. This forces Terraform to install ArgoCD and register the Application CRD into the Kubernetes API without looking at your custom manifest.

terraform apply -target=helm_release.argocd -var-file="prod.tfvars"



When you tear down the cluster you might see this error...
╷
│ Warning: Helm uninstall returned an information message
│ 
│ These resources were kept due to the resource policy:
│ [CustomResourceDefinition] applications.argoproj.io
│ [CustomResourceDefinition] applicationsets.argoproj.io
│ [CustomResourceDefinition] appprojects.argoproj.io
│ 


Terraform
  set {
    name  = "crds.keep"
    value = "true"
  }
Helm is just doing exactly what we told it to do.

In a standard production environment, if you accidentally uninstall the ArgoCD software, you do not want Kubernetes to panic and instantly delete every single Application you have configured. By keeping the CRDs (the dictionary definitions for what an "Application" is), your configurations stay safe in the cluster's memory until you reinstall ArgoCD.

After Helm uninstalled ArgoCD it safely left the CRD dictionary inside the EKS cluster's database. 


Every time you run terraform destroy and then terraform apply, AWS throws away the old control plane and generates a brand-new, randomized API endpoint for the new cluster. However, your laptop's .kube/config file doesn't know that; it would still try to call the old API endpoint..

aws eks update-kubeconfig --name gitops-ecommerce-prod --region us-east-2