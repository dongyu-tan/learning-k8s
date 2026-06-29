from sqlalchemy.orm import Session

from app.db.schema import CheckResult, Source
from app.models.source import SourceCreate


class SourceService:
    def __init__(self, session: Session):
        self._db = session

    def create_source(self, payload: SourceCreate) -> Source:
        source = Source(**payload.model_dump())
        self._db.add(source)
        self._db.commit()
        self._db.refresh(source)
        return source

    def list_sources(self) -> list[Source]:
        return self._db.query(Source).order_by(Source.id).all()

    def get_source(self, source_id: int) -> Source | None:
        return self._db.query(Source).filter(Source.id == source_id).first()

    def get_latest_result(self, source_id: int) -> CheckResult | None:
        return (
            self._db.query(CheckResult)
            .filter(CheckResult.source_id == source_id)
            .order_by(CheckResult.checked_at.desc(), CheckResult.id.desc())
            .first()
        )

    def get_history(self, source_id: int) -> list[CheckResult]:
        return (
            self._db.query(CheckResult)
            .filter(CheckResult.source_id == source_id)
            .order_by(CheckResult.checked_at.desc(), CheckResult.id.desc())
            .all()
        )
