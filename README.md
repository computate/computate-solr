
# computate-solr
```bash
sudo yum install -y buildah podman
sudo install -o $USER -g $USER -d /usr/local/src/computate-solr
git clone git@github.com:computate/computate-solr.git /usr/local/src/computate-solr/
cd /usr/local/src/computate-solr
sudo podman build -t computate/computate-solr:latest .
sudo podman login quay.io
sudo podman push computate/computate-solr:latest
git add -i
git commit
git push
oc replace --force -f "https://raw.githubusercontent.com/computate/computate-solr/master/openshift-computate-solr.json"
```

#Useful to connect to host network. 

podman run --network host -it 68e74c7d781e /bin/bash

export ZK_HOSTNAME=ctate.remote.csb

export ZK_CLIENT_PORT=10281

$APP_SRV/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_SRV/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT

($APP_SRV/bin/solr create_collection -c $SOLR_COLLECTION -n $SOLR_CONFIG && $APP_SRV/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT)

$APP_SRV/bin/solr start -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT
