import re
from aiogram import Router, types, F
from aiogram.fsm.context import FSMContext
from bot.states.order_state import OrderStates
import bot.databases.requests as rq
from bot.keyboards.reply import get_main_menu, get_cancel_menu, get_phone_menu, get_confirmation_menu
from bot.keyboards.inline import get_profile_choise_menu, get_save_profile_menu

router = Router()

@router.message(F.text == "🔙 Back to Menu")
async def cancel_order(message: types.Message, state: FSMContext):
    await state.clear()
    await message.answer(
        "Order cancelled. You can retutn at any time.",
        reply_markup=get_main_menu()
    )

@router.callback_query(F.data.startswith("drink_"))
async def start_order(callback: types.CallbackQuery, state: FSMContext):
    drink_id = callback.data.split("_")[1]
    drink = await rq.get_drink_by_id(drink_id)
    if drink:
        await state.update_data(
            chosen_drink_id=drink_id,
            drink_name=drink.name,
            drink_price=drink.price
        )
    user = await rq.get_user_stats(callback.from_user.id)
    if user and user.name and user.phone:
        await state.update_data(
            name=user.name,
            phone=user.phone,
            email=user.email
        )
        await state.set_state(OrderStates.confirm_order)
        
        await callback.message.answer(
            f"Welcome back, {user.name}!\n"
            f"I found your profile. Use it for this order of **{drink.name}**?",
            reply_markup=get_profile_choise_menu()
        )
        await callback.answer()
        return
    
    await state.set_state(OrderStates.waiting_for_name)
    await callback.message.answer(
        "⚡️ Great choice! Let's get your fuel ready.\n"
        "First, what's your name?",
        reply_markup=get_cancel_menu(),
        parse_mode="Markdown"
    )
    await callback.answer()

@router.callback_query(F.data == "use_saved_true")
async def use_saved(callback: types.CallbackQuery, state: FSMContext):
    await state.update_data(is_profile_saved=True)
    await state.set_state(OrderStates.waiting_for_address)
    await callback.message.edit_text("Perfect! Just tell me where to ship today?", parse_mode="Markdown")
    await callback.answer()

@router.callback_query(F.data == "use_saved_false")
async def edit_details(callback: types.CallbackQuery, state: FSMContext):
    await state.set_state(OrderStates.waiting_for_name)
    await callback.message.edit_text("No problem. Let's start fresh.\nWhat's your name?", parse_mode="Markdown")
    await callback.answer()


@router.message(OrderStates.waiting_for_name)
async def process_name(message: types.Message, state: FSMContext):
    await state.update_data(name=message.text)
    await state.set_state(OrderStates.waiting_for_phone)
    await message.answer("Got it! Now, please share your phone number so we can confirm the delivery.", reply_markup=get_phone_menu())

@router.message(OrderStates.waiting_for_phone)
async def process_phone(message: types.Message, state: FSMContext):
    if message.contact:
        phone = message.contact.phone_number
    else:
        phone = message.text
        if not (10 <= len(phone.replace('+', '')) <= 13):
            await message.answer("That doesn't look like a phone number. Please try again or use the button!")
            return
    await state.update_data(phone=phone)
    await state.set_state(OrderStates.waiting_for_email)
    
    await message.answer(
        "Phone number received. Now, please share your email.",
        reply_markup=get_cancel_menu()
    )

@router.message(OrderStates.waiting_for_email)
async def process_email(message: types.Message, state: FSMContext):
    email=message.text.strip()
    EMAIL_REGEX = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    if not re.match(EMAIL_REGEX, email):
        await message.answer("Wait! That doesn't look like a valid email. Please try again.")
        return
    await state.update_data(email=email)
    await state.set_state(OrderStates.waiting_for_address)
    await message.answer(
        "Perfect. Now, where should we ship your fuel? (City and Post Office)",
        reply_markup=get_cancel_menu()
    )
    
@router.message(OrderStates.waiting_for_address)
async def process_address(message: types.Message, state: FSMContext):
    await state.update_data(address=message.text)
    data = await state.get_data()
    summary = (
        "📊 **Order Summary:**\n\n"
        f"📋 Drink ID: {data['chosen_drink_id']}\n"
        f"🥤 Drink Name: {data['drink_name']}\n"
        f"💳 Drink Price: {data['drink_price']} UAH\n"
        f"👤 Name: {data['name']}\n"
        f"📞 Phone: {data['phone']}\n"
        f"📧 Email: {data['email']}\n"
        f"📍 Shipping: {data['address']}\n\n"
        "Everything correct? Type 'Confirm Order' to finish."
#        "Seems we don't have your user data in our bases. Do you want to save"
    )
    
    await state.set_state(OrderStates.confirm_order)
    await message.answer(summary, reply_markup=get_confirmation_menu())

@router.message(OrderStates.confirm_order, F.text == "🚚 Confirm Order")
async def finish_order(message: types.Message, state: FSMContext):
    data = await state.get_data()
    is_profile_saved = data.get("is_profile_saved", False)

    order_id = await rq.add_order(
        user_tg_id = message.from_user.id,
        drink_id = int(data['chosen_drink_id']),
        address = data['address']
    )
    
    if is_profile_saved:
        await state.clear()
        await message.answer(
            "Mission accomplished! 🚀 Your Omega Energy is on the way.\n"
            "We'll contact you shortly for payment.",
            reply_markup=get_main_menu(),
            parse_mode="Markdown"
        )
    else:
        await state.set_state(OrderStates.ask_to_save_profile)
        await message.answer(
            "**Order Locked In!** 🚀 \n\n"
            "Should I save your name, phone, and email for your next **Omega Energy** reload? "
            "This will make your future orders instant.",
            reply_markup=get_save_profile_menu(),
            parse_mode="Markdown"
        )

@router.callback_query(OrderStates.ask_to_save_profile, F.data.startswith("save_"))
async def process_save_profile(callback: types.CallbackQuery, state: FSMContext):
    if callback.data == "save_yes":
        data = await state.get_data()
        await rq.update_user_profile(
            tg_id=callback.from_user.id,
            name=data['name'],
            phone=data['phone'],
            email=data['email']
        )
        await callback.message.edit_text("**Profile synced!** Next time I'll remember you.")
    else:
        await callback.message.edit_text("Done! I won't store your personal details for now.")

    await state.clear()
    await callback.message.answer("Returning to main menu...", reply_markup=get_main_menu())
    await callback.answer()