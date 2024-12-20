# Final Project - BST 260, Fall 2024
**Topic: COVID-19**

## Authors
Niloufar Saririan, Annie Song, Rithika Uppalapati

# Abstract
## Introduction
The final project investigated changes in the virulence of the COVID-19 virus during the pandemic. As a secondary analysis, the project examined whether excess mortality during the pandemic could be explained by COVID-19 mortality. We used publicly-available data from the CDC and the US Census. We conducted the analysis for the 50 states, Washington D.C., and Puerto Rico. 
## Methods
For virulence, we divided the pandemic into seven waves and compared total case, hospitalization, and mortality rates to identify periods of high and low virulence. For excess mortality, we predicted expected mortality using a linear model of all-cause mortality from 2014-2019 by state and week. We compared the difference in actual vs expected mortality to recorded COVID-19 deaths. 
## Results
We found that virulence peaked during September 2020-February 2021 before decreasing. We found that deaths due to COVID-19 do not entirely explain the difference in actual vs predicted mortality.
## Discussion
Our analysis showed that COVID-19 virulence peaked during September 2020-February 2021 before decreasing, potentially related to viral evolution and public health adaptations by state. We also found that COVID-19 deaths do not represent the entirety of excess mortality, suggesting that the pandemic may have caused indirect deaths through other mechanisms. 

# Data 
## Sources
### Population
* State-Level Population Estimates (2020-2023) [NST-EST2023-ALLDATA]: https://www.census.gov/data/tables/time-series/demo/popest/2020s-national-total.html
_Note: We used the Vintage 2023 data for our analysis as the Vintage 2024 data were not yet available at the time of this project._
* State-Level Population Estimates (2010-2019) [NST-EST2019-ALLDATA]: https://www.census.gov/data/tables/time-series/demo/popest/2010s-state-total.html
* National Population Estimate (2024): https://www.census.gov/popclock/
_Note: We calculated the population proportion of each state from 2023 and applied those to the 2024 National Population Estimate for July 1, 2024 (336,673,595, accessed December 17, 2024) from the Population Clock to estimate 2024 state-level populations._

### COVID-19 and Mortality
* State-Level COVID-19 Cases: https://data.cdc.gov/Case-Surveillance/Weekly-United-States-COVID-19-Cases-and-Deaths-by-/pwn4-m3yp
* State-Level COVID-19 Hospitalizations: https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-Hospitalization-Metrics-by-/39z2-9zu6/data?no_mobile=true
* State-Level COVID-19 Mortality: https://data.cdc.gov/NCHS/Provisional-COVID-19-Death-Counts-by-Week-Ending-D/r8kw-7aab/about_data
* State-Level Mortality: https://data.cdc.gov/NCHS/Weekly-Counts-of-Deaths-by-State-and-Select-Causes/3yf8-kanr/about_data
