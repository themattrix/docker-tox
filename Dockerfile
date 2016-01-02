FROM ubuntu:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8 && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# proper init to handle signal propagation and zombie reaping
ADD https://github.com/krallin/tini/releases/download/v0.8.4/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

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
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

CMD cp -rT /src/ /app/ && tox
