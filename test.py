# %%
print("Hello, World!")
import pandas as pd
import great_tables as gt
from great_tables.data import towny


# %%

(
    towny[["name", "csd_type", "population_2001", "land_area_km2"]]
    .groupby("csd_type")
    .agg(
        population_2001=("population_2001", "sum"),
        land_area_km2=("land_area_km2", "sum"),
    )
)


# %%

# %%
