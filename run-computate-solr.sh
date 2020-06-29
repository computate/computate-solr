#!/bin/bash
#if [ -d "$SOLR_DATA/$SOLR_COLLECTION" ]; then
#$APP_OPT/bin/solr create_core -c $SOLR_COLLECTION -d $APP_OPT/server/solr/configsets/computate
$APP_OPT/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_OPT/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT
#$APP_OPT/bin/solr create_collection -c $SOLR_COLLECTION -n $SOLR_CONFIG
#fi
rsync $APP_OPT/server/solr/solr.xml $SOLR_DATA/ 
#exec $APP_OPT/bin/solr start -f -s $SOLR_DATA -p $SOLR_PORT -h "$HOSTNAME"
exec $APP_OPT/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT -h "$HOSTNAME"

