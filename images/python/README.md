# xszo/python

Python pinned by the tag, newest `psql` and PostGIS loaders, no GDAL. A
general-purpose image for scripts that talk to PostgreSQL and process data
with pandas or polars.

Source and the full description of all three images:
[github.com/KubaSzostak/SzoPy/tree/main/images](https://github.com/KubaSzostak/SzoPy/tree/main/images)

## Tags

| Tag            | Meaning                                                   |
|----------------|-----------------------------------------------------------|
| `3.14`, `3.10` | Python version; moves to the newest build of that version |
| `3.14.261007`  | the same, date-stamped, for rollback                      |
| `latest`       | the newest Python in the list                             |

## Inside

- Python from conda-forge in `/opt/conda/envs/szo`, on `PATH`
- `psql` and `shp2pgsql`, `pgsql2shp`, `raster2pgsql` from PGDG, newest
  version at build time; no PostgreSQL server
- `szo`, `psycopg` (v3), `sqlalchemy`, `requests`, `python-dotenv`,
  `pyyaml`, `numpy`, `pandas`, `polars`, `pyarrow`, `openpyxl`,
  `xlsxwriter`, `tabulate`, `structlog`, `pytest`
- working directory `/app`, default command `bash`, runs as root
- every start prints the image name, tool versions and the szo version
  to stderr, after installing the `szo` named by `SZO_VERSION`, if set

## Use

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

Set `user:` to the owner of the mounted folders; `HOME` is `/home/szo`,
writable by any uid. `SZO_VERSION: "0.1.0"` in `environment:` installs
that `szo` at every start instead of the baked-in newest release.

```bash
docker run --rm -it -v "$PWD:/app" xszo/python:3.14 python main.py
```
