#!/bin/bash
# Add namespace to mesh
echo '\n Creating SM MemberRoll \n'

echo "apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
spec:
  members:
  - bookinfo" | oc create -f - -n bookretail-istio-system

while (true); do
  APP_READY=$(oc get project -l kiali.io/member-of=bookretail-istio-system,maistra.io/member-of=bookretail-istio-system | awk '/bookinfo/ { print "OK" }')
  if [[ ${APP_READY} -eq "OK" ]] ; then
      echo "Bookinfo namespace included to service mesh!!!"
      break
  else
      echo "Waiting for configuration, checking again in 10s..."
  fi
  sleep 10
done