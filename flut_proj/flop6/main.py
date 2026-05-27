import sqlite3

conn = sqlite3.connect('db.sqlite3')
with open('main.sql', 'r', encoding='utf-8') as f:
    conn.executescript(f.read())
conn.commit()
conn.close()
print("Міграція завершена")