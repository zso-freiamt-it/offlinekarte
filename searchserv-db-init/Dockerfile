FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /workspace/searchserv

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash sudo ca-certificates wget gnupg libpq-dev gcc \
    && install -d /etc/apt/keyrings \
    && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client-16 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --create-home --shell /usr/sbin/nologin postgres \
    && printf 'Defaults env_keep += "PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD PGOPTIONS DB_CONNECT_TRIES DB_CONNECT_DELAY PYTHON_BIN DB_NAME INPUT_DIR OUTPUT_DIR"\n' > /etc/sudoers.d/searchserv \
    && chmod 0440 /etc/sudoers.d/searchserv

COPY requirements.txt ./requirements.txt
RUN python -m venv /workspace/searchserv/venv \
    && /workspace/searchserv/venv/bin/pip install --no-cache-dir -r requirements.txt

COPY . ./
RUN sed -i 's/\r$//' /workspace/searchserv/docker-entrypoint.sh /workspace/searchserv/load_db.sh
RUN chmod +x /workspace/searchserv/load_db.sh /workspace/searchserv/docker-entrypoint.sh

ENTRYPOINT ["/workspace/searchserv/docker-entrypoint.sh"]
