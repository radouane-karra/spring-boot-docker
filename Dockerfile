# Start with a base image containing Java runtime
FROM openjdk:8-jre-alpine

# Maintainer Info
LABEL MAINTAINER="Radouane KARRA"

# Install system dependencies
#RUN apk add --update --no-cache bash curl

# Set the defaut env value
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    JAVA_OPTS="-Xms1536m -Xmx2536m" \
    DATA_LOGS=/data/logs

RUN echo "export LC_ALL=$LC_ALL" >> /etc/profile.d/locale.sh
RUN echo "export LANG=$LANG" >> /etc/profile.d/locale.sh

# Create a group and user to run our app
# Add a flash user to run our application so that it doesn't need to run as root
ARG APP_USER=rkarra
#RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -g ${APP_USER} ${APP_USER}

# Add user to run our application so that it doesn't need to run as root
RUN addgroup -g 1000 -S ${APP_USER} && adduser -s /bin/sh -u 1000 -S ${APP_USER} -G ${APP_USER}
    
# The application's jar file
ARG JAR_FILE


# Create the default folders
RUN mkdir -p $DATA_LOGS

WORKDIR /home/${APP_USER}

# Add a volumes pointing to data logs folder ...
VOLUME ["$DATA_LOGS"]

# Add entrypoint 
COPY entrypoint.sh entrypoint.sh
# Add the application's fat jar to the container
COPY ${JAR_FILE} /home/${APP_USER}/app.jar

# set use user
RUN chmod 755 entrypoint.sh && chown ${APP_USER}:${APP_USER} entrypoint.sh \
	&& chmod 755 /home/${APP_USER}/app.jar && chown ${APP_USER}:${APP_USER} /home/${APP_USER}/app.jar \	
    && chmod 755 -R ${DATA_LOGS} && chown -R ${APP_USER}:${APP_USER} ${DATA_LOGS} 
    
USER ${APP_USER}

ENTRYPOINT ["sh","./entrypoint.sh"]

# Make default port available to the world outside this container
EXPOSE 8070