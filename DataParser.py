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



class DataParser:

    def parseDataFrame(self, contents, filename):
        content_type, content_string = contents.split(',')

        decoded = base64.b64decode(content_string)
        try:
            if 'csv' in filename:
                # Assume that the user uploaded a CSV or TXT file
                df = pd.read_csv(
                    io.StringIO(decoded.decode('utf-8')))
            elif 'xls' in filename:
                # Assume that the user uploaded an excel file
                df = pd.read_excel(io.BytesIO(decoded))
            elif 'txt' or 'tsv' in filename:
                # Assume that the user upl, delimiter = r'\s+'oaded an excel file
                df = pd.read_csv(
                    io.StringIO(decoded.decode('utf-8')), delimiter=r'\s+')
        except Exception as e:
            print(e)
            return html.Div([
                'There was an error processing this file.'
            ])

        return df

