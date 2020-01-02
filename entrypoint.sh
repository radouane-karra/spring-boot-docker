#!/bin/sh
set -e

echo "Start application"

JVM_ARG="-Dfile.encoding=UTF-8 -Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

MEMORY_CONSTRAINTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -XshowSettings:vm"


exec java -server ${MEMORY_CONSTRAINTS} ${JAVA_OPTS} ${JVM_ARG} -jar "${HOME}/app.jar" "$@"


