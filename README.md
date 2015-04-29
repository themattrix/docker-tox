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
ONBUILD ADD requirements*.txt /app/
ONBUILD ADD tox.ini /app/tox.ini
ONBUILD RUN TOXSKIPSDIST=true TOXCOMMANDS=installonly tox
```

This means your project must contain a `tox.ini` file and at least one at least one
`requirements.txt` file.

To avoid the tox environments being rebuilt every time you want to test your code,
tox is run twice:

1. Once during the `build` phase to initialize all of the environments, and
2. Once during the `run` phase to test your code.

When your requirements or tox configuration changes, *both* steps are run.
When your code changes, *only the second step is run*, saving valuable time.

For a full example, see the [`python-pypi-template`](https://github.com/themattrix/python-pypi-template) project.
