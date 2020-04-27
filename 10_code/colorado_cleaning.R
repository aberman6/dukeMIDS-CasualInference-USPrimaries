library(dplyr)
library(tidyr)

# Load Data
colorado_2020 <- read.csv('00_source_data/2020_Colorado_PrimaryTurnoutCountyLevel_Long.csv')
colorado_2016 <- read.csv('00_source_data/2016_Colorado_PrimaryTurnoutCountyLevel.csv')
colorado_demo <- read.csv('00_source_data/2019_Colorado_Demographics.csv')

#-- Clean and widen 2020 Colorado Dataset ----------------------------------------
# All 2020democratic candidates
candidates <- c('Andrew Yang', 'Bernie Sanders', 'Cory Booker', 'Deval Patrick',
               'Elizabeth Warren', 'Joseph R. Biden', 'Marianne Williamson', 
               'Michael R. Bloomberg', 'Rita Krichevsky', 'Robby Wells',
               'Roque \"Rocky\" De La Fuente III', 'Tom Steyer', 'Tulsi Gabbard')

my_num <- function(x){
    ### Removes commas in numbers and changes to numeric format
    return(as.numeric(gsub(',','',x)))
}

colorado_2020 <- colorado_2020 %>%
    # Only interested in Democratic Primary
    filter(Party=='Democratic Party') %>%
    # Make wide dataset
    spread(Candidate, Votes.Percentage) %>%
    # Select only voter turnout numbers
    filter(County != '') %>%
    select(c('County', candidates)) %>%
    # Calculate totaly county turnout %>%
    mutate_at(candidates, my_num) %>%
    mutate(turnout_2020 = rowSums(.[,-1])) %>%
    select(County, turnout_2020)

# Export cleaned colorado 2020 dataset
#write.csv(colorado_2020, '20_intermediate_files/turnout_colorado_2020.csv')

#-- Clean 2016 dataset ---------------------------------------------------------

colorado_2016 <- colorado_2016 %>%
    mutate(turnout_2016 = my_num(Ballots.Cast),
           registered_voters = my_num(Total.Voters)) %>%
    filter(County != '') %>%
    select(County, turnout_2016, registered_voters)

# Export cleaned colorado 2016 dataset
#write.csv(colorado_2016, '20_intermediate_files/turnout_colorado_2016.csv')


#-- Clean demo dataset ---------------------------------------------

colorado_demo <- colorado_demo %>%
    mutate(County = toupper(gsub(' County', '', County))) %>%
    mutate_at(names(colorado_demo)[-1], my_num)


#-- Combine 2020 and 2016 dataset ---------------------------------------------

colorado <- colorado_2020 %>%
    # Merge 2016, 2020 and demo data
    mutate(County = toupper(County)) %>%
    left_join(colorado_2016, by="County") %>% 
    left_join(colorado_demo, by="County") %>%
    # Turn numbers to % of voter eligible age
    mutate(turnout_2020 = turnout_2020/pop18.85,
           turnout_2016 = turnout_2016/pop18.85,
           registered_voters = registered_voters/pop18.85,
           White = White/pop18.85,
           Black = Black/pop18.85,
           Hispanic = Hispanic/pop18.85,
           pop18.25 = pop18.25/pop18.85,
           pop18.30 = pop18.30/pop18.85,
           pop65.85 = pop65.85/pop18.85,
           delta = turnout_2020-turnout_2016) # turnout

# Export cleaned colorado dataset
write.csv(colorado, '20_intermediate_files/turnout_colorado.csv')






library(ggplot2)
ggplot(colorado) + 
    geom_point(mapping=aes(x=pop18.30, y=delta))
    
