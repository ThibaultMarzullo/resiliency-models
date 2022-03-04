

###### (Automatically generated documentation)

# Add Batteries and PV

## Description
Add batteries and PV generation to baseline building.  Add relevant controls.

## Modeler Description
In an all-electric building, include on-site storage and generation for improved building resiliency.

## Measure Type
EnergyPlusMeasure

## Taxonomy


## Arguments


### Capacity of the battery bank
Total capacity of the battery bank in Joules (J)
**Name:** batt_storage_capacity,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Battery discharge power
Maximum discharge power in Watts (W)
**Name:** batt_discharge_power,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Battery charge power
Maximum charge power in Watts (W)
**Name:** batt_charge_power,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Initial battery charge
Initial charge of the battery bank in Joules (J)
**Name:** batt_initial_charge,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Total PV power
Total power output of the PV panels in Watts (W)
**Name:** pv_total_power,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Number of PV modules in a series string
Number of modules
**Name:** parallel_modules,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Number of PV strings in series
Number of modules
**Name:** series_modules,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Length of PV array
In meters (m)
**Name:** pv_len,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Width of PV array
In meters (m)
**Name:** pv_wid,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false






