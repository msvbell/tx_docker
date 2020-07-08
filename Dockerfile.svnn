FROM mamohr/subversion-edge

ARG SVN_USER
ARG SVN_PASSWORD
ARG REPOSITORIES_DIR="/opt/csvn/data/repositories/"

ENV REPOSITORY_NAME="TX"
ENV RUN_AS_USER=collabnet
ENV REPOSITORY_DIR=${REPOSITORIES_DIR}${REPOSITORY_NAME}
ENV SVN_USER=${SVN_USER:-TX}
ENV SVN_PASSWORD=${SVN_PASSWORD:-TX}
ENV DB_SID=TX
ENV TEST_DB_NAME=TEST
ENV PROD_DB_NAME=PROD

COPY init/svn_config /opt/csvn/data/conf
COPY init/svn_repository_files /tmp/repository_files
COPY init/repository.dumpfile /tmp/repository.dumpfile
COPY scripts/init_repository.sh /tmp/init_repository.sh

ENTRYPOINT ["/tmp/init_repository.sh"]