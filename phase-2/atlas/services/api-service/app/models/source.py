from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class SourceCreate(BaseModel):
    name: str
    table_name: str
    timestamp_column: str
    expected_frequency_minutes: int = Field(gt=0)


class SourceRead(SourceCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime


class CheckResultRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    source_id: int
    checked_at: datetime
    latest_data_at: datetime | None
    lag_minutes: int | None
    status: str | None


class SourceDetail(SourceRead):
    latest_result: CheckResultRead | None
