"""Certificate model."""

from sqlalchemy import Column, String, DateTime
from sqlalchemy.sql import func
from app.database import Base


class Certificate(Base):
    """User certification record."""

    __tablename__ = "certificates"

    id = Column(String, primary_key=True)
    user_id = Column(String, unique=True, nullable=False, index=True)
    certificate_id = Column(String, nullable=False)
    persona = Column(String, nullable=True)
    issued_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "certificate_id": self.certificate_id,
            "persona": self.persona,
            "issued_at": self.issued_at.isoformat() if self.issued_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
