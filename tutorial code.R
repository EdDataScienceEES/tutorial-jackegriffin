# First, let's load our library and dataset
library(tidyverse)
library(data.table)


# The LPI data here is provided as .csv, but we can load it as a data.table using the fread function from data.table
lpi_data <- fread("data/LPI_birds.csv")
# fread() reads the CSV file and returns it as a data.table
# Let's see what the data looks like
str(lpi_data)
head(lpi_data)

# Let's now inspect the columns to see which ones are important for the analysis
colnames(lpi_data)
summary(lpi_data)

# Let's suppose we want to filter data for a specific country
# We can use [...] from data.table to filter or subset the data efficiently
# In this case, we use it to specify which column (Country.list) and what we want to do within the column using operators (==).
uk_data <- lpi_data[Country.list == "United Kingdom"]

# Before we go any further, you may have spotted that the data is in wide format.
# The next few steps use dplyr to tidy the data and altogether acts as a great example of how packages can be combined.
# We can convert the data to long format nicely using dplyr and pivot_longer()
uk_data <- uk_data %>%
  pivot_longer(cols = 25:69,
               names_to = 'Year',
               values_to = 'Population')

# From this, we need to then extract numeric values from the year column using mutate()
uk_data <- uk_data %>%
  mutate(Year = as.numeric(gsub("X", "", "Year")))

# Now, we have quite a few NAs, lets get rid of these and only keep rows with numeric values
uk_data <- uk_data %>%
  filter(is.finite(as.numeric(Population)))

# OK, brilliant, now we may continue.
# Say we want to group the data by each species in the UK and calculate the mean population for each.
species_trends <- uk_data[Country.list == "United Kingdom", .(mean_population = mean(Population, na.rm = TRUE)), by = Species]

?data.table




# [, .(column_name = function), by = column] (Group by and aggregate) This syntax is used to perform operations on groups of data. It allows you to compute summary statistics or create new columns based on groupings.