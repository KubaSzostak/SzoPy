# xszo/gdalbox

`xszo/gdalpy` plus an SSH server: a workbench container to log into and use
like a small VM, with `tmux`, `sudo`, `nano` and `htop`. For interactive
geoprocessing and day-long jobs on data mounted from the host.

Source and the full description of all images:
[github.com/KubaSzostak/SzoPy/tree/main/images](https://github.com/KubaSzostak/SzoPy/tree/main/images)

## Tags

| Tag           | Meaning                                                       |
|---------------|---------------------------------------------------------------|
| `3.13`        | GDAL minor version; moves to the newest build of that version |
| `3.13.261015` | the same, date-stamped, for rollback                          |
| `latest`      | the newest GDAL in the list                                   |

## Inside

- everything that is in `xszo/gdalpy` of the same tag, built from the same
  recipe
- `openssh-server` on port 22, key authentication only, no root login
- user `boxer` with passwordless `sudo`; `PUID` and `PGID` set its uid and
  gid at start, so files written to a mounted folder get the host owner
- `tmux`, `nano`, `htop`
- every start prints the image name, tool versions and the szo version
  to stderr, after installing the `szo` named by `SZO_VERSION`, if set;
  then it generates the host key in `/etc/ssh/keys` when missing and runs
  `sshd`

## Use

```yaml
services:
  gdalbox:
    image: xszo/gdalbox:3.13
    hostname: gdalbox
    restart: unless-stopped
    ports:
      - "2201:22"
    environment:
      PUID: "1000"
      PGID: "1000"
    volumes:
      - ./home:/home/boxer
      - ./ssh:/etc/ssh/keys
      - /srv/data:/srv/data
```

Mount the home and the host key folder, or dotfiles, `pip install --user`
packages and the server identity are lost at every recreate. Put the public
key of the client into `home/.ssh/authorized_keys`, owned by `PUID`, folder
mode `700`, file mode `600`. Then:

```bash
ssh -p 2201 boxer@host
```

The container starts as root so that `sshd` can switch to `boxer`; do not
set `user:`. `SZO_VERSION: "0.1.0"` in `environment:` installs that `szo`
into the environment at every start instead of the baked-in newest release.
