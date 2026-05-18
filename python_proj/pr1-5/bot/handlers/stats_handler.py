from aiogram import Router, types, F
import bot.databases.requests as rq

router = Router()

@router.message(F.text == "🏆 My Stats")
async def show_stats(message: types.Message):
    user_data = await rq.get_user_stats(message.from_user.id)
    if user_data:
        await message.answer(
            f"📊 <b>Your stats:</b>\n\n"
            f"👤 ID: <code>{message.from_user.id}</code>\n"
            f"💎 Poinst aquired: {user_data.points}",
            parse_mode="HTML"
        )
    else:
        await message.answer("You haven't even start me, press /start")
