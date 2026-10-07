# xszo/gdalpy

GDAL pinned by the tag, newest Python, newest `psql` and PostGIS loaders.
For geoprocessing scripts tested against one GDAL version.

Source and the full description of all three images:
[github.com/KubaSzostak/SzoPy/tree/main/images](https://github.com/KubaSzostak/SzoPy/tree/main/images)

## Tags

| Tag                    | Meaning                                                       |
|------------------------|---------------------------------------------------------------|
| `3.13`, `3.12`, `3.10` | GDAL minor version; moves to the newest build of that version |
| `3.13.261007`          | the same, date-stamped, for rollback                          |
| `latest`               | the newest GDAL in the list                                   |

## Inside

- GDAL of the tagged version from conda-forge, with every geo package
  resolved against it in one step, in `/opt/conda/envs/szo`, on `PATH`
- the newest Python that conda-forge resolves at build time
- `gdal`, `shapely`, `fiona`, `pyogrio`, `rasterio`, `geopandas`,
  `matplotlib`, `h3-py`, `duckdb`
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
    image: xszo/gdalpy:3.13
    user: "1000:1000"
    working_dir: /app
    volumes:
      - ./scripts:/app:ro
    command: python process.py
```

Set `user:` to the owner of the mounted folders; `HOME` is `/home/szo`,
writable by any uid. `SZO_VERSION: "0.1.0"` in `environment:` installs
that `szo` at every start instead of the baked-in newest release.

```bash
docker run --rm -v "$PWD:/app" xszo/gdalpy:3.13 gdalinfo input.tif
```
