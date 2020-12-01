#!/bin/bash
# mTLS Security Part A

echo -en '\n Setting probes \n'
for i in $(oc get deploy -n bookinfo | awk '/\-v/ {print $1}')
do
  oc set probe deploy -n bookinfo $i --liveness -- echo ok
  oc set probe deploy -n bookinfo $i --readiness -- echo ok
done

echo -en '\n Creating self signed certificates for ingress gateways...\n'
echo ""

echo "
[ req ]
req_extensions     = req_ext
distinguished_name = req_distinguished_name
prompt             = no
[req_distinguished_name]
commonName=.apps.cluster-4025.4025.sandbox419.opentlc.com
[req_ext]
subjectAltName   = @alt_names
[alt_names]
DNS.1  = bookinfo.apps.cluster-4025.4025.sandbox419.opentlc.com
DNS.2  = *.bookinfo.apps.cluster-4025.4025.sandbox419.opentlc.com
" > cert.cfg

openssl req -x509 -config cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:2048 -sha256 -keyout tls.key -out tls.crt

echo "Creating secrets for istio-ingressgateway..."
oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n bookretail-istio-system

echo ""
echo "Creating bookinfo wildcard..."
echo 'apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-wildcard-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
    hosts:
    - productpage.bookinfo.apps.cluster-4025.4025.sandbox419.opentlc.com' | oc create -n bookretail-istio-system -f - 

echo "Patching deployment istio-ingressgateway..."
oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n bookretail-istio-system