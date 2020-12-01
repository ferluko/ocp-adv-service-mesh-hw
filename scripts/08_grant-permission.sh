
#!/bin/bash
# grant permissions to user1 as mesh-admin

echo '\n Grant permissions \n'
oc adm policy add-role-to-user edit user1 -n bookretail-istio-system
oc adm policy add-role-to-user admin user1 -n bookinfo