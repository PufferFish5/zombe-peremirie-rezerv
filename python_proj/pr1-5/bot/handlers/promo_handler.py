from aiogram import Router, types, F
from aiogram.fsm.context import FSMContext
from bot.states.promo_state import PromoStates
from bot.keyboards.reply import get_main_menu, get_cancel_menu
from bot.databases import requests as rq

router = Router()

@router.message(F.text == "💎 Drop a Code")
async def start_promo_process(message: types.Message, state: FSMContext):
    await state.set_state(PromoStates.waiting_for_code)
    await message.answer(
        "Got a code from under the cap? Type it in below to stack those Omega Points!",
        reply_markup=get_cancel_menu()
    )

@router.message(F.text == "🔙 Back to Menu")
async def cancel_handler(message: types.Message, state: FSMContext):
    await state.clear()
    await message.answer(
        "Back to the main hub. What's next, champ?",
        reply_markup=get_main_menu()
    )

@router.message(PromoStates.waiting_for_code)
async def process_code(message: types.Message, state: FSMContext):
    code = message.text
    if len(code) == 8:
        await state.clear()
        await rq.add_points(message.from_user.id, 10),
        await message.answer(
            f"Locked in! **{code}** is valid. +10 Points added to your vault!",
            reply_markup=get_main_menu(),
            parse_mode="Markdown"
        )
    else:
        await message.answer(
            "My bad, that code doesn't look right. It should be 8 characters. "
            "Try again or hit the button to go back."
        )