# merge data from all years

setwd("~/Duke/2019-2020/Spring 2020/Unifying DS/unifying-data-science-final-project-primaries")

library(dplyr)
library(tidyverse)
library(zoo)

#load raw data
vote2008 <- read.csv("00_source_data/2008 Primary Elections - Turnout Rates.csv", skip=1, stringsAsFactors = FALSE)
vote2012 <- read.csv("00_source_data/2012 Primary Elections - Turnout Rates.csv", skip=1, stringsAsFactors = FALSE)
vote2016 <- read.csv("00_source_data/2016 Primary Elections - Turnout Rates.csv", skip=1, stringsAsFactors = FALSE)
vote2020 <- read.csv("00_source_data/2020 Primary Elections - Turnout Rates.csv", skip=1, stringsAsFactors = FALSE)

#rename so all have same column names
vote2008 <- vote2008 %>% rename(State = State.Territory)
vote2012 <- vote2012 %>% rename(State = State.Territory)

#clean so can merge - 2008
##add year column to keep track
vote2008['year'] <- 2008
#fill NAs with previous so each row has election date
vote2008$Date[vote2008$Date == ""] <- NA
vote2008$Date <- na.locf(vote2008$Date)

#clean so can merge - 2012
##add year column to keep track
vote2012['year'] <- 2012
#fill NAs with previous so each row has election date
vote2012$Date[vote2012$Date == ""] <- NA
vote2012$Date <- na.locf(vote2012$Date)

#clean so can merge - 2016
##add year column to keep track
vote2016['year'] <- 2016
#fill NAs with previous so each row has election date
vote2016$Date[vote2016$Date == ""] <- NA
vote2016$Date <- na.locf(vote2016$Date)

#clean so can merge - 2020
##add year column to keep track
vote2020['year'] <- 2020
#fill NAs with previous so each row has election date
vote2020$Date[vote2020$Date == ""] <- NA
vote2020$Date <- na.locf(vote2020$Date)

#merge
turnout <- bind_rows(vote2008, vote2012, vote2016, vote2020)

#clean state names
turnout$State <- str_remove(turnout$State, "(\\(.*?\\))")
#clean election.type
turnout$type <- str_extract(turnout$Election.Type, "Caucus|Primary")

# add indicator for treated rows
turnout <- turnout %>% mutate(Treated = ifelse(State == "Minnesota", 1,
                              ifelse(State == "Colorado", 1,
                              ifelse(State == "Idaho", 1,
                              ifelse("Maine", 1, NA)))))

#remove cols not using or have cleaned
turnout <- turnout %>% select(-c(Date, Election.Type, Party, Notes, X, Total.Ballots.Counted.May.Include.Under.and.Over.Votes))
#rename so easier
turnout <- turnout %>% rename(
  VEP_Counted = VEP.Total.Ballots.Counted,
  Cast = Total.Ballots.Cast,
  Year = year,
  Counted = Total.Ballots.Counted,
  Type = type,
  VEP = Voting.Eligible.Population..VEP.,
  VAP = Voting.Age.Population..VAP.,
  Treatment = Treated
)

#reorder so makes sense
turnout <- turnout[, c(1, 2, 3, 7, 8, 4, 5, 6, 9, 10, 11, 12)]

# need to combine separate elections somehow (if dem and rep for one state in one year are in diff rows)

turnout <- write.csv("turnout.csv")
