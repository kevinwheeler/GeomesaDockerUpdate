#!/bin/bash
# Given a path to the core jar and a path to the plugin jar, this script will copy them into geoserve and will then shutdown and restart geoserver.
# example plugin jar filename geomesa-plugin-accumulo1.5-1.0.0-SNAPSHOT-geoserver-plugin.jar
USAGE="Usage: ./script path/to/core.jar path/to/plugin.jar"

if [ $# -ne 2 ] 
  then
  echo $USAGE
  exit 0
fi

foundCore=$(grep core < <(echo $1))
if [ -z "$foundCore" ]
  then
  echo the first argument didnt contain the substring string core. exiting.
  exit 0
fi

foundPlugin=$(grep plugin < <(echo $2))
if [ -z "$foundPlugin" ]
  then
  echo the second argument didnt contain the substring plugin. exiting.
  exit 0
fi

if [ -a $1 ] && [ -a $2 ]
  then
    echo 'Found input files.'
  else
    echo 'Didnt find both input files'
    exit 0 
fi

CONTAINER_ID=$(docker ps | grep tests-geoserver)
CONTAINER_ID=${CONTAINER_ID:0:12}
echo abbreviated geoserver container id = $CONTAINER_ID
if [ -z "$CONTAINER_ID" ]
  then
  echo Error: Couldnt find  'tests-geoserver' container.
  exit 0
fi

FULL_ID=$(docker inspect -f \{\{\.Id\}\} $CONTAINER_ID)
echo full geoserver container id = $FULL_ID



cp $1 /var/lib/docker/aufs/mnt/$FULL_ID/opt/geoserver-2.5.2/webapps/geoserver/WEB-INF/lib/geomesa-core.jar
cp $2 /var/lib/docker/aufs/mnt/$FULL_ID/opt/geoserver-2.5.2/webapps/geoserver/WEB-INF/lib/geomesa-plugin.jar

docker exec tests-geoserver /opt/geoserver-2.5.2/bin/shutdown.sh
docker exec tests-geoserver /opt/start-geoserver.sh

