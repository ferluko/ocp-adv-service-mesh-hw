#!/bin/bash

# Deploy BookInfo App

echo "Creating project.."
echo "kind: Namespace
apiVersion: v1
metadata:
  name: bookinfo
  annotations:
    openshift.io/display-name: 'Business App'" | oc create -f -

echo "Deploying Business App..."
oc apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml -n bookinfo

echo "Exposing application..."
oc expose service productpage
echo -en "\n$(oc get route productpage --template '{{ .spec.host }}')\n"

echo "Waiting 30s for pod status..."
sleep 30

echo "Pods status..."
oc get pods -n bookinfo
