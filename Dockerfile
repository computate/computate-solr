FROM openshift/base-centos7:latest

MAINTAINER Christopher Tate <computate@computate.org>

ENV APP_NAME=solr \
    APP_VERSION=7.1.0 \
    USER_NAME=solr \
    APP_REPO=https://github.com/apache/lucene-solr.git \
    APP_TAG=releases/lucene-solr/7.1.0 \
    APP_SRC=/usr/local/src/solr \
    APP_SRV=/srv/solr \
    USER_HOME=/home/solr \
    ANT_REPO=https://github.com/apache/ant.git \
    ANT_TAG=rel/1.10.6 \
    ANT_SRC=/usr/local/src/ant \
    ANT_OPT=/opt/ant \
    IVY_REPO=https://github.com/apache/ant-ivy.git \
    IVY_TAG=2.4.0 \
    IVY_SRC=/usr/local/src/ant-ivy \
    IVY_OPT=/opt/ant-ivy \
    COMPUTATE_REPO=https://github.com/computate/computate.git \
    COMPUTATE_SRC=/usr/local/src/computate \
    SOLR_CONFIG=computate \
    SOLR_COLLECTION=site \
    SOLR_PORT=8080 \
    SOLR_DATA=/srv/solr/data \
    ZK_HOSTNAME=localhost \
    ZK_CLIENT_PORT=8080 \
    ZK_ADMIN_PORT=8081 \
    INSTALL_PKGS="java-1.8.0-openjdk ivy lsof maven git"

EXPOSE $SOLR_PORT

RUN useradd -m -d $USER_HOME -s /bin/bash -U $USER_NAME
RUN usermod -m -d $USER_HOME $USER_NAME
RUN yum install -y $INSTALL_PKGS && yum clean all
#RUN install -d -o $USER_NAME -g $USER_NAME $IVY_SRC
#RUN install -d -o $USER_NAME -g $USER_NAME $IVY_OPT
RUN install -d -o $USER_NAME -g $USER_NAME $APP_SRC
RUN install -d -o $USER_NAME -g $USER_NAME $APP_SRV
RUN install -d -o $USER_NAME -g $USER_NAME $COMPUTATE_SRC
RUN install -d -o $USER_NAME -g $USER_NAME $SOLR_DATA
USER $USER_NAME
#RUN git clone $ANT_REPO $ANT_SRC --single-branch --branch $ANT_TAG --depth 1
#RUN git clone $IVY_REPO $IVY_SRC --single-branch --branch $IVY_TAG --depth 1
RUN git clone $APP_REPO $APP_SRC --single-branch --branch $APP_TAG --depth 1
RUN git clone $COMPUTATE_REPO $COMPUTATE_SRC
#WORKDIR $ANT_SRC
#(JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk ./build.sh -Ddist.dir=/opt/ant dist)
#RUN cp /usr/share/java/{bcel,junit,commons-logging,log4j,javamail/javax.mail}.jar $ANT_SRC/lib/optional/
#RUN bootstrap/bin/ant -nouserlib -lib lib/optional -emacs -Ddist.dir=/opt/ant dist
#WORKDIR $IVY_SRC
#RUN ant
WORKDIR $APP_SRC/solr
RUN ant ivy-bootstrap
RUN ant package
RUN rsync -r $APP_SRC/solr/build/solr-$APP_VERSION-SNAPSHOT/ $APP_SRV/
RUN find $APP_SRC -mindepth 1 -delete
RUN rsync -r $APP_SRV/server/solr/solr.xml $APP_SRV/
RUN rm -rf $APP_SRV/example
RUN ln -s $COMPUTATE_SRC/config/solr/server/configsets/computate $APP_SRV/server/solr/configsets/computate

WORKDIR $APP_SRV
CMD $APP_SRV/bin/solr zk upconfig -n $SOLR_CONFIG -d $COMPUTATE_SRC/server/solr/configsets/computate -z $ZK_HOSTNAME:$ZK_CLIENT_PORT && ($APP_SRV/bin/solr create_collection -c $SOLR_COLLECTION -n $SOLR_CONFIG && $APP_SRV/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT) || $APP_SRV/bin/solr start -f -c -s $SOLR_DATA -p $SOLR_PORT -z $ZK_HOSTNAME:$ZK_CLIENT_PORT

