apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: my-provider
  namespace: karpenter
spec:
  subnetSelector:
    karpenter.sh/discovery: "true"
  securityGroupSelector:
    aws:eks:cluster-name: ${EKS_CLUSTER} #CHANGE THIS VALUE TO CLUSTER NAME
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
        iops: 3000
        deleteOnTermination: true
        throughput: 125