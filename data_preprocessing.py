import pandas as pd
df_1 = pd.read_csv('my_expenses_clean.csv')
df_2 = pd.read_csv('may_2026.csv', sep=';', names=['user_id', 'created', 'item', 'cat', 'price'])
df = pd.concat([df_1, df_2], ignore_index=True)
cols_to_keep = ['price', 'created', 'user_id', 'item', 'cat']
df = df[cols_to_keep]
df['price'] = pd.to_numeric(df['price'].astype(str).str.replace(',', '.'), errors='coerce')
df['cat'] = df['cat'].astype(str).str.strip().str.lower()
df['created'] = pd.to_datetime(df['created'], format='mixed')
df['created'] = df['created'].dt.date
df = df.sort_values(by='created')
print(df.tail())
df.to_csv('master_clean_expenses.csv', index=False)
print("Файл успешно обработан и сохранен как master_clean_expenses.csv")