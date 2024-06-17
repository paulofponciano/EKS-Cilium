#!/bin/bash

# kubectl apply -f ./00-fluentBit/kubernetes
# kubectl apply -f ./01-data-prepper/kubernetes
# kubectl apply -f ./02-otel-collector/kubernetes
kubectl apply -f ./03-mysql/kubernetes
kubectl apply -f ./04-analytics-service/kubernetes
kubectl apply -f ./05-databaseService/kubernetes
kubectl apply -f ./06-orderService/kubernetes
kubectl apply -f ./07-inventoryService/kubernetes
kubectl apply -f ./08-paymentService/kubernetes
kubectl apply -f ./09-recommendationService/kubernetes
kubectl apply -f ./10-authenticationService/kubernetes
kubectl apply -f ./11-client/kubernetes