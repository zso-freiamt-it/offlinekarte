FROM python:3.13.14 AS build

WORKDIR /app

RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
	pip install -r requirements.txt

FROM python:3.13.14-trixie

WORKDIR /app

RUN apt install libpq5

COPY --from=build /venv /venv

COPY ./search.py .
COPY ./db_connect.py .

EXPOSE 8000

CMD ["/venv/bin/python3", "-m", "uvicorn", "search:app", "--host=0.0.0.0"]
