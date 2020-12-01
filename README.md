# Red Hat Service Mesh - Homework

Red Hat Service Mesh Homework Assigment for Adv Red Hat Service Mesh Course

* *Student*: Fernando Gonzalez
* *Company*: Sales Vision SA (Semperti) - Red Hat Business Partner
* *E-mail*: <fernando.gonzalez@semperti.com>

## Evidence

![Evidence](evidence.gif)

## 1. POC Environment

*IMPORTANT!!! Lab Expires @ 12/07/20 14:54 UTC. Please email me if the environment is in "stopped" or  in "standby" mode.*

* API Server

```
$ oc whoami --show-server
https://api.cluster-4025.4025.sandbox419.opentlc.com:6443
```

* Web Console

```
$ oc whoami --show-console
https://console-openshift-console.apps.cluster-4025.4025.sandbox419.opentlc.com
```

* Users

```
Admin User: admin
Admin Password: r3dh4t1!

Mesh-admin User: user1
Mesh-admin Password: r3dh4t1!
```

* Lab Versions

```
$ oc version             
Client Version: 4.5.1
Server Version: 4.5.4
Kubernetes Version: v1.18.3+012b3ec
```

## 2. Pre-Requirements

- Shell terminal
- OCP Cluster +v4.5
- Openshift Client Version 4.5 installed and logged on OCP Cluster

```bash
git clone https://github.com/ferluko/ocp-adv-service-mesh-hw
chmod +x scripts/*.sh
oc login -u admin -p r3dh4t1! https://api.cluster-4025.4025.sandbox419.opentlc.com:6443
```

## 3. Business Application

Bookinfo Application Deployment

```bash
sh ./scripts/01_app-deploy.sh
```

## 4. OpenShift Service Mesh Operator and Control Plane

* Red Hat OpenShift Service Mesh Operators

```bash
$ sh ./scripts/02_serv-mesh-deploy-operator.sh
```
* Service Mesh Control Plane Installation

```bash
$ sh ./scripts/03_deploy-SMCP.sh
```

## 5. ServiceMeshMemberRoll

* Install a ServiceMeshMemberRoll resource with bookinfo as its only member.

```bash
$ sh ./scripts/04_serv-mesh-member-roll.sh
```

* Inject envoy to bookinfo deployments

```bash
$ sh ./scripts/05_inject-envoy-proxy.sh
```

## 6. mTLS Security

* Setting up probes and create gateway and certs

```bash
$ sh ./scripts/06_certs-istio-ingressgw.sh
```
* Red Hat Service Mesh Resources for bookinfo project
  * Gateways
  * VirtualServices
  * DestinationRules
  * Policy

```bash
$ sh ./scripts/07_apply-mTLS.sh
```

* Grant permission to user1 as mesh-admin

```bash
$ sh ./scripts/08_grant-permission.sh
```

## Testing

```bash
export GATEWAY_URL=$(oc -n bookretail-istio-system get route productpage-gateway -o jsonpath='{.spec.host}')
curl -kv -o /dev/null -s -w "%{http_code}\n" https://$GATEWAY_URL/productpage
200
```

## Generate continuous traffic

```bash
while (true) ; do curl -kv -o /dev/null -s -w "%{http_code}\n" https://$GATEWAY_URL/productpage ; sleep .1 ; done
```

## Clean up Red Hat Service Mesh and Business App
```bash
$ sh ./scripts/99_delete-serv-mesh.sh
```
