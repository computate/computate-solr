FROM registry.access.redhat.com/ubi8/ubi

MAINTAINER Christopher Tate <computate@computate.org>

ENV APP_NAME=solr \
    APP_VERSION=8.4.1 \
    APP_REPO=https://github.com/apache/lucene-solr.git \
    APP_TAG=releases/lucene-solr/8.4.1 \
    APP_SRC=/usr/local/src/solr \
    APP_OPT=/opt/solr \
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
    ANT_REPO=https://github.com/apache/ant.git \
    ANT_TAG=rel/1.10.7 \
    ANT_SRC=/usr/local/src/ant \
    ANT_OPT=/opt/ant \
    IVY_TAG=2.3.0 \
    COMPUTATE_REPO=https://github.com/computate/computate.git \
    COMPUTATE_SRC=/usr/local/src/computate \
    SOLR_CONFIG=computate \
    SOLR_COLLECTION=site \
    SOLR_PORT=8983 \
    SOLR_DATA=/opt/solr/data \
    ZK_HOSTNAME=localhost \
    ZK_CLIENT_PORT=2181 \
    INSTALL_PKGS="java-1.8.0-openjdk lsof maven git rsync procps-ng"

EXPOSE $SOLR_PORT

RUN yum install -y $INSTALL_PKGS && yum clean all
RUN install -d -g 0 $ANT_SRC $ANT_OPT $APP_SRC $APP_OPT $COMPUTATE_SRC $SOLR_DATA
RUN git clone $ANT_REPO $ANT_SRC --single-branch --branch $ANT_TAG --depth 1
RUN git clone $APP_REPO $APP_SRC --single-branch --branch $APP_TAG --depth 1
RUN git clone $COMPUTATE_REPO $COMPUTATE_SRC
WORKDIR $ANT_SRC
RUN ./bootstrap.sh
RUN bootstrap/bin/ant -f fetch.xml -Ddest=optional
RUN ./build.sh -Ddist.dir=$ANT_OPT dist
RUN ln -s /opt/ant/bin/ant /usr/bin/ant
RUN install -d -g 0 /home/solr/.ant/lib
RUN curl https://repo1.maven.org/maven2/org/apache/ivy/ivy/$IVY_TAG/ivy-$IVY_TAG.jar -o /home/solr/.ant/lib/ivy-$IVY_TAG.jar
WORKDIR $APP_SRC/solr
RUN ant ivy-bootstrap
RUN ant package
RUN rsync -r $APP_SRC/solr/build/solr-$APP_VERSION-SNAPSHOT/ $APP_OPT/
RUN find $APP_SRC -mindepth 1 -delete
RUN rm -rf $APP_OPT/example
RUN ln -s $COMPUTATE_SRC/config/solr/server/solr/configsets/computate $APP_OPT/server/solr/configsets/computate
RUN chmod a+x $APP_OPT/bin/*
RUN install -d -g 0 $APP_OPT/server/logs
RUN chgrp -R 0 $ANT_SRC $ANT_OPT $APP_SRC $APP_OPT $COMPUTATE_SRC $SOLR_DATA && chmod -R g=u $ANT_SRC $ANT_OPT $APP_SRC $APP_OPT $COMPUTATE_SRC $SOLR_DATA
COPY run-computate-solr.sh "$APP_OPT/bin/"

USER 1001

WORKDIR $APP_OPT
#CMD $APP_OPT/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_OPT/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT 
#CMD ($APP_OPT/bin/solr create_collection -c $SOLR_COLLECTION -n $SOLR_CONFIG && $APP_OPT/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT)
#CMD $APP_OPT/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_OPT/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT && $APP_OPT/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT -h "$HOSTNAME"
#CMD $APP_OPT/bin/run-computate-solr.sh
CMD $APP_OPT/bin/solr start -f -s $SOLR_DATA -p $SOLR_PORT -h "$HOSTNAME"

