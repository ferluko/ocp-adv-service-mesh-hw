#!/bin/bash

# Deploy Red Hat Service Mesh Operator

echo "Creating project openshift-operators-redhat for Red Hat Service Mesh Operator.."
echo 'kind: Namespace
apiVersion: v1
metadata:
  name: openshift-operators-redhat
  annotations:
    openshift.io/node-selector: ""
    openshift.io/display-name: "Red Hat Service Mesh Operator"
  labels:
    openshift.io/cluster-monitoring: "true"' | oc create -f -

###
echo "Creating operator groups in openshift-operators-redhat namespace"
echo "apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-operators-redhat
  namespace: openshift-operators-redhat
spec: {}" | oc create -f -

###
echo "Suscripting Elasticsearch Operator..."
echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: "4.5"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: elasticsearch-operator' | oc create -f -

###
echo "Suscripting Jeager Operator..."
echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators-redhat
spec:
  channel: "stable"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: jaeger-product' | oc create -f -

###
echo "Suscripting Kiali Operator..."
echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators-redhat
spec:
  channel: "stable"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: kiali-ossm' | oc create -f -

###
echo "Suscripting Red Hat Service Mesh Operator..."
echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: "1.0"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: servicemeshoperator' | oc create -f -

echo "Wait until service mesh opertor is ready"
while (true); do
  REPLICAS_READY=$(oc get deployment istio-operator -n openshift-operators -o jsonpath='{.status.readyReplicas}')
  if [[ ${REPLICAS_READY} -eq 1 ]] ; then
      echo "Operator is ready!"
      break
  else
      echo "Waiting for replicas ready..."
  fi
  sleep 10
done 
