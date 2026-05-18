from bot.databases.models import async_session, User, Drink, Order
from sqlalchemy import select, update

async def set_user(tg_id: int):
    async with async_session() as session:
        user = await session.scalar(select(User).where(User.tg_id == tg_id))

        if not user:
            session.add(User(tg_id=tg_id))
            await session.commit()
            print(f"New user registered: {tg_id}")

async def update_user_profile(tg_id: int, name: str, phone: str, email: str):
    async with async_session() as session:
        await session.execute(
            update(User).where(User.tg_id == tg_id).values(
                name=name,
                phone=phone,
                email=email
            )
        )
        await session.commit()

async def get_user_stats(tg_id: int):
    async with async_session() as session:
        return await session.scalar(select(User).where(User.tg_id == tg_id))

async def add_points(tg_id: int, points_to_add: int):
    async with async_session() as session:
        await session.execute(
            update(User).where(User.tg_id == tg_id).values(points=User.points + points_to_add)
        )
        await session.commit()

async def seed_drinks():
    async with async_session() as session:
        result = await session.execute(select(Drink).limit(1))
        exists = result.scalars().first()
        
        if not exists:
            new_drinks = [
                Drink(name="🌴 Tropical Burst", series="tropical", price=60.0),
                Drink(name="🫐 Electric Berry", series="tropical", price=50.0),
                Drink(name="🍉 Cooling Watermelon", series="tropical", price=45.0),
                Drink(name="🥭 Neon Mango", series="tropical", price=40.0),
                Drink(name="☕️ Black Coffe", series="noir", price=60.0),
                Drink(name="💫 Mysterious Blackberry", series="noir", price=50.0),
                Drink(name="🍒 Deep Cherry", series="noir", price=45.0),
                Drink(name="🍋 Sharp Lemon", series="noir", price=40.0),
                Drink(name="🔥 Bold Grape", series="thug", price=60.0),
                Drink(name="✨ Gold Citrus", series="thug", price=50.0),
                Drink(name="🍍 Rich Pineapple", series="thug", price=45.0),
                Drink(name="🍋‍🟩 Hustling Lime", series="thug", price=40.0),
                Drink(name="👑 Miyagoda Rofls", series="og", price=100.0)
            ]
            session.add_all(new_drinks)
            await session.commit()
            print("Database seeded: Drinks added.")
        else:
            print("Database already has drinks. Skipping seed.")

async def get_drinks_by_series(series_type: str):
    async with async_session() as session:
        result = await session.execute(select(Drink).where(Drink.series == series_type))
        return result.scalars().all()

async def get_drink_by_id(drink_id: int):
    async with async_session() as session:
        return await session.get(Drink, drink_id)

async def get_all_profiles():
    async with async_session() as session:
        result = await session.execute(select(User).where(User.name.is_not(None)))
        return result.scalars().all()
    
async def add_order(user_tg_id: int, drink_id: int, address: str):
    async with async_session() as session:
        new_order = Order(
            user_tg_id = user_tg_id,
            drink_id = drink_id,
            address = address
        )
        session.add(new_order)
        await session.commit()
        await session.refresh(new_order)
        return new_order.id
