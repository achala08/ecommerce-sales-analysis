

from sqlalchemy import create_engine 
import pandas as pd

engine = create_engine("postgresql+psycopg2://postgres:achalapostgresql@localhost:5432/ecommerce_db")
df = pd.read_sql("SELECT * FROM sales_clean;", engine)
df['invoicedate'] = pd.to_datetime(df['invoicedate'])




print(df.head())
print(df.dtypes)

