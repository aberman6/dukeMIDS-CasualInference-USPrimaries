library(dplyr)
library(tidyr)

# Load Data
colorado_2020 <- read.csv('00_source_data/2020_Colorado_PrimaryTurnoutCountyLevel_Long.csv')
colorado_2016 <- read.csv('00_source_data/2016_Colorado_PrimaryTurnoutCountyLevel.csv')

#-- Clean and widen 2020 Colorado Dataset ----------------------------------------
# All 2020democratic candidates
candidates <- c('Andrew Yang', 'Bernie Sanders', 'Cory Booker', 'Deval Patrick',
               'Elizabeth Warren', 'Joseph R. Biden', 'Marianne Williamson', 
               'Michael R. Bloomberg', 'Rita Krichevsky', 'Robby Wells',
               'Roque \"Rocky\" De La Fuente III', 'Tom Steyer', 'Tulsi Gabbard')

votes <- function(x){
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
    mutate_at(candidates, votes) %>%
    mutate(turnout_2020 = rowSums(.[,-1])) %>%
    select(County, turnout_2020)

# Export cleaned colorado 2020 dataset
#write.csv(colorado_2020, '20_intermediate_files/turnout_colorado_2020.csv')

#-- Clean 2016 dataset ---------------------------------------------------------

colorado_2016 <- colorado_2016 %>%
    mutate(turnout_2016 = votes(Ballots.Cast),
           total_voters = votes(Total.Voters)) %>%
    filter(County != '') %>%
    select(County, turnout_2016, total_voters)

# Export cleaned colorado 2016 dataset
#write.csv(colorado_2016, '20_intermediate_files/turnout_colorado_2016.csv')

#-- Combine 2020 and 2016 dataset ---------------------------------------------

colorado <- colorado_2020 %>%
    mutate(County = toupper(County)) %>%
    left_join(colorado_2016, by="County") %>%
    mutate(turnout_delta = turnout_2020 - turnout_2016,
           turnout_deltaPerc = turnout_delta/total_voters)

# Export cleaned colorado dataset
write.csv(colorado, '20_intermediate_files/turnout_colorado.csv')
    
