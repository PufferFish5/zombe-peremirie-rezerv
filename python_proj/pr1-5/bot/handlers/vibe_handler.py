from aiogram import Router, types, F
from aiogram.types import FSInputFile
from bot.keyboards.inline import get_vibe_menu

router = Router()

@router.message(F.text == "🎧 Vibe Check")
async def vibe_check_handler(message: types.Message):
    video_note_file = FSInputFile("bot/media/vibe_circle.mp4")
#    video_note_file = "bBAACAgIAAxkBAAIB8Gmm1aSSUa1I7cCMyE3HyRzOgQcyAAIBnAACUYEwSbXoyG9MNCffOgQ"

    await message.answer_video_note(
        video_note=video_note_file,
        reply_markup=get_vibe_menu()
    )