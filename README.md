# IWN 2025 Hackathon

This repository provides the data files for the 2025 IWN hackathon.

This repository was cloned from the original to obtain the datasets.

The code in this repo explores and cleans the digital metering data in readiness for the hackathon.

## Datasets

Anonymity datasets are provided by the SmartH2O project.

This repository contains the anonymized datasets of water consumptions of __Tegna__ and __Valencia__ SmartH2O's users.

Each dataset is stored in its named folder, and have the same file naming:
 
`anonymizer.zip`: the compressed archive of water consumptions and households features

Once decompressed, the archived files are `smarth2o_anonymized_households.csv` and `smarth2o_anonymized_consumptions.csv`

### smarth2o_anonymized_households.csv
It contains the features of the households' users. The columns meaning is:

1. `index` The number of the row in the csv file
1. `smart_meter_id` The smart meter's ID
1. `household_size` The size of the Household (in squared meters)
1. `household_garden_area` The size of the garden (in squared meters)
1. `household_pool_volume` The volume of the pool (in cubic meters)
1. `household_pool` The presence of the pool (boolean)
1. `household_garden` The presence of the garden (boolean)
1. `residency_type` The type of residency (Flat, House, Single Family, ...) 
1. `number_bathrooms` The number of bathrooms
1. `environmental_attitude` The environmental attitude sensitivity of the user (High, Medium, Low)
1. `irrigation_system` The presence of an irrigation system (boolean)
1. `house_plants` The presence of house plants (boolean)
1. `balcony_plants` The presence of balcony plants (boolean)
1. `building_size` The size of the building (in squared meters)
1. `name` The name of a complex device (washing mascine, dishwater, ...)
1. `efficiency` The nefficiency of the complex device ( A, A+. A++, ...)
1. `ecomode` The presence of the Eco-Mode feature in the complex device (boolean)
1. `timer` The presence of the timer in the complex device (boolean)
1. `name.1` The name of a simple device (toilet, sink, bathtub, ...)
1. `number` The number of the simple device 

For all columns, a `NULL` value means that the user doesn't provided the information.

### smarth2o_anonymized_consumptions.csv
It contains the periodic readings of the smart meters.

The columns meaning is:
1. `index`  The number of the row in the csv file
1. `smart_meter_id` The smart meter's ID
1. `tst` The timestamp of the reading
1. `meter_reading` The value read

The difference of the reading values between two consecutive rows gives the water __consumption__.

