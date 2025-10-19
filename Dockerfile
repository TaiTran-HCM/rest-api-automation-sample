# --- Base image ---
FROM python:3.12-slim

# --- Set working directory ---
WORKDIR /test-app

# --- Copy dependency file ---
COPY requirements.txt .

# --- Install dependencies ---
RUN pip install --no-cache-dir -r requirements.txt

# --- Copy source code ---
COPY . .

# --- Expose port (optional, compose sẽ map) ---

# --- Define environment variables ---
ENV PYTHONUNBUFFERED=1