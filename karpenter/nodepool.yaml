apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: ${EKS_CLUSTER}-default
spec:
  template:
    spec:
      requirements:
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["medium", "large", "2xlarge"]
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["m5", "c5", "t3a"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: "topology.kubernetes.io/zone"
          operator: In
          values: ["us-east-2a", "us-east-2b"]
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: ${EKS_CLUSTER}-default
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 72h