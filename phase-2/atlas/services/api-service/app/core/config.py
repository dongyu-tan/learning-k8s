from dotenv import load_dotenv
from pydantic import field_validator
from pydantic_settings import BaseSettings

load_dotenv()


class Config(BaseSettings):
    app_name: str = "Atlas"
    debug: bool = False
    database_url: str | None = None
    db_name: str = "test.db"

    @field_validator("debug", mode="before")
    @classmethod
    def parse_debug(cls, value):
        if isinstance(value, str) and value.lower() in {"release", "prod", "production"}:
            return False
        return value

    @property
    def db_url(self):
        if self.database_url:
            return self.database_url
        return f"sqlite:///./{self.db_name}"


config = Config()
