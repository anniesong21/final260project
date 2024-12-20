# load libraries and read/wrangle data ####
library(tidyverse)
library(ggplot2)

# read in data 
# setwd("~/Harvard/Fall2024/BST260_Data_Science/final260project/code")
dat_wave <- readRDS("../data/dat_wave.rds")
head(dat_wave)
str(dat_wave)

# old mortality by state
get_cdc_data <- function(url){
  require(httr2)
  ret <-
    request(url) |>
    req_url_query("$limit"=10000000000) |>
    req_perform() |>
    resp_body_json(simplifyDataFrame = TRUE) 
  return(ret)
}
# dataset: [CDC] weekly counts of deaths by state and select causes, 2014-2019
deaths_raw <- get_cdc_data("https://data.cdc.gov/resource/3yf8-kanr.json")

# dataset: [Census] Population, Population Change, and Estimated Components of 
#           Population Change: April 1, 2010 to July 1, 2019
pop1 <- read.csv("https://github.com/anniesong21/final260project/blob/main/data/nst-est2019-alldata.csv?raw=true")
pop2 <- pop1 |> 
  filter(STATE != 0) |>
  as_tibble() |>
  select(NAME, POPESTIMATE2014, POPESTIMATE2015, POPESTIMATE2016
         , POPESTIMATE2017, POPESTIMATE2018, POPESTIMATE2019) |>
  rename(state_name = NAME) |>
  pivot_longer(-state_name, names_to='year', values_to='population') |>
  mutate(year = str_remove(year, "POPESTIMATE")) |>
  mutate(across(-state_name, as.numeric)) |>
  mutate(state = state.abb[match(state_name, state.name)]) |>
  mutate(state = case_when(state_name == "Puerto Rico" ~ "PR",
                           state_name == "District of Columbia" ~ "DC",
                           .default = state))  |>
  select(year, population, state)
head(pop2)
rm(pop1)

# get historical weekly death rates ####
deaths <- deaths_raw |>
  select(jurisdiction_of_occurrence, mmwryear, mmwrweek
         , allcause) |>
  mutate(state = state.abb[match(jurisdiction_of_occurrence, state.name)]) |>
  filter(state %in% dat_wave$state) |>
  rename(deaths = allcause) |>
  select(-jurisdiction_of_occurrence) |>
  mutate(across(-state, as.numeric)) |>
  left_join(pop2, by = c("mmwryear" = "year", "state" = "state")) |>
  mutate(death_per_100k = deaths/population*100000)

# predict future weekly death rates ####

