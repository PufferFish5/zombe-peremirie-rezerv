from aiogram.types import ReplyKeyboardMarkup, KeyboardButton
from aiogram.utils.keyboard import ReplyKeyboardBuilder
from aiogram import types
# def main_menu_keyboard():
#     builder = ReplyKeyboardBuilder()

#     builder.add(types.KeyboardButton(text="💎 Drop a Code"))
#     builder.add(types.KeyboardButton(text="📦 Grab a Pack"))
#     builder.add(types.KeyboardButton(text="🏆 My Stats"))
#     builder.add(types.KeyboardButton(text="📍 Find Omega"))
#     builder.add(types.KeyboardButton(text="❓ The Formula"))
#     builder.add(types.KeyboardButton(text="🎧 Vibe Check"))
#     builder.add(types.KeyboardButton(text="⚡️ Get Fueled"))   

#     builder.adjust(2)
#     return builder.as_markup(resize_keyboard=True)

def get_main_menu():
    builder = ReplyKeyboardBuilder()
    buttons = [
        "💎 Drop a Code", "📦 Grab a Pack", 
        "🏆 My Stats", "📍 Find Omega", 
        "❓ The Formula", "🎧 Vibe Check",
        "⚡️ Get Fueled"
    ]
    for bt in buttons:
        builder.add(KeyboardButton(text=bt))
    builder.adjust(2)
    return builder.as_markup(resize_keyboard=True)

def get_cancel_menu() -> ReplyKeyboardMarkup:
    builder = ReplyKeyboardBuilder()
    builder.add(KeyboardButton(text="🔙 Back to Menu"))
    return builder.as_markup(resize_keyboard=True)

def get_phone_menu():
    kb = [
        [KeyboardButton(text="📱 Share Phone Number", request_contact=True)],
        [KeyboardButton(text="🔙 Back to Menu")]
    ]
    return ReplyKeyboardMarkup(
        keyboard=kb,
        resize_keyboard=True,
        one_time_keyboard=True
    )

def get_confirmation_menu():
    kb = [
        [KeyboardButton(text="🚚 Confirm Order")],
        [KeyboardButton(text="🔙 Back to Menu")]
    ]
    return ReplyKeyboardMarkup(
        keyboard=kb,
        resize_keyboard=True,
        one_time_keyboard=True
    )

