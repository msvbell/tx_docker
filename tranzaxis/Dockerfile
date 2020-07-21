FROM openjdk:8 AS builder

ENV MANAGER_FILE=manager_1_2_11_27_7.zip

COPY ./init/${MANAGER_FILE} /tmp/manager.zip

RUN apt-get install -y unzip && \
    unzip /tmp/manager.zip -d /tmp

FROM centos:7

RUN yum update -y && yum install -y \
    java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel \
    dos2unix

ARG INSTANCE_PORT
ARG EAS_PORT
ARG SVN_PORT
ENV SVN_PORT=${SVN_PORT:-18080}
ENV INST_PORT=$INST_PORT
ENV EASARG_PORT=$EAS_PORT

COPY ./server /app/server
COPY ./init/project_for_manager /app/project
#COPY --from-build=builder /tmp/manager /app/manager
RUN dos2unix /app/server/server.sh
RUN bash -c "/app/server/init_config.sh"
ENTRYPOINT ["sh", "/app/server/server.sh"]