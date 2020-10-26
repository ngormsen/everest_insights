import pandas as pd
import datetime as dt
import plotly.express as px

def get_month(x):
    return dt.datetime(year=x.year, month=x.month, day=1)

def get_date(df, column):
    year = df[column].dt.year
    month = df[column].dt.month
    day = df[column].dt.day
    return year, month, day
    
def preprocess_transaction_log(df, customer_id, timestamp, revenue):
    # Renaming Variables
    df.rename(
        columns={
            customer_id: "customer_id",
            timestamp: "timestamp",
            revenue: "revenue"
        },
        inplace=True
    )

    # Drop all other variables
    df = df[["customer_id", "timestamp", "revenue"]]

    df.loc[:, "timestamp"] = pd.to_datetime(df["timestamp"])
    df['order_month'] = df["timestamp"].apply(get_month)
    df['cohort_month'] = df.groupby("customer_id")['order_month'].transform('min')

    order_year, order_month, _ = get_date(df, 'order_month')
    cohort_year, cohort_month, _ = get_date(df, 'cohort_month')

    year_diff = order_year - cohort_year
    month_diff = order_month - cohort_month

    df['cohort_id'] = year_diff * 12 + month_diff + 1
    return df

def cohort_based_revenue(df, relative_to_acquisition_year=False):
    cohort_data = df.groupby(["cohort_id", "order_month"])["revenue"].sum().reset_index()
    cohort_table = cohort_data.pivot_table(
        index = 'cohort_id',
        columns = 'order_month',
        values = 'revenue'
    )

    # TODO
    # if relative_to_acquisition_year:
        # acquisition_year_values = cohort_table.iloc[:, 0]
        # cohort_table = cohort_table.divide(acquisition_year_values, axis = 0)
        # cohort_table.round(3)

    return cohort_table

def plot_cohort_table(cohort_table):
    plt = px.imshow(cohort_table, color_continuous_scale='RdBu_r')
    return plt

    

# ## TESTING
# df = pd.read_csv("data/retail_relay.csv")
# df = preprocess_transaction_log(df, customer_id="userId", timestamp="orderDate", revenue="totalCharges")
# cohort_table = cohort_based_revenue(df)

