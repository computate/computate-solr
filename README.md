#Useful to connect to host network. 

docker run --network host -it 68e74c7d781e /bin/bash

export ZK_HOSTNAME=ctate.remote.csb

export ZK_CLIENT_PORT=10281

$APP_SRV/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_SRV/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT

($APP_SRV/bin/solr create_collection -c $SOLR_COLLECTION -n $SOLR_CONFIG && $APP_SRV/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT)

$APP_SRV/bin/solr start -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT

# computate-solr
```bash
sudo mkdir /usr/local/src/computate-solr
sudo chown $USER: /usr/local/src/computate-solr/
git clone git@github.com:computate/computate-solr.git /usr/local/src/computate-solr/
cd /usr/local/src/computate-solr
docker build -t computate/computate-solr:latest .
docker login
docker push computate/computate-solr:latest
git add -i
git commit
git push
oc replace --force -f "https://raw.githubusercontent.com/computate/computate-solr/master/openshift-computate-solr.json"
```
