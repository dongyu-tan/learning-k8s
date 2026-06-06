# 1. Always Base image (FROM)
FROM python:3.12-slim

# 2. Metadata & Vars (ENV, LABEL)
# PYTHONDONTWRITEBYTECODE = don't write into pyc(python cache file), as this only run once, not useful in container.
# PYTHONUNBUFFERED = makes print() and logs show up in the docker logs immedietly instead of waiting for buffer fill up.
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

# install uv, this step is require as uv doesn't not come preinstall
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 3. Working Dir (WORKDIR)
RUN useradd --create-home appuser
WORKDIR /app

# users should be created or added as early as possible so the layer is cached
# can switch to the user at the very end of the dockerfile
# 4. Dependencies Isolation (COPY, RUN)

# copy dependencies files, if pyproject.toml doesn't change, it won't reinstall packages(save time)
COPY pyproject.toml uv.lock ./

# install dependencies
# uv pip install is not recommended unless working in legacy repo
# should always use uv sync by default
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked --no-install-project --python 3.12

# what this does is it copies rest of the app code
COPY . .

RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked --python 3.12
# 5. Security & Ports (EXPOSE, USER)
# run as non-root user, good habit and better security
RUN chmod -R +x .venv/bin/
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# 6. Execution (CMD / ENTRYPOINT)
CMD ["/app/.venv/bin/uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

