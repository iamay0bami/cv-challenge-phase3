# backend/Dockerfile
FROM python:3.10-slim

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Ensure poetry is available
ENV PATH="/root/.local/bin:$PATH"

# Set workdir
WORKDIR /app

# Copy pyproject.toml and poetry.lock first (for caching)
COPY pyproject.toml poetry.lock* /app/

# Install dependencies (no virtualenvs)
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root
# Copy the backend app code
COPY . /app

# Expose FastAPI port
EXPOSE 8000

# Run FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
