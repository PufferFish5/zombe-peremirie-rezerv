import asyncio
import logging
from aiogram import Bot, Dispatcher, F
from bot.config import config
from bot.handlers import start_handler
from bot.handlers import promo_handler
from bot.handlers import catalog_handler
from bot.handlers import geo_handler
from bot.handlers import formula_handler
from bot.handlers import vibe_handler
from bot.handlers import stats_handler
from bot.handlers import order_handler
from bot.databases.models import db_main
import bot.databases.requests as rq

async def main():
    logging.basicConfig(level=logging.DEBUG)
    await db_main()
    await rq.seed_drinks()

    bot = Bot(token=config.bot_token.get_secret_value())
    dp = Dispatcher()

    dp.include_router(start_handler.router)
    dp.include_router(promo_handler.router)
    dp.include_router(catalog_handler.router)
    dp.include_router(geo_handler.router)
    dp.include_router(formula_handler.router)
    dp.include_router(vibe_handler.router)
    dp.include_router(stats_handler.router)
    dp.include_router(order_handler.router)
    await bot.delete_webhook(drop_pending_updates=True)
    await dp.start_polling(bot)
    
if __name__ == '__main__':
    try:
        import asyncio
        asyncio.run(main())
    except KeyboardInterrupt:
        pass