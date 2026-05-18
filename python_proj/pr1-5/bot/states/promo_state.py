from aiogram.fsm.state import StatesGroup, State

class PromoStates(StatesGroup):
    waiting_for_code = State()

