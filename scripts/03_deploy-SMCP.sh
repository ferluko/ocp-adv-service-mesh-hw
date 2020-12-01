#!/bin/bash

# Service Mesh Control Plane
export SM_CP_NS=bookretail-istio-system


echo "Creating namespace for control plane.."
echo "kind: Namespace
apiVersion: v1
metadata:
  name: $SM_CP_NS
  annotations:
    openshift.io/display-name: 'Service Mesh System'" | oc create -f -

##
echo "Deploying Service Mesh Control Plane in namespace $SM_CP_NS..."
echo 'apiVersion: maistra.io/v1
kind: ServiceMeshControlPlane
metadata:
  name: service-mesh-installation
spec:
  version: v1.1
  threeScale:
    enabled: false
  istio:
    global:
      mtls:
        enabled: false
        auto: false
      disablePolicyChecks: true
      proxy:
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 128Mi
    gateways:
      istio-egressgateway:
        autoscaleEnabled: false
      istio-ingressgateway:
        autoscaleEnabled: false
        ior_enabled: false
    mixer:
      policy:
        autoscaleEnabled: false
      telemetry:
        autoscaleEnabled: false
        resources:
          requests:
            cpu: 100m
            memory: 1G
          limits:
            cpu: 500m
            memory: 4G
    pilot:
      autoscaleEnabled: false
      traceSampling: 100.0
    kiali:
      dashboard:
        user: admin
        passphrase: redhat
    tracing:
      enabled: true' | oc create -f - -n $SM_CP_NS

sleep 10

while (true); do
  READY=$(oc get deployment -n $SM_CP_NS istio-pilot -o jsonpath='{.status.readyReplicas}')
  if [[ ${READY} -eq 1 ]] ; then
      echo "Operator is ready!"
      break
  else
      echo "Waiting for replicas ready..."
  fi
  sleep 10
done
