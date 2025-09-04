# IWN 2025 Hackathon

This repository provides the data files and some exploratory analysis for the 2025 IWN hackathon.

This repository is forked from the [SmartH2O data](https://github.com/The-SmartH2O-project/datasets) and enhanced with some scripting to clean and explore the data.

## Files
- `clean_data`: Cleaned data sets suitable for analysis (not on GitHub)
- `Tegna`: Raw data for the Swiss town of [Terre di Pedemonte](https://en.wikipedia.org/wiki/Terre_di_Pedemonte).
- `Valencia`: Raw data for the Spanish city of [Valencia](https://en.wikipedia.org/wiki/Valencia).
- `etl.R`: Script for cleaning the raw data
- `README.md`: This file
- `shiny-application.r`: Interactive application to explore the data. 

## Raw Data
The SmartH2O project provides anonymised digital metering datasets from the towns of Tegna and Valencia in Switserland and Spain.

Each dataset is stored in its named folder and has the same file: `anonymizer.zip`. Once decompressed, the archived files are `smarth2o_anonymized_households.csv` and `smarth2o_anonymized_consumptions.csv`

## Extract, Transfer and Load (ETL)
The raw data is extracted and transferred with the `etl.R` script to create [tidy data](https://r4ds.had.co.nz/tidy-data.html). The data is stored in three files:

### `tegna_valencia_meter_reads.csv`

- `smart_meter_id`: The smart meter's unique ID. Starts with either T (Tegna) or V (Valencia), followed by a three-digit number.
- `timestamp`: Timestamp in local time.
- `meter_reading`: Cumulative meter read in litres.
- `town`: name of the town (Tegna or Valencia).

Note that this data shows regular anomalies, such as negative flows.

The meta data is provided in two separate files:

### `tegna_valencia_houshold_meta_data.csv`

- `smart_meter_id`: The smart meter's unique ID. Starts with either T (Tegna) or V (Valencia), followed by a three-digit number.
- `household_size`: The size of the Household (in square meters)
- `household_garden_area` The size of the garden (in square meters)
- `household_pool_volume` The volume of the pool (in cubic meters)
- `household_pool` The presence of the pool (boolean)
- `household_garden` The presence of the garden (boolean)
- `residency_type` The type of residency (Flat, House, Single Family, ...)
- `number_bathrooms` The number of bathrooms
- `environmental_attitude` The environmental attitude sensitivity of the user 
- `irrigation_system` The presence of an irrigation system (boolean)
- `house_plants` The presence of house plants (boolean)
- `balcony_plants` The presence of balcony plants (boolean)
- `building_size` The size of the building (in square meters)
- `appliance` The name of a complex device (washing machine, dishwasher, ...)
- `efficiency` The efficiency of the complex device ( A, A+, A++, ...)
- `ecomode` The presence of the Eco-Mode feature in the complex device (boolean)
- `timer` The presence of the timer in the complex device (boolean)

### `tegna_valencia_appliances.csv`

- `smart_meter_id`: The smart meter's unique ID.
- `appliance`: Type of appliance.
- `number`: Number of appliances in the household.

Note that the meta data is incomplete as not all trial participants provided the required information.

# Shiny Application
A [Shiny Application](https://shiny.posit.co/) provides basic exploratory analysis of the meter reads and provides the basic metadata.

The application is hosted on [ShinyApps.io](https://prevos.shinyapps.io/iwn-hackathon-2025/).
