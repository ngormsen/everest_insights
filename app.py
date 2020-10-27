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
global df
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
    html.Div(id='output-data-upload'),
    html.P(id='intermediate-value', style={'display': 'none'})
])


# CALLBACKS
dataParser = DataParser()

@app.callback(Output('intermediate-value', 'children'),
              [Input('upload-data', 'contents'),
               Input('upload-data', 'filename'),
               ])
def loadDataFrame(contents, filename):

    if contents is not None:

        contents = contents[0]
        filename = filename[0]

        df = dataParser.parseDataFrame(contents, filename)

        return df.to_json(date_format='iso', orient='split')
        # fig = px.scatter(df, x="gdp per capita", y="life expectancy",
        # size="population", color="continent", hover_name="country",
        # log_x=True, size_max=60)
    


@app.callback( Output('output-data-graph', 'children'),
                [Input('intermediate-value', 'children'),
                 Input('id-column','value'),
                 Input('time-column', 'value'),
                 Input('value-column', 'value')])
def updateTableVisualisation(intermediateValue, idColumnValue, timeColumnValue, valueColumnValue ):
    if idColumnValue is not None and timeColumnValue is not None and valueColumnValue is not None:
        print(idColumnValue, timeColumnValue, valueColumnValue)
        
        if intermediateValue is not None:

            transaction_log_clean = preprocess_transaction_log(
                df=pd.read_json(intermediateValue, orient='split'),
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
              [Input('upload-data', 'contents'),
               Input('upload-data', 'filename')])
def updateTableVisualisation(contents, filename):

    if contents is not None:

        contents = contents[0]
        filename = filename[0]
        df = dataParser.parseDataFrame(contents, filename)
        columns = sorted(df)
 
        options = [{'label':column,'value':column} for column in columns]
        print(columns)

        children = [
            dcc.Dropdown(
                options=options,
                id="id-column"
            ),
            dcc.Dropdown(
                options=options,
                id="time-column"
            ),
            dcc.Dropdown(
                options=options,
                id="value-column"
            ),
            dash_table.DataTable(
                data=df.to_dict('records'),
                columns=[{'name': i, 'id': i} for i in df.columns]
            )
        ]

        return children
        





if __name__ == '__main__':
    app.run_server(debug=True)