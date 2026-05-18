from aiogram import Router, types, F
from aiogram.fsm.context import FSMContext
from bot.keyboards.reply import get_main_menu

router = Router()
 
@router.message(F.text == "❓ The Formula")
async def formula_handler(message: types.Message):
    await message.answer(
        "<b>Clean energy only</b>. ☕ Caffeine + 🧪 Taurine + 💊 B-Vitamins. \n\n" 
        "No crushes, just pure flow. \n\n"
        "There can be a large text with whole formula, but you should probably check it <a href='https://pufferfish5.github.io/omega-energy/us/ingredients.html'>here</a>",
        parse_mode="HTML",
        disable_web_page_preview=True
    )