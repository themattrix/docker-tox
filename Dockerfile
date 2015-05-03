FROM krallin/ubuntu-tini:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install \
       python-software-properties software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository -y ppa:fkrull/deadsnakes

RUN apt-get update \
    && apt-get -y install \
       wget python-pip \
       python2.6 python2.7 python3.2 python3.3 python3.4 \
       pypy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /install \
    && wget -O /install/pypy3-2.4-linux_x86_64-portable.tar.bz2 \
           "https://bitbucket.org/squeaky/portable-pypy/downloads/pypy3-2.4-linux_x86_64-portable.tar.bz2" \
    && tar jxf /install/pypy3-*.tar.bz2 -C /install \
    && rm /install/pypy3-*.tar.bz2 \
    && ln -s /install/pypy3-*/bin/pypy3 /usr/local/bin/pypy3

RUN pip install tox

WORKDIR /app
VOLUME /src

ONBUILD ADD requirements*.txt tox.ini /app/
ONBUILD RUN TOXBUILD=true tox

CMD cp -rT /src/ /app/ && tox
