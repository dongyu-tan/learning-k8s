from fastapi import FastAPI
from fastapi.openapi.docs import get_swagger_ui_html
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from starlette.responses import HTMLResponse, JSONResponse

from app.api.v1 import sources, user
from app.core.config import config
from app.core.logging import setup_logging
from app.db.schema import Base, engine

setup_logging()
Base.metadata.create_all(bind=engine)

app = FastAPI(title=config.app_name, docs_url=None)


@app.get("/healthz", include_in_schema=False)
def healthz():
    return {"status": "ok"}


@app.get("/readyz", include_in_schema=False)
def readyz():
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except SQLAlchemyError:
        return JSONResponse(status_code=503, content={"status": "not_ready"})

    return {"status": "ok"}


@app.get("/docs", include_in_schema=False)
def custom_swagger_ui_html() -> HTMLResponse:
    return get_swagger_ui_html(
        openapi_url=app.openapi_url,
        title=f"{config.app_name} - Swagger UI",
        swagger_js_url="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js",
        swagger_css_url="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css",
    )

# Register routes
app.include_router(sources.router, prefix="/api/v1")
app.include_router(user.router, prefix="/api/v1")
