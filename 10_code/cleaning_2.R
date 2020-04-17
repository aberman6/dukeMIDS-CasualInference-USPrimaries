library(dplyr)

# Load Data
turnout <- read.csv('20_intermediate_files/turnout_v2.csv', row.names = 1, stringsAsFactors = FALSE)

treatment_group <- c('Colorado','Maine', 'Minnesota', 'Idaho', 'Washington')

# States that are excluded from the analysis
exclude_group <- c('California', 'Hawaii', 'Alaska', 'Ohio', 'Wisconsin', 
                   'Connecticut', 'Delaware','District of Columbia', 'Georgia',
                   'Indiana', 'Kansas', 'Kentucky', 'Louisiana', 'Maryland',
                   'Montana', 'Nebraska', 'New Jersey', 'New Mexico', 'New York',
                   'Pennsylvania', 'Oregon', 'Rhode Island','Wyoming', 
                   'West Virginia')

# Clean Idaho 2008 - seemd to have 2 primary days
idaho_2008_clean <- turnout %>%
    mutate(State = trimws(State)) %>%
    filter(State == 'Idaho' & Year == 2008) %>%
    mutate(Democrat = '64,026') %>%
    slice(-1)

# Removes states with strange systems and states effected by COVID
# Cleans Idaho 2008
# Creates treatment variable
# Formats columns correctly
# Removes records with NAs for outcome variable
turnout_clean <- turnout %>%
    # Exclude states
    mutate(State = trimws(State)) %>%
    # Idaho 2008 remove duplicate
    filter(State != 'Idaho' | Year != 2008) %>%
    rbind(idaho_2008_clean) %>%
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
    filter(!is.na(VEP_Counted_D))

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

# Keep only columns we care about
turnout_clean <- turnout_clean %>%
    mutate(Pop = Total) %>%
    select(State, Year, treatment, VEP_Counted_D, VEP, 
           Democrat, Type, Pop)

# Export cleaned dataset
write.csv(turnout_clean, '20_intermediate_files/turnout_v3.csv')
