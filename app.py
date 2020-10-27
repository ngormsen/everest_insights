# -*- coding: utf-8 -*-

# Run this app with `python app.py` and
# visit http://127.0.0.1:8050/ in your web browser.
import base64
import datetime
import io

import dash
from dash.dependencies import Input, Output, State
import dash_core_components as dcc
import dash_html_components as html
import dash_table
import plotly.graph_objects as go
import pandas as pd

from utils import *
from DataParser import DataParser

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
server = app.server

# # LOAD DATA
# transaction_log_raw = pd.read_csv('data/retail_relay.csv')
# transaction_log_clean = preprocess_transaction_log(
#     df=transaction_log_raw,
#     customer_id="userId",
#     timestamp="orderDate",
#     revenue="totalCharges"
# )

# # BUILD COHORT TABLE 
# cohort_table = cohort_based_revenue(transaction_log_clean, relative_to_acquisition_year=False)
# plt = plot_cohort_table(cohort_table)


# APP LAYOUT
app.layout = html.Div([
        html.H1("Everest Insights"),
        dcc.Upload(
        id='upload-data',
        children=html.Div([
            'Drag and Drop or ',
            html.A('Select Files')
        ]),
        style={
            'width': '100%',
            'height': '60px',
            'lineHeight': '60px',
            'borderWidth': '1px',
            'borderStyle': 'dashed',
            'borderRadius': '5px',
            'textAlign': 'center',
            'margin': '10px'
        },
        # Allow multiple files to be uploaded
        multiple=True
    ),
    # dcc.Graph(
    #     id='cohort-table',
    #     figure=plt
    # ),
    html.Div(id="output-data-graph"),
    html.Div(id='output-data-upload')
])


# CALLBACKS
dataParser = DataParser()

@app.callback(Output('output-data-graph', 'children'),
              [Input('upload-data', 'contents'),
               Input('upload-data', 'filename')])
def update_graph_output(contents, filename):
    if contents is not None:
        contents = contents[0]
        filename = filename[0]
        df = dataParser.parse_data(contents, filename)
    
        # fig = px.scatter(df, x="gdp per capita", y="life expectancy",
        # size="population", color="continent", hover_name="country",
        # log_x=True, size_max=60)
    
        transaction_log_clean = preprocess_transaction_log(
            df=df,
            customer_id="userId",
            timestamp="orderDate",
            revenue="totalCharges"
        )
        cohort_table = cohort_based_revenue(transaction_log_clean, relative_to_acquisition_year=False)
        plt = plot_cohort_table(cohort_table)

        return dcc.Graph(
            id='cohort_data',
            figure=plt
        )


@app.callback(Output('output-data-upload', 'children'),
              [Input('upload-data', 'contents')],
              [State('upload-data', 'filename'),
               State('upload-data', 'last_modified')])

def update_table_output(list_of_contents, list_of_names, list_of_dates):
    if list_of_contents is not None:
        children = [
            dataParser.parse_contents(c, n, d) for c, n, d in
            zip(list_of_contents, list_of_names, list_of_dates)]
        return children



if __name__ == '__main__':
    app.run_server(debug=True)