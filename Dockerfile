FROM themattrix/tox-base

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ONBUILD ARG SKIP_TOX=false
ONBUILD COPY install-prereqs*.sh /app/
ONBUILD RUN bash -c " \
    if [[ -f '/app/install-prereqs.sh' ]]; then \
        bash /app/install-prereqs.sh; \
    fi"

ONBUILD COPY requirements*.txt tox.ini /app/
ONBUILD RUN bash -c " \
    if [[ $SKIP_TOX == false ]]; then \
        TOXBUILD=true tox; \
    fi"
