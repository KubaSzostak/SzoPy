# xszo/postgispy

`psql` pinned by the tag to a PostgreSQL major version, newest Python,
newest GDAL and PostGIS loaders. For loading and maintaining data in a
PostGIS server of a known version.

Source and the full description of all three images:
[github.com/KubaSzostak/SzoPy/tree/main/images](https://github.com/KubaSzostak/SzoPy/tree/main/images)

## Tags

| Tag         | Meaning                                                                       |
|-------------|-------------------------------------------------------------------------------|
| `18`, `17`  | PostgreSQL major version of `psql`; moves to the newest build of that version |
| `18.261007` | the same, date-stamped, for rollback                                          |
| `latest`    | the newest PostgreSQL in the list                                             |

## Inside

- `psql` of the tagged version and `shp2pgsql`, `pgsql2shp`, `raster2pgsql`
  from PGDG; no PostgreSQL server
- the newest Python and GDAL that conda-forge resolves at build time, in
  `/opt/conda/envs/szo`, on `PATH`
- `gdal`, `shapely`, `fiona`, `pyogrio`, `rasterio`, `geopandas`,
  `matplotlib`, `h3-py`, `duckdb`
- `szo`, `psycopg` (v3), `sqlalchemy`, `requests`, `python-dotenv`,
  `pyyaml`, `numpy`, `pandas`, `polars`, `pyarrow`, `openpyxl`,
  `xlsxwriter`, `tabulate`, `structlog`, `pytest`
- working directory `/app`, default command `bash`, runs as root
- every start prints the image name and tool versions to stderr

## Use

```yaml
services:
  app:
    image: xszo/postgispy:18
    user: "1000:1000"
    working_dir: /app
    volumes:
      - ./scripts:/app:ro
    command: python load.py
```

Set `user:` to the owner of the mounted folders. Give a library that
needs a writable home `HOME=/tmp` in `environment:`.

```bash
docker run --rm -v "$PWD:/app" xszo/postgispy:18 \
    shp2pgsql -s 4326 regions.shp public.regions
```
