from aiogram.fsm.state import StatesGroup, State

class OrderStates(StatesGroup):
    waiting_for_name = State()
    waiting_for_phone = State()
    waiting_for_email = State()
    waiting_for_address = State()
    confirm_order = State()
    ask_to_save_profile = State()