#!/bin/bash
# On every start: banner to stderr, szo of SZO_VERSION if set, its version, then the command.
set -e

{
    echo xszo/python
    python --version
    psql --version
    if [ -n "$SZO_VERSION" ]; then
        pip install --quiet --user --root-user-action=ignore "szo==$SZO_VERSION"
    fi
    python -c "import szo; print('szo', szo.__version__)"
} >&2

exec "$@"
