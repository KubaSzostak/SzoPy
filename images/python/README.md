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
- every start prints the image name and tool versions to stderr

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

Set `user:` to the owner of the mounted folders. Give a library that
needs a writable home `HOME=/tmp` in `environment:`.

```bash
docker run --rm -it -v "$PWD:/app" xszo/python:3.14 python main.py
```
