from utils import get_month, get_date
import pandas as pd

class DataModel:
    trans_log_raw = None
    trans_log_clean = None
    cohort_data = None

    def __init__(self, transaction_log):
        self.trans_log_raw = transaction_log

    def preprocess(self, cust_id, timestamp, amount_spent):
        self.rename_columns(cust_id, timestamp, amount_spent)
        self.convert_data_types()

    def get_cohort_data(self, dep_var="amount_spent", by_period="month"):
        trans_log = self.trans_log_clean
        trans_log = self.add_cohort_columns(trans_log=trans_log, period=by_period)
        cohort_data = self.build_cohort_data(trans_log, dep_var=dep_var)
        self.cohort_data = cohort_data
        return cohort_data

    def get_cohort_table(self):
        cohort_table = self.cohort_data.pivot_table(
            index = "cohort_id",
            columns = "order_month",
            values= "amount_spent"
        )
        return cohort_table
        
    def rename_columns(self, cust_id, timestamp, amount_spent):
        """
        Select and rename the columns that are relevant for building
        cohorts from a transaction log. This should be done manually by the user.
        """
        df = self.trans_log_raw

        df.rename(
            columns={
                cust_id: "cust_id",
                timestamp: "timestamp",
                amount_spent: "amount_spent"
            },
            inplace=True
        )

        # Drop all other Variables
        df = df[["cust_id", "timestamp", "amount_spent"]]
        self.trans_log_clean = df

    def convert_data_types(self):
        """
        Converts the columns of the transaction log into correct data types.
        """
        df = self.trans_log_clean
        df.loc[:, "timestamp"] = pd.to_datetime(df["timestamp"])
        self.trans_log_clean = df

    def add_cohort_columns(self, trans_log, period="month"):
        """
        Builds cohorts based on the period chosen.

        Args
            period: String: One of "month", "year"

        Note: Currently works only for month
        """
        df = trans_log
        df["order_month"] = df["timestamp"].apply(get_month)
        df["cohort_month"] = df.groupby("cust_id")["order_month"].transform("min")

        order_year, order_month, _ = get_date(df, 'order_month')
        cohort_year, cohort_month, _ = get_date(df, 'cohort_month')

        year_diff = order_year - cohort_year
        month_diff = order_month - cohort_month

        df['cohort_id'] = year_diff * 12 + month_diff + 1
        return df

    def build_cohort_data(self, trans_log, dep_var):
        """
        Builds a Cohort Table from a (cleaned) Transaction Log that already
        contains columns created by `add_cohort_columns()`.

        Args:
            dep_var: String: One of "count", "amount_spent"
        """
        df = trans_log

        if dep_var == "count":
            # Counts the number of customers per cohort & month
            cohort_data = df.groupby(["cohort_id", "order_month"])["cust_id"].agg("count").reset_index()

        if dep_var == "amount_spent":
            cohort_data = df.groupby(["cohort_id", "order_month"])["amount_spent"].sum().reset_index()

        return cohort_data

    def get_cohort_table(self):
        cohort_table = self.cohort_data.pivot_table(
            index = "cohort_id",
            columns = "order_month",
            values= "amount_spent"
        )
        return cohort_table

    def get_trans_log(self):
        return self.trans_log_clean

# ## EXAMPLE

# trans_log = pd.read_csv("data/retail_relay.csv")
# data = DataModel(transaction_log=trans_log)

# # Data Cleaning
# data.preprocess(
#     cust_id="userId",
#     timestamp="orderDate",
#     amount_spent="totalCharges"
# )

# cohort_data = data.get_cohort_data(dep_var="amount_spent", by_period="month")
# cohort_table = data.get_cohort_table()
    
# print(cohort_data)
# print(cohort_table)





    
