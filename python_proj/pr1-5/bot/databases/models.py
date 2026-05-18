import re
from typing import Optional
from sqlalchemy import BigInteger, ForeignKey, String, Integer, Float, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, validates, relationship
from sqlalchemy.ext.asyncio import AsyncAttrs, async_sessionmaker, create_async_engine


class Base(AsyncAttrs, DeclarativeBase):
    pass

class User(Base):
    __tablename__ = 'users'

    id: Mapped[int] = mapped_column(primary_key=True)
    tg_id: Mapped[int] = mapped_column(BigInteger)
    name: Mapped[Optional[str]] = mapped_column(String(100))
    phone: Mapped[Optional[str]] = mapped_column(String(20))
    email: Mapped[Optional[str]] = mapped_column(String(100), unique=True)
    points: Mapped[int] = mapped_column(default=0)

class Drink(Base):
    __tablename__ = 'drinks'
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50), unique=True)
    series: Mapped[str] = mapped_column(String(50))
    price: Mapped[float] = mapped_column(Float)
    photo_id: Mapped[str] = mapped_column(String(255), nullable=True)

class Order(Base):
    __tablename__ = 'orders'
    id: Mapped[int] = mapped_column(primary_key=True)
    user_tg_id: Mapped[int] = mapped_column(BigInteger, ForeignKey('users.tg_id'))
    drink_id: Mapped[int] = mapped_column(ForeignKey('drinks.id'))
    address: Mapped[str] = mapped_column(String(255))
    status: Mapped[str] = mapped_column(String(50), default="pending")
    user = relationship("User")
    drink = relationship("Drink")
engine = create_async_engine(url='sqlite+aiosqlite:///db.sqlite3')
async_session = async_sessionmaker(engine)

async def db_main():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)