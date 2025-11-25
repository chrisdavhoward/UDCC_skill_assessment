import pandas as pd
import sqlite3

excel_file = pd.ExcelFile('data/DataWarehouseAnalyst_Dataset.xlsx')
conn = sqlite3.connect('data/assessment.db')

# Convert each sheet to a table
for sheet_name in excel_file.sheet_names:
    df = pd.read_excel(excel_file, sheet_name=sheet_name)
    # Use sheet name as table name (cleaned up)
    table_name = sheet_name.lower().replace(' ', '_')
    df.to_sql(table_name, conn, if_exists='replace', index=False)
    print(f"Created table: {table_name}")

conn.close()