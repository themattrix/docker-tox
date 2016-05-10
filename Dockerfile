FROM ubuntu:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

RUN groupadd -r tox --gid=999 && \
    useradd -r -g tox --uid=999 tox

# https://github.com/tianon/gosu#from-debian
ENV GOSU_VERSION 1.7
RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true && \
    apt-get purge -y --auto-remove ca-certificates wget

RUN apt-get update && \
    apt-get -y install \
        wget \
        libssl-dev \
        libffi-dev \
        python-pip \
        python-software-properties \
        software-properties-common && \
    add-apt-repository -y ppa:fkrull/deadsnakes && \
    apt-get update && \
    apt-get -y install \
        python2.6 \
        python2.7 \
        python3.3 \
        python3.4 \
        python3.5 \
        pypy && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /install && \
    wget -O /install/pypy3-2.4-linux_x86_64-portable.tar.bz2 \
            "https://bitbucket.org/squeaky/portable-pypy/downloads/pypy3-2.4-linux_x86_64-portable.tar.bz2" && \
    tar jxf /install/pypy3-*.tar.bz2 -C /install && \
    rm /install/pypy3-*.tar.bz2 && \
    ln -s /install/pypy3-*/bin/pypy3 /usr/local/bin/pypy3

RUN pip install -U pip && pip install tox

WORKDIR /app
VOLUME /src

ONBUILD COPY install-prereqs*.sh requirements*.txt tox.ini /app/
ONBUILD ARG SKIP_TOX=false
ONBUILD RUN bash -c " \
    if [ -f '/app/install-prereqs.sh' ]; then \
        bash /app/install-prereqs.sh; \
    fi && \
    if [ $SKIP_TOX == false ]; then \
        TOXBUILD=true tox; \
    fi"

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
