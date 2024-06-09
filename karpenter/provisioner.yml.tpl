apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: ${EKS_CLUSTER}
  namespace: kube-system
spec:
  ttlSecondsAfterEmpty: 60 # scale down nodes after 60 seconds without workloads (excluding daemons)
  ttlSecondsUntilExpired: 604800 # expire nodes after 7 days (in seconds) = 7 * 60 * 60 * 24
  limits:
    resources:
      cpu: 200 # limit to 100 CPU cores the maximum cluster usage
  requirements:
    # Include general purpose instance families
    - key: karpenter.k8s.aws/instance-family
      operator: In
      values:
%{ for ify in INSTANCE_FAMILY ~}
      - ${ify}
%{ endfor ~}
    - key: karpenter.k8s.aws/instance-size
      operator: In
      values:
%{ for ic in INSTANCE_SIZES ~}
      - ${ic}
%{ endfor ~} 
    - key: karpenter.sh/capacity-type
      operator: In
      values:
%{ for ct in CAPACITY_TYPE ~}
      - ${ct}
%{ endfor ~}
    - key: "topology.kubernetes.io/zone" 
      operator: In
      values:
%{ for azs in AVAILABILITY_ZONES ~}
      - ${azs}
%{ endfor ~}
  providerRef:
    name: my-provider