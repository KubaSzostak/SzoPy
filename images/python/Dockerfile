# xszo/python: pinned Python, newest psql and PostGIS commands, no GDAL.
FROM ubuntu:26.04

ARG PYTHON_VERSION=3.14
ARG REVISION=
ARG CREATED=
LABEL org.opencontainers.image.source=https://github.com/KubaSzostak/SzoPy \
      org.opencontainers.image.version=${PYTHON_VERSION} \
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
        postgresql-client postgis \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
        -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -b -p $CONDA_DIR \
    && rm /tmp/miniforge.sh

RUN $CONDA_DIR/bin/conda create -y -n szo -c conda-forge \
        python=${PYTHON_VERSION} \
        psycopg psycopg-c sqlalchemy \
        requests python-dotenv pyyaml \
        numpy pandas polars pyarrow \
        openpyxl xlsxwriter tabulate \
        structlog pytest \
    && $CONDA_DIR/bin/conda clean -afy

ENV PATH=$CONDA_DIR/envs/szo/bin:$PATH
RUN pip install --no-cache-dir szo

# A home writable by any uid, so pip --user and config caches work under user:.
RUN mkdir -m 1777 /home/szo
ENV HOME=/home/szo

WORKDIR /app
# On every start: banner to stderr, szo of SZO_VERSION if set, its version, then the command.
# sh -c receives the command after the script, so it is $0 followed by $@.
ENTRYPOINT ["sh", "-c", "{ echo xszo/python; python --version; psql --version; if [ -n \"$SZO_VERSION\" ]; then pip install --quiet --user --root-user-action=ignore \"szo==$SZO_VERSION\" || exit 1; fi; python -c \"import szo; print('szo', szo.__version__)\"; } >&2; exec \"$0\" \"$@\""]
CMD ["bash"]
