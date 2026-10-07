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
- every start prints the image name, tool versions and the szo version
  to stderr, after installing the `szo` named by `SZO_VERSION`, if set

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

Set `user:` to the owner of the mounted folders; `HOME` is `/home/szo`,
writable by any uid. `SZO_VERSION: "0.1.0"` in `environment:` installs
that `szo` at every start instead of the baked-in newest release.

```bash
docker run --rm -v "$PWD:/app" xszo/postgispy:18 \
    shp2pgsql -s 4326 regions.shp public.regions
```
