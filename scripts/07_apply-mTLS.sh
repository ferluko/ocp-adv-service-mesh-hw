#!/bin/bash
# mTLS Security Part B

echo '\n Securing  \n'

mkdir -p ./manifests
echo 'apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: {{DEPLOY_NAME}}-mtls
spec:
  peers:
  - mtls:
      mode: STRICT
  targets:
  - name: {{DEPLOY_NAME}}' > ./manifests/policy-template.yaml

echo 'apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: {{DEPLOY_NAME}}-destinationrule-mtls
spec:
  host: {{DEPLOY_NAME}}
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  subsets:
  - name: v1
    labels:
      version: v1' > ./manifests/destinationrule-template.yaml

echo 'apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews-destinationrule-mtls
spec:
  host: reviews
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3' > ./manifests/destinationrule-reviews.yaml

echo 'apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: productpage-virtualservice
spec:
  gateways:
  - bookinfo-wildcard-gateway.bookretail-istio-system.svc.cluster.local
  hosts:
  - productpage.bookinfo.apps.cluster-4025.4025.sandbox419.opentlc.com
  http:
  - match:
    - uri:
        exact: /
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage.bookinfo.svc.cluster.local
        port:
          number: 9080
---' > ./manifests/virtualservices.yaml

echo 'apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    openshift.io/host.generated: \"true\"
  labels:
    app: productpage
  name: productpage-gateway
spec:
  host: productpage.bookinfo.apps.cluster-4025.4025.sandbox419.opentlc.com
  port:
    targetPort: https
  tls:
    termination: passthrough
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  wildcardPolicy: None' > ./manifests/productpage-route.yaml


echo '\n Creating policies \n'
for DEPLOY in $(oc get deploy -o jsonpath='{.items[*].metadata.labels.app}')
do
  template=`cat "./manifests/policy-template.yaml" | sed "s/{{DEPLOY_NAME}}/$DEPLOY/g"`
  echo "$template" | oc apply -n bookinfo -f -
done

echo '\n Creating destinationrules \n'
for DEPLOY_LABEL in $(oc get deploy -o jsonpath='{.items[*].metadata.labels.app}')
do
  if [[ ${DEPLOY_LABEL} == *"reviews"* ]]
  then
    continue
  else
    template=`cat "./manifests/destinationrule-template.yaml" | sed "s/{{DEPLOY_NAME}}/$DEPLOY_LABEL/g"`
    echo "$template" | oc apply -n bookinfo -f -
  fi
done
oc apply -n bookinfo -f ./manifests/destinationrule-reviews.yaml


echo '\n Creating virtual services \n'
oc apply -n bookinfo -f ./manifests/virtualservices.yaml

echo '\n Creating productpage route \n'
oc patch deploy productpage-v1 -p '{"spec": {"template": {"metadata": {"labels": {"maistra.io/expose-route": "true"}}}}}' -n bookinfo
oc apply -n bookretail-istio-system -f ./manifests/productpage-route.yaml