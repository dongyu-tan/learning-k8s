# 1. Always Base image (FROM)
FROM python:3.14-slim

# 2. Metadata & Vars (ENV, LABEL)
# PYTHONDONTWRITEBYTECODE = don't write into pyc(python cache file), as this only run once, not useful in container.
# PYTHONUNBUFFERED = makes print() and logs show up in the docker logs immedietly instead of waiting for buffer fill up.
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

# 3. Working Dir (WORKDIR)
WORKDIR /app

# 4. Dependencies Isolation (COPY, RUN)
# install uv, this step is require as uv doesn't not come preinstall
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# copy dependencies files, if pyproject.toml doesn't change, it won't reinstall packages(save time)
COPY pyproject.toml .

# install dependencies
RUN uv pip install --system -r pyproject.toml

# what this does is it copies rest of the app code
COPY . .

# 5. Security & Ports (EXPOSE, USER)
# run as non-root user, good habit and better security
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000

# 6. Execution (CMD / ENTRYPOINT)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

