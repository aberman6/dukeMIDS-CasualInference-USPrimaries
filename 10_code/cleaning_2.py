#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Data processing
 - Creation of treatment variable
 - Drop NAs of VEP_Count
 - 

Created on Tue Apr 14 12:41:25 2020

@author: annaberman
"""

import pandas as pd

# Load Data
turnout = pd.read_csv('../20_intermediate_files/turnout_v2.csv', index_col=0)

# States that made the switch from caucus to primary in 2020
treatment_group = ['Colorado','Maine', 'Washington', 'Minnesota',
                  'Kansas', 'Idaho', 'Hawaii', 'Nebraska']

# Create numeric treatment variable
# treatment == 1 : State that switched from from caucus to primary in 2020
# treatment == 0 : State that maintained format in 2020
turnout['treatment'] = turnout.State.isin(treatment_group)*1

# Drop NaNs for VEP_Counted (voting eligible population couted as a vote)
turnout = turnout.dropna(subset=['VEP_Counted'])

# Make VEP_Counted numeric
turnout.VEP_Counted = [float(i[:-1]) for i in turnout.VEP_Counted]

# Final Dataset
turnout.to_csv('../20_intermediate_files/turnout_v3.csv')