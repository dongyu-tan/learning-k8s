from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.dependencies import get_db
from app.models.source import CheckResultRead, SourceCreate, SourceDetail, SourceRead
from app.services.source_service import SourceService

router = APIRouter(tags=["sources"])


def get_source_service(db: Session = Depends(get_db)) -> SourceService:
    return SourceService(session=db)


@router.post("/sources", response_model=SourceRead)
def create_source(
    payload: SourceCreate, service: SourceService = Depends(get_source_service)
):
    return service.create_source(payload)


@router.get("/sources", response_model=list[SourceRead])
def get_sources(service: SourceService = Depends(get_source_service)):
    return service.list_sources()


@router.get("/sources/{source_id}", response_model=SourceDetail)
def get_source(source_id: int, service: SourceService = Depends(get_source_service)):
    source = service.get_source(source_id)
    if not source:
        raise HTTPException(status_code=404, detail="Source not found")

    return SourceDetail.model_validate(
        {
            **SourceRead.model_validate(source).model_dump(),
            "latest_result": service.get_latest_result(source_id),
        }
    )


@router.get("/sources/{source_id}/history", response_model=list[CheckResultRead])
def get_source_history(
    source_id: int, service: SourceService = Depends(get_source_service)
):
    source = service.get_source(source_id)
    if not source:
        raise HTTPException(status_code=404, detail="Source not found")

    return service.get_history(source_id)
