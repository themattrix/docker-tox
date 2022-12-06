# Tox

*Available on Docker Hub as [`btenmann/tox`](https://registry.hub.docker.com/u/themattrix/tox/).*

This image is intended for running [tox](https://tox.readthedocs.org/en/latest/) with
Python 2.7, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, PyPy, and PyPy3.
Its goal is to make testing your code against multiple Python versions quick and easy.
The image contains several `ONBUILD` commands for initializing the tox environments with
your project's `requirements.txt` files.


## Usage

The Dockerfile contains the following `ONBUILD` commands:

```dockerfile
ONBUILD COPY install-prereqs*.sh requirements*.txt tox.ini /app/
ONBUILD ARG SKIP_TOX=false
ONBUILD RUN bash -c " \
    if [ -f '/app/install-prereqs.sh' ]; then \
        bash /app/install-prereqs.sh; \
    fi && \
    if [ $SKIP_TOX == false ]; then \
        TOXBUILD=true tox; \
    fi"
```

This means your project *must* contain a `tox.ini` file.

You can also optionally include an `install-prereqs.sh` script for installing
prerequisites of the project requirements.

To avoid the tox environments being rebuilt every time you want to test your code,
tox is run twice - first with the `TOXBUILD` environment variable set to `true`,
and second without it being set:

1. `$ TOXBUILD=true tox`

    Executed during the `build` phase to initialize all of the environments. It is
    expected *not* to install your code nor run your tests; it should *only*
    install the requirements which your project needs to be tested.

    This step can be skipped by specifying `--build-arg SKIP_TOX=true` in the build phase.

2. `$ tox`

    Executed during the `run` phase to test your code.


When your requirements or tox configuration changes, *both* steps are run.
When your code changes, *only the second step is run*, saving valuable time.
This also ensures that your code is always tested in a completely clean
environment.

Example `tox.ini` supporting the TOXBUILD environment variable:

    [tox]
    envlist = py27,py35,py36,py37,py38,py39,py310,py311,pypy,pypy3
    skipsdist = {env:TOXBUILD:false}

    [testenv]
    passenv = LANG
    whitelist_externals = true
    deps =
        -rrequirements_test_runner.txt
        -rrequirements_static_analysis.txt
        -rrequirements_test.txt
    commands = {env:TOXBUILD:./tests.sh --static-analysis}


For a full example, see the [`python-pypi-template`](
https://github.com/themattrix/python-pypi-template) project, which uses this image.
