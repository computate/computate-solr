FROM registry.access.redhat.com/ubi8/ubi

MAINTAINER Christopher Tate <computate@computate.org>

ENV APP_NAME=solr \
    APP_VERSION=8.4.1 \
    USER_NAME=solr \
    APP_REPO=https://github.com/apache/lucene-solr.git \
    APP_TAG=releases/lucene-solr/8.4.1 \
    APP_SRC=/usr/local/src/solr \
    APP_SRV=/srv/solr \
    USER_HOME=/home/solr \
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
    SOLR_PORT=8080 \
    SOLR_DATA=/srv/solr/data \
    ZK_HOSTNAME=localhost \
    ZK_CLIENT_PORT=8080 \
    ZK_ADMIN_PORT=8081 \
    INSTALL_PKGS="java-1.8.0-openjdk lsof maven git rsync procps-ng"

EXPOSE $SOLR_PORT

RUN useradd -m -d $USER_HOME -s /bin/bash -U $USER_NAME
RUN usermod -m -d $USER_HOME $USER_NAME
RUN yum install -y $INSTALL_PKGS && yum clean all
RUN install -d -o $USER_NAME -g $USER_NAME $ANT_SRC $ANT_OPT $APP_SRC $APP_SRV $COMPUTATE_SRC $SOLR_DATA
USER $USER_NAME
RUN git clone $ANT_REPO $ANT_SRC --single-branch --branch $ANT_TAG --depth 1
RUN git clone $APP_REPO $APP_SRC --single-branch --branch $APP_TAG --depth 1
RUN echo "Updated Solr config version 8.4.1"
RUN git clone $COMPUTATE_REPO $COMPUTATE_SRC
WORKDIR $ANT_SRC
RUN ./bootstrap.sh
RUN bootstrap/bin/ant -f fetch.xml -Ddest=optional
RUN ./build.sh -Ddist.dir=$ANT_OPT dist
USER root
RUN ln -s /opt/ant/bin/ant /usr/bin/ant
USER $USER_NAME
RUN install -d /home/solr/.ant/lib
RUN curl https://repo1.maven.org/maven2/org/apache/ivy/ivy/$IVY_TAG/ivy-$IVY_TAG.jar -o /home/solr/.ant/lib/ivy-$IVY_TAG.jar
WORKDIR $APP_SRC/solr
RUN ant ivy-bootstrap
RUN ant package
RUN rsync -r $APP_SRC/solr/build/solr-$APP_VERSION-SNAPSHOT/ $APP_SRV/
RUN find $APP_SRC -mindepth 1 -delete
RUN rsync -r $APP_SRV/server/solr/solr.xml $SOLR_DATA/
RUN rm -rf $APP_SRV/example
RUN ln -s $COMPUTATE_SRC/config/solr/server/solr/configsets/computate $APP_SRV/server/solr/configsets/computate
RUN chmod a+x $APP_SRV/bin/*
RUN chmod -R a+rw $APP_SRV
RUN chmod -R a+rw $COMPUTATE_SRC

WORKDIR $APP_SRV
#CMD $APP_SRV/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_SRV/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT 
#CMD ($APP_SRV/bin/solr create_collection -c $SOLR_COLLECTION -n $SOLR_CONFIG && $APP_SRV/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT)
#CMD $APP_SRV/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_SRV/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT && $APP_SRV/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT -h "$HOSTNAME"
CMD $APP_SRV/bin/solr zk upconfig -n $SOLR_CONFIG -d $APP_SRV/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT && $APP_SRV/bin/solr start -f -s $SOLR_DATA -p $SOLR_PORT -h "$HOSTNAME"

