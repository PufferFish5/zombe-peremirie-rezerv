from aiogram.utils.keyboard import InlineKeyboardBuilder
from aiogram.types import InlineKeyboardMarkup

def get_series_menu():
    builder = InlineKeyboardBuilder()
    series = {
        "tropical": "🌕 Night City Calling",
        "noir": "🔎 When City Sleeps",
        "thug": "💰 Midnight SWAG",
        "og": "🏅 OG Collection"
    }
    for key, value in series.items():
        builder.button(text=value, callback_data=f"series_{key}")
    builder.adjust(2)
    return builder.as_markup()

def get_drinks_menu(drinks_list):
    builder = InlineKeyboardBuilder()
    # drinks_data = {
    #     "tropical": {
    #         "tropical_burst": "🌴 Tropical Burst",
    #         "electric_berry": "🫐 Electric Berry",
    #         "cooling_watermelon": "🍉 Cooling Watermelon",
    #         "neon_mango": "🥭 Neon Mango"
    #     },
    #     "noir": {
    #         "black_coffee": "☕️ Black Coffe",
    #         "mysterious_blackberry": "💫 Mysterious Blackberry",
    #         "deep_cherry": "🍒 Deep Cherry",
    #         "sharp_lemon": "🍋 Sharp Lemon"
    #     },
    #     "thug": {
    #         "bold_grape": "🔥 Bold Grape",
    #         "gold_citrus": "✨ Gold Citrus",
    #         "rich_pineapple": "🍍 Rich Pineapple",
    #         "hustling_lime": "🍋‍🟩 Hustling Lime"
    #     },
    #     "og": {
    #         "miyagoda_rofls": "👑 Miyagoda Rofls",
    #     }
    # }

    # current_series_drinks = drinks_data.get(series_type, {})

    for drink in drinks_list:
        builder.button(
            text=f"{drink.name} — {drink.price} UAH",
            callback_data=f"drink_{drink.id}"
        )

    builder.button(text="🔙 Back to Series", callback_data="back_to_series")
    builder.adjust(1) 
    return builder.as_markup()

def get_location_menu():
    builder = InlineKeyboardBuilder()
    url = "https://maps.app.goo.gl/VgsApRNuS8S5q5VC6"
    builder.button(text="Open in Google Maps 🗺", url=url)
    return builder.as_markup()

def get_vibe_menu():
    builder = InlineKeyboardBuilder()
    builder.button(text="🎧 Spotify Playlist", url="https://open.spotify.com/playlist/0Y1VOLEpWFulGWhup9wsss?si=c1d40d324adf4529")
    builder.button(text="☁️ SoundCloud Mix", url="https://soundcloud.com/")
    builder.button(text="📺 YouTube Music", url="https://music.youtube.com/")
    builder.adjust(1)
    return builder.as_markup()

def get_profile_choise_menu():
    builder = InlineKeyboardBuilder()
    builder.button(text="✅ Use saved profile", callback_data="use_saved_true")
    builder.button(text="✍️ Edit details", callback_data="use_saved_false")
    return builder.as_markup()

def get_save_profile_menu():
    builder = InlineKeyboardBuilder()
    builder.button(text="Yes, save it.", callback_data="save_yes")
    builder.button(text="No, just this once", callback_data="save_no")
    return builder.as_markup()