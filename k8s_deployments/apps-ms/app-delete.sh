#!/bin/bash

kubectl delete -f ./00-fluentBit/kubernetes
kubectl delete -f ./01-data-prepper/kubernetes
kubectl delete -f ./02-otel-collector/kubernetes
kubectl delete -f ./03-mysql/kubernetes
kubectl delete -f ./04-analytics-service/kubernetes
kubectl delete -f ./05-databaseService/kubernetes
kubectl delete -f ./06-orderService/kubernetes
kubectl delete -f ./07-inventoryService/kubernetes
kubectl delete -f ./08-paymentService/kubernetes
kubectl delete -f ./09-recommendationService/kubernetes
kubectl delete -f ./10-authenticationService/kubernetes
kubectl delete -f ./11-client/kubernetes