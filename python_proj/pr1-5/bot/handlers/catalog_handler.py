from aiogram import Router, types, F
from aiogram.fsm.context import FSMContext
from aiogram.filters import Command
from aiogram.types import FSInputFile
from bot.states.catalog_state import CatalogStates
from bot.states.order_state import OrderStates
from bot.keyboards.reply import get_main_menu, get_cancel_menu
from bot.keyboards.inline import get_series_menu, get_drinks_menu
import bot.databases.requests as rq
router = Router()

@router.message(F.text == "⚡️ Get Fueled")
async def catalogue_series(message: types.Message, state: FSMContext):
    await state.set_state(CatalogStates.series_choice)
    await message.answer_photo(
        photo=FSInputFile("bot/media/news1.jpg"),
#        photo='AgACAgIAAxkBAAIBvGmmwXPU8L9dxAmuGlehs-f0_j-MAAKBGGsbUYEwSbsRJtsXFJIxAQADAgADeQADOgQ',
        caption="Check out our elite lineup. Which vibe are you feeling today?",
        reply_markup=get_series_menu())
    
# @router.message(Command("test"))
# async def catalogue_series(message: types.Message, state: FSMContext):
#     await state.set_state(CatalogStates.series_choice)
#     await message.answer(
#         "Check out our elite lineup. Which vibe are you feeling today?",
#         reply_markup=get_cancel_menu())
    
# @router.message(F.text == "🔙 Back to Menu")
# async def cancel_handler(message: types.Message, state: FSMContext):
#     await state.clear()
#     await message.answer(
#         "Back to the main hub. What's next, champ?",
#         reply_markup=get_main_menu()
#     )

@router.callback_query(F.data.startswith("series_"))
async def show_series(callback: types.CallbackQuery):
    series_type = callback.data.split("_")[1]
    drinks = await rq.get_drinks_by_series(series_type)
    # series_content = {
    #     "tropical": {"text": "Neon lights and retro vibes", "photo": "AgACAgIAAxkBAAIBvmmmwy8TKCoGaK_SnV-0oyoxgiQiAAKNGGsbUYEwSSiVoUhlYJmWAQADAgADeQADOgQ"},
    #     "noir": {"text": "Classic taste for deep thinkers.", "photo": "bAgACAgIAAxkBAAIBwGmmw0MVY9DxS4zI22-c3TUyt_PWAAKOGGsbUYEwST5cPKzdg3jgAQADAgADeQADOgQ"},
    #     "thug": {"text": "Powerful punch for the bold.", "photo": "bAgACAgIAAxkBAAIBwmmmw1Sl9DqjzRFyOE3gr96dwK_DAAKPGGsbUYEwSc2JwQFUb3YkAQADAgADeQADOgQ"},
    #     "og": {"text": "Where it all started.", "photo": "AgACAgIAAxkBAAIBxGmmw3_YoCDKcHe_39y3RFMjafK5AAKQGGsbUYEwSZr_EzFKbuy5AQADAgADeQADOgQ"}
    # }
    series_content = {
        "tropical": {"text": "Neon lights and retro vibes", "photo": "bot/media/series1_back_text.png"},
        "noir": {"text": "Classic taste for deep thinkers.", "photo": "bot/media/series2_back_text.png"},
        "thug": {"text": "Powerful punch for the bold.", "photo": "bot/media/series3_back_text.png"},
        "og": {"text": "Where it all started.", "photo": "bot/media/ex_drink1_render.png"}
    }

    content = series_content.get(series_type)
    await callback.message.edit_media(
        media=types.InputMediaPhoto(
            media=FSInputFile(content["photo"]),
            caption=content["text"]
        ),
        reply_markup=get_drinks_menu(drinks)
    )
    await callback.answer()

@router.callback_query(F.data == "back_to_series")
async def go_back_to_series(callback: types.CallbackQuery):
    await callback.message.edit_media(
        media=types.InputMediaPhoto(
            media=FSInputFile("bot/media/news1.jpg"),
#            media='AgACAgIAAxkBAAIBvGmmwXPU8L9dxAmuGlehs-f0_j-MAAKBGGsbUYEwSbsRJtsXFJIxAQADAgADeQADOgQ',
            caption="Pick your vibe again, champ!"
        ),
        reply_markup=get_series_menu()
    )
    await callback.answer()
#ZAPUSK NA POTOM DLYA ID
@router.message(F.photo)
async def get_photo_file_id(message: types.Message):
    photo_id = message.photo[-1].file_id
    await message.reply(photo_id, parse_mode="HTML")

@router.message(F.video)
async def get_video_note_file_id(message: types.Message):
    file_id = message.video.file_id
    await message.reply(file_id, parse_mode="HTML")