# ecommerce-gitops

Terraform builds the cloud, authenticates into the cluster, installs the platform (ArgoCD), and connects the GitOps bridge.

Without the resources-finalizer.argocd.argoproj.io finalizer, deleting an application will not delete the resources it manages. To perform a cascading delete, you must add the finalizer. See App Deletion. (https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#about-the-deletion-finalizer)