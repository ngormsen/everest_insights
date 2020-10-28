from utils import get_month, get_date
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

class DataModel:
    trans_log_raw = None
    trans_log_clean = None
    cohort_data = None

    def __init__(self, transaction_log, cust_id, timestamp, amount_spent):
        # Preprocessing
        df = transaction_log
        df = self.preprocess_colnames(df, cust_id, timestamp, amount_spent)
        df = self.preprocess_data_types(df)
        df = self.add_acquisition_timestamp(df)

        self.trans_log_raw = transaction_log
        self.trans_log_clean = df

    def preprocess_colnames(self, trans_log, cust_id, timestamp, amount_spent):
        """
        Select and rename the columns that are relevant for building
        cohorts from a transaction log. This should be done manually by the user.
        """
        trans_log.rename(
            columns={
                cust_id: "cust_id",
                timestamp: "timestamp",
                amount_spent: "amount_spent"
            },
            inplace=True
        )

        # Drop all other Variables
        trans_log = trans_log[["cust_id", "timestamp", "amount_spent"]]
        return trans_log

    def preprocess_data_types(self, trans_log):
        """
        Converts columns of the transaction log into correct data types.
        """
        trans_log.loc[:, "timestamp"] = pd.to_datetime(trans_log["timestamp"])
        return trans_log

    def add_acquisition_timestamp(self, trans_log):
        """
        Adds new column for the acquisition date. The acquisition date
        is the date of the first purchase for each customer.
        """
        acq_timestamps = (trans_log
            .groupby("cust_id")["timestamp"]
            .min()
            .reset_index()
            .rename(columns={"timestamp" : "acq_timestamp"}))

        trans_log = (trans_log
            .set_index("cust_id")
            .join(acq_timestamps.set_index("cust_id")))
        return trans_log

    def compute_cohort_ages(self, trans_log, acq_timestamp, order_timestamp, by):
        """
        Computes the ages for each cohort given a (cohort) transaction log.
        
        Args
            acq_timestamp: String: Name of the column containing acquisition period
            order_timestamp: String: Name of the column containing order period
            by: String: Ages in terms of "month" or "year"
        """
        if by == "month":
            order_years, order_months, _ = get_date(trans_log, order_timestamp)
            acq_years, acq_months, _ = get_date(trans_log, acq_timestamp)
            trans_log["age"] = (order_years - acq_years) * 12 + (order_months - acq_months)
        self.trans_log_clean = trans_log
        return trans_log

    def aggregate_translog_by_cohort(self, trans_log, dep_var):
        """
        Aggregates a customer-level transaction log into cohort-based data.

        Args
            dep_var: String: One of "count" or "amount_spent"
        """
        if dep_var == "amount_spent":
            cohort_trans_log = (trans_log
                .groupby(["acq_timestamp", "timestamp"])["amount_spent"]
                .sum()
                .reset_index()
                .rename(columns={"acq_timestamp": "cohort"}))
        return cohort_trans_log

    def get_cohort_table(self, cohort_trans_log, dep_var="amount_spent"):
        cohort_table = cohort_trans_log.pivot_table(
            index="cohort",
            columns="timestamp",
            values=dep_var 
        )
        return cohort_table

    def plot_linechart(self, cohort_trans_log, dep_var, view="cohort-age"):
        """
        Args
            view: String: One of "cohort-age" or "cohort-period"
        """
        if view == "cohort-age":
            plt = px.line(
                cohort_trans_log,
                x="age",
                y=dep_var,
                color="cohort"
            )
            return plt
        elif view == "cohort-period":
            plt = px.line(
                cohort_trans_log,
                x="timestamp",
                y=dep_var,
                color="cohort"
            )
            return plt
        else:
            raise ValueError("Unknown view. Choose cohort-age or cohort-period")

    def plot_c3(self, cohort_trans_log, dep_var="amount_spent"):

        # Convert datetime to string
        df = cohort_trans_log.copy()
        df["timestamp"] = df["timestamp"].dt.strftime("%Y-%m")
        df["cohort"] = df["cohort"].dt.strftime("%Y-%m")

        plt_layout = go.Layout(
            title = "Customer Cohort Chart",
            xaxis_title="Period",
            yaxis_title="Revenue",
            xaxis = {'showgrid': False,
                    'zeroline': True,
                    'linecolor': 'rgb(100, 100, 100)',
                    'ticks': 'outside'},
            yaxis = {'showgrid': False,
                    'zeroline': True,
                    'linecolor': 'rgb(100, 100, 100)',
                    'ticks': 'outside'
                    },
            plot_bgcolor = 'rgba(0, 0, 0, 0)'
        )

        plt = go.Figure(layout = plt_layout)
        for cohort in df.cohort.unique():
            plt.add_trace(go.Scatter(
                name=cohort,
                x=df[df["cohort"] == cohort]["timestamp"],
                y=df[df["cohort"] == cohort]["amount_spent"],
                stackgroup='one',
                mode='none'
            ))
        return plt

    def get_translog(self):
        return self.trans_log_clean
        

# ## TESTING
# df = pd.read_csv("data/retail_relay.csv")
# preprocessor = DataModel(
#     transaction_log=df,
#     cust_id="userId",
#     timestamp="orderDate",
#     amount_spent="totalCharges"
# )
# translog = preprocessor.get_translog()
# translog_by_cohort = preprocessor.aggregate_translog_by_cohort(
#     trans_log=translog,
#     dep_var="amount_spent"
# )
# translog_by_cohort = preprocessor.compute_cohort_ages(
#     trans_log=translog_by_cohort,
#     acq_timestamp="cohort",
#     order_timestamp="timestamp",
#     by="month"
# )
# # plt = preprocessor.plot_linechart(
# #     cohort_trans_log=translog_by_cohort,
# #     dep_var="amount_spent",
# #     view="cohort-age"
# # )
# plt = preprocessor.plot_c3(
#     cohort_trans_log=translog_by_cohort,
#     dep_var="amount_spent"
# )


    
