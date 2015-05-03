# Tox

*Available on Docker Hub as [`themattrix/tox`](https://registry.hub.docker.com/u/themattrix/tox/).*

This image is intended for running [tox](https://tox.readthedocs.org/en/latest/) with
Python 2.6, 2.7, 3.2, 3.3, 3.4, PyPy, and PyPy3.
Its goal is to make testing your code against multiple Python versions quick and easy.
The image contains several `ONBUILD` commands for initializing the tox environments with
your project's `requirements.txt` files.


## Usage

The Dockerfile contains the following `ONBUILD` commands:

```dockerfile
ONBUILD ADD requirements*.txt tox.ini /app/
ONBUILD RUN TOXBUILD=true tox
```

This means your project must contain a `tox.ini` and at least one
`requirements.txt` file.

To avoid the tox environments being rebuilt every time you want to test your code,
tox is run twice - first with the `TOXBUILD` environment variable set to `true`,
and second without it being set:

1. `$ TOXBUILD=true tox`

    Executed during the `build` phase to initialize all of the environments. It is
    expected *not* to install your code nor run your tests; it should *only*
    install the requirements which your project needs to be tested.

2. `$ tox`

    Executed during the `run` phase to test your code.


When your requirements or tox configuration changes, *both* steps are run.
When your code changes, *only the second step is run*, saving valuable time.

Example `tox.ini` supporting the TOXBUILD environment variable:

    [tox]
    envlist = py26,py27,py32,py33,py34,pypy,pypy3
    skipsdist = {env:TOXBUILD:false}

    [testenv]
    whitelist_externals = true
    deps =
        -rrequirements_test_runner.txt
        -rrequirements_static_analysis.txt
        -rrequirements_test.txt
    commands = {env:TOXBUILD:./tests.sh --static-analysis}


For a full example, see the [`python-pypi-template`](https://github.com/themattrix/python-pypi-template) project, which uses this image.
