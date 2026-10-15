# xszo/gdalbox: gdalpy plus an SSH server, a workbench container to log into.
# The recipe mirrors gdalpy/Dockerfile up to the szo install; keep the two in step.
FROM ubuntu:26.04

ARG GDAL_VERSION=3.13
ARG REVISION=
ARG CREATED=
LABEL org.opencontainers.image.source=https://github.com/KubaSzostak/SzoPy \
      org.opencontainers.image.version=${GDAL_VERSION} \
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
        postgresql-client postgis git rclone \
        openssh-server tmux sudo nano htop \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
        -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -b -p $CONDA_DIR \
    && rm /tmp/miniforge.sh

# One conda create so every geo package resolves against the pinned GDAL.
# No python pin: conda picks the newest Python the packages support.
RUN $CONDA_DIR/bin/conda create -y -n szo -c conda-forge \
        gdal=${GDAL_VERSION} libgdal \
        shapely fiona pyogrio rasterio geopandas \
        matplotlib h3-py python-duckdb \
        psycopg psycopg-c sqlalchemy \
        requests python-dotenv pyyaml \
        numpy pandas polars pyarrow \
        openpyxl xlsxwriter tabulate \
        structlog pytest \
    && $CONDA_DIR/bin/conda clean -afy

ENV PATH=$CONDA_DIR/envs/szo/bin:$PATH
RUN pip install --no-cache-dir szo

# An ssh session does not see Docker's ENV; PAM reads /etc/environment for every login.
RUN echo "PATH=$CONDA_DIR/envs/szo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        > /etc/environment \
    && useradd --create-home --shell /bin/bash boxer \
    && echo "boxer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/boxer \
    && mkdir -p /run/sshd /etc/ssh/keys
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 22
ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
