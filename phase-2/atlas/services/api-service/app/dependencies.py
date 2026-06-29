from typing import Annotated

from fastapi import Header, HTTPException
from sqlalchemy.orm import Session

from app.db.schema import SessionLocal


async def get_token_header(x_token: Annotated[str, Header()]):
    if x_token != "fake-super-secret-token":
        raise HTTPException(status_code=400, detail="X-Token header invalid")


async def get_query_token(token: str):
    if token != "jessica":
        raise HTTPException(status_code=400, detail="No Jessica token provided")


def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
