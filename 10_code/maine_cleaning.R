library(dplyr)
library(tidyr)

# Load Data
raw <- read.csv('20_intermediate_files/turnout_num_Maine.csv', row.names = 1, 
                stringsAsFactors = FALSE)

# Clean data
maine <- raw %>%
    # Create percentage features
    mutate(Turnout = Turnout_number/Total_pop,
           WhitePerc = White/Total_pop,
           BlackPerc = Black/Total_pop,
           MalePerc = Male_pop/Total_pop,
           pop20.25Perc = pop.25/Total_pop,
           pop25.35Perc = pop.35/Total_pop,
           pop35.45Perc = pop.45/Total_pop,
           pop45.55Perc = pop.55/Total_pop,
           pop55.65Perc = pop.65/Total_pop,
           pop65..Perc = (pop.65+pop.75+pop.85+pop..85)/Total_pop) %>%
    # Wide dataset
    pivot_wider(id_cols = County,  names_from = Year, 
                values_from = c("Turnout", "WhitePerc", "BlackPerc",
                                "MalePerc", "pop20.25Perc", "pop25.35Perc",
                                "pop35.45Perc", "pop45.55Perc", "pop55.65Perc",
                                "pop65..Perc",'Total_pop')) %>%
    # Calculate difference in turnout
    mutate(Turnout_change = Turnout_2020-Turnout_2016) %>%
    select(County, Turnout_change, WhitePerc_2020, BlackPerc_2020,
           MalePerc_2020, pop20.25Perc_2020, pop25.35Perc_2020, 
           pop35.45Perc_2020, pop45.55Perc_2020, pop55.65Perc_2020, 
           pop65..Perc_2020, Total_pop_2020)

write.csv(maine, '20_intermediate_files/turnout_num_Maine_v2.csv')




