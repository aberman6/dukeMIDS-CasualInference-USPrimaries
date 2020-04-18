library(dplyr)
library(tidyr)

# Load Data
turnout <- read.csv('20_intermediate_files/turnout_v2.csv', row.names = 1, stringsAsFactors = FALSE)
election_format <- read.csv('00_source_data/electiontype.csv')

# Long election_format dataset
election_format <- election_format %>%
    mutate(State = trimws(State)) %>%
    gather(key = 'Year', value = 'Format', -State) %>%
    mutate(Year = as.numeric(gsub('X','', Year)))

# States that has caucuses in 2008-2016, and had a primary in 2020
treatment_group <- c('Colorado','Maine', 'Minnesota', 'Washington')

# States that are excluded from the analysis
# States with unique formats
# States that switched back and forth
# States effected by COVID
exclude_group <- c('California', 'Hawaii', 'Alaska', 'Ohio', 'Wisconsin', 
                   'Connecticut', 'Delaware','District of Columbia', 'Georgia',
                   'Idaho', 'Indiana', 'Kansas', 'Kentucky', 'Louisiana', 
                   'Maryland', 'Montana', 'Nebraska', 'New Jersey', 'New Mexico', 
                   'New York', 'Pennsylvania', 'Oregon', 'Rhode Island',
                   'Wyoming', 'West Virginia')

# Removes states with strange systems and states effected by COVID
# Creates treatment variable
# Formats columns correctly
# Removes records with NAs for outcome variable
# Corrects for incorrect election type variable
turnout_clean <- turnout %>%
    # Exclude states
    mutate(State = trimws(State)) %>%
    filter(!State %in% exclude_group) %>%
    # Create numeric treatment variable
    # treatment == 1 : State that switched from from caucus to primary in 2020
    # treatment == 0 : State that maintained format in 2020
    mutate(treatment = ifelse(State %in% treatment_group, 1, 0)) %>%
    # Ensure numeric type
    mutate(VEP = as.numeric(gsub(',', '', VEP)),
           Cast = as.numeric(gsub(',', '', Cast)),
           VAP = as.numeric(gsub(',', '', VAP)),
           Democrat = as.numeric(gsub(',', '', Democrat)),
           Republican = as.numeric(gsub(',', '', Republican)),
           Counted = as.numeric(gsub(',', '', Counted)),
           VEP_Counted = as.numeric(gsub('%', '', VEP_Counted))) %>%
    # Democratic votes only drop NaNs 
    mutate(VEP_Counted_D = Democrat/VEP) %>%
    filter(!is.na(VEP_Counted_D)) %>%
    # Correct for election type errors
    left_join(election_format, by = c("State", "Year"))  %>%
    mutate(Type = Format, Pop = Total) %>%
    # Remove extraneous columns
    select(State, Year, treatment, VEP_Counted_D, VEP, 
           Democrat, Republican, Type, Pop, White, Black, Hispanic)

# Now that we have the first pass of cleaning, what states have complete data?
# States with complete data from 2018, 2016, & 2020
# 2012 was an Obama reelection year
complete_states <- turnout_clean %>%
    filter(Year != 2012) %>%
    group_by(State) %>%
    summarise(count = n()) %>%
    filter(count ==  3) %>%
    pull(State)
complete_states

# Remove states without records for all years of analysis
turnout_clean <- turnout_clean %>%
    filter(Year != 2012) %>%
    filter(State %in% complete_states)

# Export cleaned dataset
write.csv(turnout_clean, '20_intermediate_files/turnout_v3.csv')
