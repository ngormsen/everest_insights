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
from DataModel import DataModel
from DataParser import DataParser

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
server = app.server
global df

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
        multiple=True # Allow multiple files to be uploaded
    ),
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
    

@app.callback( Output('output-data-graph', 'children'),
                [Input('intermediate-value', 'children'),
                 Input('id-column','value'),
                 Input('time-column', 'value'),
                 Input('value-column', 'value')])
def updateTableVisualisation(intermediateValue, idColumnValue, timeColumnValue, valueColumnValue ):
    if idColumnValue is not None and timeColumnValue is not None and valueColumnValue is not None:
        #print(idColumnValue, timeColumnValue, valueColumnValue)
        
        if intermediateValue is not None:
            translog_raw = pd.read_json(intermediateValue, orient='split')
            preprocessor = DataModel(
                transaction_log=translog_raw,
                cust_id=idColumnValue,
                timestamp=timeColumnValue,
                amount_spent=valueColumnValue
            )
            translog = preprocessor.get_translog()
            translog_by_cohort = preprocessor.aggregate_translog_by_cohort(
                trans_log=translog,
                dep_var="amount_spent"
            )
            translog_by_cohort = preprocessor.compute_cohort_ages(
                trans_log=translog_by_cohort,
                acq_timestamp="cohort",
                order_timestamp="timestamp",
                by="month"
            )
            plt = preprocessor.plot_linechart(
                cohort_trans_log=translog_by_cohort,
                dep_var="amount_spent",
                view="cohort-age"
            )
            return dcc.Graph(id='cohort_data', figure=plt)


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
                id="id-column",
                placeholder="Customer ID"
            ),
            dcc.Dropdown(
                options=options,
                id="time-column",
                placeholder="Timestamp of Order"
            ),
            dcc.Dropdown(
                options=options,
                id="value-column",
                placeholder="Amount Spent per Order"
            ),
            dash_table.DataTable(
                data=df[:10].to_dict('records'),
                columns=[{'name': i, 'id': i} for i in df.columns]
            )
        ]

        return children
        


if __name__ == '__main__':
    app.run_server(debug=True)