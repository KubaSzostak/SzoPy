# Docker images

Three general-purpose images for running Python scripts in containers.
Each is built from `ubuntu:26.04` with a conda-forge environment, `psql`,
the PostGIS command-line loaders and the `szo` package. They differ in
what is pinned by the tag and what floats to the newest version at build
time.

| Image                                 | Tag pins           | Floats       | GDAL   |
|---------------------------------------|--------------------|--------------|--------|
| [xszo/python](python/README.md)       | Python             | psql         | no     |
| [xszo/postgispy](postgispy/README.md) | psql major version | Python, GDAL | newest |
| [xszo/gdalpy](gdalpy/README.md)       | GDAL minor version | Python, psql | pinned |

Pick the image by the thing your scripts must not drift on. Plain database
work: `python`. Loading data into a PostGIS server of a known version:
`postgispy`. Geoprocessing tested against one GDAL: `gdalpy`.

## Tags

Every build publishes two tags, and the newest version also gets `latest`:

| Tag                  | Example                   | Use                                                                                 |
|----------------------|---------------------------|-------------------------------------------------------------------------------------|
| `<version>`          | `xszo/gdalpy:3.13`        | in compose files; moves to the newest build of that version                         |
| `<version>.<YYMMDD>` | `xszo/gdalpy:3.13.261007` | pinned reference for rollback                                                       |
| `latest`             | `xszo/gdalpy:latest`      | the newest version in `versions.json`; convenient for `docker run`, not for compose |

The versions built, the build argument that pins each image and which
version is `latest` are in [versions.json](versions.json). Adding a version
means adding it there; removing a version from the file stops building it
but does not delete published tags.

## What is inside

Common to all three images:

- `/opt/conda/envs/szo`, a conda-forge environment on `PATH`, so `python`,
  `pip` and `pytest` work without activation
- `psql` and the PostGIS loaders `shp2pgsql`, `pgsql2shp`, `raster2pgsql`
  from the PGDG apt repository; no PostgreSQL server
- Python packages: `szo`, `psycopg` (v3, with the C speedup), `sqlalchemy`,
  `requests`, `python-dotenv`, `pyyaml`, `numpy`, `pandas`, `polars`,
  `pyarrow`, `openpyxl`, `xlsxwriter`, `tabulate`, `structlog`, `pytest`
- working directory `/app`, default command `bash`, `HOME=/home/szo`
- an entrypoint that prints the image name and the Python, psql and GDAL
  versions to stderr on every start, installs the szo of `SZO_VERSION`
  when that variable is set, prints the szo version, then runs the command

`postgispy` and `gdalpy` add the geo set: `gdal`, `shapely`, `fiona`,
`pyogrio`, `rasterio`, `geopandas`, `matplotlib`, `h3-py`, `duckdb`.

## User

The images run as root by default, like the official `python` image. Bind
mounts then get root-owned files, so set the user in the compose file to
the owner of the mounted folders:

```yaml
services:
  app:
    image: xszo/python:3.14
    user: "1000:1000"
    working_dir: /app
    volumes:
      - ./scripts:/app:ro
    command: python main.py
```

`HOME` is `/home/szo`, writable by any uid, so caches and `pip install
--user` work whatever `user:` says.

## Choosing the szo version at start

Each build bakes in the newest `szo` from PyPI. The environment variable
`SZO_VERSION` overrides it: the entrypoint runs `pip install --user` of
that version before the command, and the user site shadows the baked copy.

```yaml
    environment:
      SZO_VERSION: "0.1.0"
```

The install happens on every start, since the container's writable layer
is discarded on recreate, and it needs PyPI to be reachable; without it
the container fails to start. Unset, nothing is installed.

## Pinning szo in a local image

A host that must not depend on PyPI at start time builds a derived image
once, on top of the pulled base image, with the szo version baked in:

```bash
sudo docker build -t mygdal:3.10 --build-arg BASE=xszo/gdalpy:3.10 --build-arg SZO_VERSION=0.1.2 - <<'EOF'
ARG BASE
FROM ${BASE}
ARG SZO_VERSION
RUN pip install --no-cache-dir "szo==${SZO_VERSION}"
EOF
```

It takes seconds, needs no file on the host, and the compose file then
names `mygdal:3.10`. The name is free, as long as it is not one that exists
on Docker Hub: a local `xszo/gdalpy:3.10` would be overwritten by the next
`docker compose pull`. The derived image keeps the entrypoint, so its banner
shows the pinned szo. Rebuild it after pulling a newer base image.

## Building locally

```bash
docker build --build-arg PYTHON_VERSION=3.14 -t xszo/python:3.14 images/python
docker build --build-arg PG_VERSION=18 -t xszo/postgispy:18 images/postgispy
docker build --build-arg GDAL_VERSION=3.13 -t xszo/gdalpy:3.13 images/gdalpy
```

Without a build argument each Dockerfile builds its `latest` version. The
labels `org.opencontainers.image.revision` and `.created` take the build
arguments `REVISION` and `CREATED`; the workflow passes the commit hash and
the build time, a local build may leave them empty.

Smoke test:

```bash
docker run --rm xszo/python:3.14 python --version
docker run --rm xszo/python:3.14 psql --version
docker run --rm xszo/python:3.14 python -c "import szo, psycopg; print(szo.__version__)"
docker run --rm xszo/gdalpy:3.13 python -c "from osgeo import gdal; print(gdal.__version__)"
docker run --rm xszo/postgispy:18 raster2pgsql 2>&1 | head -1
```

## Publishing

The images live on Docker Hub in the `xszo` organization; pushes are made by
the member account `kuszo`. The GitHub Actions workflow builds and
pushes every version in `versions.json` on each push to `main` that touches
`images/`, and on manual dispatch; it also pushes each image's `README.md`
as the Docker Hub description. It authenticates with the repository secrets
`DOCKERHUB_USERNAME` (`kuszo`) and `DOCKERHUB_TOKEN`, an access token
of that account with read and write scope. Neither value is in the
repository.

To push a build by hand:

```bash
docker login -u kuszo
docker tag xszo/python:3.14 xszo/python:3.14.$(date +%y%m%d)
docker push xszo/python:3.14
docker push xszo/python:3.14.$(date +%y%m%d)
```

A host then pulls with `docker compose pull`; no image is ever copied over
ssh.

## Gotchas

- A new GDAL minor version is usable only once `rasterio` and `pyogrio`
  have conda-forge builds against it; 3.13 had to wait for rasterio 1.5.2.
  Check before adding a version to `versions.json`.
- The `postgis` apt package from PGDG is the command-line loaders only. It
  installs no server and no extension files; the PostGIS version it carries
  is the newest PGDG publishes for Ubuntu 26.04.
- Images are amd64 only, matching the hosts they run on.
