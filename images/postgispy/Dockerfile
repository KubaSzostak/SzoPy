# xszo/postgispy: pinned psql, newest Python, GDAL and PostGIS commands.
FROM ubuntu:26.04

ARG PG_VERSION=18
ARG REVISION=
ARG CREATED=
LABEL org.opencontainers.image.source=https://github.com/KubaSzostak/SzoPy \
      org.opencontainers.image.version=${PG_VERSION} \
      org.opencontainers.image.revision=${REVISION} \
      org.opencontainers.image.created=${CREATED}

ENV DEBIAN_FRONTEND=noninteractive

# psql and the PostGIS loaders (shp2pgsql, pgsql2shp, raster2pgsql) from PGDG.
# The postgis package holds the commands only, no server.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt resolute-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        postgresql-client-${PG_VERSION} postgis \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
        -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -b -p $CONDA_DIR \
    && rm /tmp/miniforge.sh

# No python pin: conda picks the newest Python the packages support.
RUN $CONDA_DIR/bin/conda create -y -n szo -c conda-forge \
        gdal libgdal \
        shapely fiona pyogrio rasterio geopandas \
        matplotlib h3-py python-duckdb \
        psycopg psycopg-c sqlalchemy \
        requests python-dotenv pyyaml \
        numpy pandas polars pyarrow \
        openpyxl xlsxwriter tabulate \
        structlog pytest \
    && $CONDA_DIR/bin/conda clean -afy

ENV PATH=$CONDA_DIR/envs/szo/bin:$PATH
# Empty installs the newest szo from PyPI; a value pins it, e.g. 0.1.2.
ARG SZO_VERSION=
RUN pip install --no-cache-dir "szo${SZO_VERSION:+==$SZO_VERSION}"

WORKDIR /app
# Prints the banner to stderr on every start, then runs the command.
# sh -c receives the command after the script, so it is $0 followed by $@.
ENTRYPOINT ["sh", "-c", "{ echo xszo/postgispy; python --version; psql --version; gdalinfo --version; } >&2; exec \"$0\" \"$@\""]
CMD ["bash"]
