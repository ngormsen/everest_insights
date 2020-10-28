class CLV:
    df = None
    clvs_per_customer = None

    def __init__(self, transaction_log):
        self.df = transaction_log
    
    def compute_historical_clv_per_customer(self):
        df = self.df
        df_clvs = (df
            .groupy("cust_id")["amount_spent"]
            .sum()
            .reset_index()
        )
        self.clvs_per_customer = df_clvs

    def get_historical_clvs_per_customer(self, top_n=10):
        """Returns top n customers in terms of their historical spending"""
        df = self.clvs_per_customer
        top_n = df.nlargest(n=top_n, columns="cust_id")
        return top_n


