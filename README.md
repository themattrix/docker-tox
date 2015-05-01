# Tox

*Available on Docker Hub as [`themattrix/tox`](https://registry.hub.docker.com/u/themattrix/tox/).*

This image is intended for running [tox](https://tox.readthedocs.org/en/latest/) with
Python 2.6, 2.7, 3.2, 3.3, 3.4, PyPy, and PyPy3.
Its goal is to make testing your code against multiple Python versions quick and easy.
The image contains several `ONBUILD` commands for initializing the tox environments with
your project's `requirements.txt` files.


## Usage

The Dockerfile contains the following `ONBUILD` commands:

```Dockerfile
ONBUILD ADD requirements*.txt tox*.ini /app/
ONBUILD RUN tox -c tox.build.ini
```

This means your project must contain a `tox.ini`, `tox.build.ini`, and at least one
`requirements.txt` file.

To avoid the tox environments being rebuilt every time you want to test your code,
tox is run twice - each with a different config file:

1. `tox.build.ini`

    Executed during the `build` phase to initialize all of the environments. This config
    file is expected to *not* install your code nor run your tests; it should *only*
    install the requirements which your project needs to be tested. Example:
    
        [tox]
        envlist = py26,py27,py32,py33,py34,pypy,pypy3
        skipsdist = true

        [testenv]
        whitelist_externals = true
        deps =
            -rrequirements_test_runner.txt
            -rrequirements_static_analysis.txt
            -rrequirements_test.txt
        commands = true
    
2. `tox.ini`

    Executed during the `run` phase to test your code. Example:
    
        [tox]
        envlist = py26,py27,py32,py33,py34,pypy,pypy3
    
        [testenv]
        whitelist_externals = true
        deps =
            -rrequirements_test_runner.txt
            -rrequirements_static_analysis.txt
            -rrequirements_test.txt
        commands =
            flake8 setup.py "my_package"
            pyflakes setup.py "my_package"
            pylint --rcfile=.pylintrc "my_package"
            nosetests "my_package"

When your requirements or tox configuration changes, *both* steps are run.
When your code changes, *only the second step is run*, saving valuable time.

For a full example, see the [`python-pypi-template`](https://github.com/themattrix/python-pypi-template) project, which uses this image.
