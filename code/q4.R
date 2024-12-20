# load libraries and read/wrangle data ####
library(tidyverse)
library(ggplot2)
library(scales)

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

# create state name table
state_xwalk <- tibble(state = state.name) |>
  bind_cols(tibble(abb = state.abb)) |>
  bind_rows(tibble(state = c("District of Columbia", "Puerto Rico")
                   , abb = c("DC", "PR")))

# dataset: [Census] Population, Population Change, and Estimated Components of 
#           Population Change: April 1, 2010 to July 1, 2019
pop1 <- read.csv("https://github.com/anniesong21/final260project/blob/main/raw-data/nst-est2019-alldata.csv?raw=true")
pop2 <- pop1 |> 
  filter(STATE != 0) |>
  as_tibble() |>
  select(NAME, POPESTIMATE2014, POPESTIMATE2015, POPESTIMATE2016
         , POPESTIMATE2017, POPESTIMATE2018, POPESTIMATE2019) |>
  rename(state_name = NAME) |>
  pivot_longer(-state_name, names_to='year', values_to='population') |>
  mutate(year = str_remove(year, "POPESTIMATE")) |>
  mutate(across(-state_name, as.numeric)) |>
  left_join(state_xwalk, by = c("state_name" = "state")) |>
  rename(state = abb) |>
  select(year, population
         , state_name
         , state)
head(pop2)
rm(pop1)

# get historical weekly death rates ####
deaths <- deaths_raw |>
  select(jurisdiction_of_occurrence, mmwryear, mmwrweek
         , allcause) |>
  rename(deaths = allcause, state_name = jurisdiction_of_occurrence) |>
  mutate(across(-state_name, as.numeric)) |>
  left_join(pop2, by = c("mmwryear" = "year", "state_name" = "state_name")) |>
  filter(state %in% dat_wave$state) |>
  mutate(death_per_100k = deaths/population*100000) |>
  # change to factor for modeling
  mutate(mmwr_week = as.factor(mmwrweek)) |>
  select(-mmwrweek)

# visualize historical death rates - random state - Mass.
deaths |> filter(state == "MA") |>
  ggplot(aes(mmwr_week, death_per_100k, group = mmwr_week)) +
  geom_boxplot()

# predict future weekly death rates ####
# not including year
mod1 <- lm(death_per_100k ~ state + mmwr_week, data = deaths)

newdata <- dat_wave |>
  mutate(mmwr_week = as.factor(mmwr_week))

# new data
pred <- predict(mod1, newdata = newdata, se.fit=TRUE)

dat_wave_expected <- dat_wave |>
  mutate(expected_mort_rate_per100k = pred$fit
         , expected_deaths = pred$fit * population / 100000
         , excess = total_deaths - expected_deaths)

# saveRDS(dat_wave_expected, file = "../data/dat_wave_expected.rds")

# visualize results ####

# excess deaths by state
dat_wave_expected |> 
  mutate(wave = as.factor(wave)) |>
  ggplot(aes(x=date, color = wave)) +
  geom_line(aes(y = excess)) +
  facet_wrap(~state, scales = "free_y") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "8 months") + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  geom_hline(yintercept = 0, linetype="dashed", color = "black")
# ggsave("../docs/excess_by_state.png", width = 24, height = 14)

# excess deaths with covid case rate overlaid in gray
dat_wave_expected |> 
  mutate(wave = as.factor(wave)) |>
  ggplot(aes(x=date, color = wave)) +
  geom_line(aes(y = excess)) +
  geom_line(aes(y = cases/population*100000), col = "darkgrey", lty = 1) +
  facet_wrap(~state, scales = "free_y") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "8 months") + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  geom_hline(yintercept = 0, linetype="dashed", color = "black")
# ggsave("../docs/excess_by_state_overlay.png", width = 24, height = 14)

# covid deaths ####
dat_covid <- dat_wave_expected |>
  mutate(deaths = replace_na(deaths, 0)) |>
  mutate(excess_min_covid = excess - deaths)

dat_covid |>
  mutate(wave = as.factor(wave)) |>
  ggplot(aes(x = date, y = excess_min_covid)) +
  geom_boxplot(aes(group = date), col = "grey") +
  # geom_point(col = "grey") +
  geom_smooth(aes(color = wave)) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "6 months") + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  geom_hline(yintercept = 0, linetype="dashed", color = "black") +
  ggtitle("Difference in Actual vs Predicted Mortality, Minus Deaths From COVID-19, by State") +
  xlab("Date") + 
  ylab("Deaths")
# ggsave("../docs/excs_min_cvd_box.png", width = 10, height = 6)
