from aiogram import Router, types, F
from aiogram.fsm.context import FSMContext
from bot.states.promo_state import PromoStates
from bot.keyboards.reply import get_main_menu
from bot.keyboards.inline import get_location_menu

router = Router()

@router.message(F.text == "📍 Find Omega")
async def find_omega_handler(message: types.Message):
    latitude = 47.095372480656245
    longitude = 31.922075134552557
    
    await message.answer_venue(
        latitude=latitude,
        longitude=longitude,
        title="Omega Energy Base",
        address="Peremohy Street, Kostyantynivka, Mykolaiv Region",
        reply_markup=get_location_menu())