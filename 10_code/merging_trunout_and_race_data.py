#!/usr/bin/env python
# coding: utf-8

# ### Read turnout data

# In[1]:


import pandas as pd


# In[2]:


get_ipython().system('ls ../00_source_data')


# In[3]:


get_ipython().system('ls ../20_intermediate_files')


# In[4]:


df_to = pd.read_csv("../20_intermediate_files/turnout.csv")


# In[5]:


df_to.head()


# ### Read state population data by race from 2008 to 2016
# * dataset from https://www.kff.org/other/state-indicator/distribution-by-raceethnicity/?dataView=1&currentTimeframe=10&sortModel=%7B%22colId%22:%22Location%22,%22sort%22:%22asc%22%7D based on the Census Bureau's American Community Survey, 2008-2018.

# In[6]:


df_race_2008 = pd.read_csv("../00_source_data/2008_USStates_by_Race.csv", skiprows = 2)
df_race_2008['Year'] = 2008
df_race_2008.rename(columns={'Location':'State'}, inplace=True)
df_race_2008.head()


# In[7]:


df_race_2012 = pd.read_csv("../00_source_data/2012_USStates_by_Race.csv", skiprows = 2)
df_race_2012['Year'] = 2012
df_race_2012.rename(columns={'Location':'State'}, inplace=True)
df_race_2012.head()


# In[8]:


df_race_2016 = pd.read_csv("../00_source_data/2016_USStates_by_Race.csv", skiprows = 2)
df_race_2016['Year'] = 2016
df_race_2016.rename(columns={'Location':'State'}, inplace=True)
df_race_2016.head()


# ### Read state population data by race of 2020
# * this data set from another website, https://worldpopulationreview.com/states/states-by-race/, that is based on an estimate preformed in 2017 (https://www.census.gov/newsroom/press-releases/2017/estimates-idaho.html)
# * so, this format is slightly different from those of 2008 - 2016
# * especially, this dataset does not have Hispanic categories. It might be assigned to other races, such as white, black, and other races.

# In[9]:


3317453+1293186+25576+64609+2182+70055+91619


# In[10]:


df_race_2016.columns


# In[11]:


df_race_2020 = pd.read_csv("../00_source_data/2020_USStates_by_Race.csv")
df_race_2020['Year'] = 2020
df_race_2020.rename(
    columns={'Native':'American Indian/Alaska Native',
             'Islander':'Native Hawaiian/Other Pacific Islander', 'TwoOrMoreRaces': 'Two Or More Races'}, inplace=True)
df_race_2020.head()


# ### Merge datasets of state population by race from 2008 to 2020

# In[12]:


df_race_2008_2020 = pd.concat([df_race_2008, df_race_2012, df_race_2016, df_race_2020], sort = False)
df_race_2008_2020.head()


# In[13]:


df_race_2008_2020.tail()


# ### Merge turnout dataset and state population data by race from 2008 to 2020

# In[14]:


turnout_v2 = pd.merge(df_to, df_race_2008_2020, how = 'left', on = ['State', 'Year'])


# In[15]:


turnout_v2.drop(columns=['Unnamed: 0'], inplace=True)
turnout_v2


# ### Write final merged data as turnout_v2.csv

# In[16]:


turnout_v2.to_csv("../20_intermediate_files/turnout_v2.csv")


# In[17]:


get_ipython().system('ls ../20_intermediate_files/turnout_v2.csv')


# In[18]:


get_ipython().system('cat ../20_intermediate_files/turnout_v2.csv')

