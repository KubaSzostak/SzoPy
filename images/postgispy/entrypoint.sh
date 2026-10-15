#!/bin/bash
# On every start: banner to stderr, szo of SZO_VERSION if set, its version, then the command.
set -e

{
    echo xszo/postgispy
    python --version
    psql --version
    gdalinfo --version
    if [ -n "$SZO_VERSION" ]; then
        pip install --quiet --user --root-user-action=ignore "szo==$SZO_VERSION"
    fi
    python -c "import szo; print('szo', szo.__version__)"
} >&2

exec "$@"
