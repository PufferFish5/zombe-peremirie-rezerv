from aiogram.fsm.state import StatesGroup, State

class CatalogStates(StatesGroup):
    series_choice = State()
    drink_choice = State()
