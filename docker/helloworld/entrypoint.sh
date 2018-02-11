#!/bin/bash

set -e

export JAVA_OPTS=${JAVA_OPTS:="-Xmx256m"}

echo "current image environment vars."
env
echo "-----"
cd $INSTALL_PATH
exec java -jar $JAVA_OPTS helloworld.war