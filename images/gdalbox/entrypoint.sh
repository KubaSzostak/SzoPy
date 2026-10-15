#!/bin/bash
# On every start: banner to stderr, szo of SZO_VERSION if set, its version,
# boxer's uid and gid from PUID and PGID, the host key if missing, then the command.
set -e

{
    echo xszo/gdalbox
    python --version
    psql --version
    gdalinfo --version
    if [ -n "$SZO_VERSION" ]; then
        pip install --quiet --root-user-action=ignore "szo==$SZO_VERSION"
    fi
    python -c "import szo; print('szo', szo.__version__)"
} >&2

if [ -n "$PGID" ] && [ "$PGID" != "$(id -g boxer)" ]; then
    groupmod -o -g "$PGID" boxer
fi
if [ -n "$PUID" ] && [ "$PUID" != "$(id -u boxer)" ]; then
    usermod -o -u "$PUID" boxer
fi

if [ ! -f /etc/ssh/keys/ssh_host_ed25519_key ]; then
    ssh-keygen -q -t ed25519 -N "" -f /etc/ssh/keys/ssh_host_ed25519_key
fi

exec "$@"
