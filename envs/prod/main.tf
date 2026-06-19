module "vpc" {
  region                  = var.region
  source                  = "../../modules/vpc"
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name        = "vpc"
    Environment = "prod"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "gitops-ecommerce-prod"
  vpc_id       = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnet_ids

  tags = var.tags
}


resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.1.3"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  # Enable server-side apply for large Custom Resource Definitions (CRDs)
  set = [
    {
    name  = "crds.keep"
    value = "true"
  }
  ]
  
  lifecycle {
    prevent_destroy = false
  }
}

resource "kubernetes_manifest" "root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root-bootstrap"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/TheInvincibleRalph/ecommerce-gitops.git"
        targetRevision = "HEAD"
        path           = "clusters/argocd-apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  # CRITICAL: Ensures ArgoCD CRDs exist in the API server before applying this manifest
  depends_on = [helm_release.argocd] 
}


# Install Karpenter Controller via Helm
resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  
  # Karpenter is hosted on AWS's public Elastic Container Registry
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  
  version          = "0.37.0" 

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.eks.karpenter_iam_role_arn}
    EOT
  ]

  depends_on = [module.eks]
}