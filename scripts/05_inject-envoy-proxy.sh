#!/bin/bash
# Injecting Envoy Proxy

echo -en 'Patching deployments of bookinfo namespace...'
for i in $(oc get deployment -n bookinfo | grep -v NAME | awk '{print $1}')
do 
  oc patch deployment/$i -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n bookinfo
done

echo -e "Waiting 60s for pods ready"
sleep 60
echo -e "Listing pods and their sidecar containers"
for POD in $(oc get pods -n bookinfo -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}')
do
  oc get pod $POD -n bookinfo -o jsonpath='{.metadata.name}{":\t\t"}{.spec.containers[*].name}{"\n"}'
done