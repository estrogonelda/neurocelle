# Browsers + system deps are preinstalled in the official Playwright image.
FROM mcr.microsoft.com/playwright/python:v1.49.1-noble
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
WORKDIR /e2e
COPY requirements.txt .
# Optional build secret "ca_bundle": extra CA certificates for builds behind a
# TLS-intercepting proxy. Absent by default (e.g. in CI) and never stored in the image.
RUN --mount=type=secret,id=ca_bundle,required=false \
    if [ -s /run/secrets/ca_bundle ]; then export PIP_CERT=/run/secrets/ca_bundle; fi; \
    pip install -r requirements.txt
COPY pytest.ini conftest.py ./
COPY tests ./tests
CMD ["pytest", "-v"]
