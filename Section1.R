# Loading libraries ----
library(tidyverse)
install.packages("palmerpenguins")
library(palmerpenguins)

# It's recommended to run install.packages() to get the latest version of data.table on the CRAN repository
# If you want to get the latest development version however, you can get it from GitHub as well
# Install using CRAN
install.packages(data.table)

# Install Dev version from GitHub
install.packages("data.table", repos="https://Rdatatable.gitlab.io/data.table")
data.table::update.dev.pkg()

# Don't worry if this doesn't work, you can revert back to the CRAN version of data.table using:
remove.packages("data.table")
install.packages("data.table")
library(data.table)


# Importing data ----
# The way we work with data.tables is quite different to how we would normally work with data.frames.
# Before we gain mastery over this package, lets understand the differences first.

# The fread() function (short for fast read) is data.tables equivalent to read.csv().
# Akin to read.csv, it works from a file in your local computer as well as file hosted on the internet.
# On top of this, it is at least 20 times faster!
# This is especially useful when working with very large datasets (millions of rows)
# Run the code below, and see how fast fread() is. It creates a 1M rows csv file, then reads it back again.
# The time taken by fread() and read.csv gets printed in the console

# Create a large .csv file
set.seed(100)
m <- data.frame(matrix(runif(10000000), nrow=10000000))
write.csv(m, 'm2.csv', row.names = F)

# Time taken for read.csv to import
system.time({m_df <- read.csv('m2.csv')})
# Your time may be different to mine
#> user system  elapsed
#> 8.636  0.120 43.003

# Time taken by fread to import
system.time({m_dt <- fread('m2.csv')})
# Again, your time may be different to mine, but you should see much quicker speeds
#> user system  elapsed
#> 0.217  0.018 0.067

# For my times, that's around at least 40x faster. Big difference
# IMPORTANT: Do not attempt to open the m2.csv or push it to github as it will crash your session - it is a very large dataset.
# Let's import some data based on forest fires
ff <- fread("https://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv")
head(ff)
class(ff)
# The imported is stored directly as a data.table. As you can see from the class(ff) output, the data.table inherits from a data.frame class and therefore is a data.frame by itself
# This means that any functions you may normally use on data.frame will also work just fine on data.table.
# Because the dataset we imported was relatively small, the read.csv()'s speed was good enough

# Converting data.frame to data.table ----
# You can convert any 'data.frame' into 'data.table' using any one of these two approaches:
#1. data.table(df) or as.data.table(df), where (df) is your chosen data frame
#2. setDT(df)
# The difference between these two approaches is that data.table(df) will create a copy of (df) and convert it to a data.table,
# whereas setDT(df) converts it to a data.table and fully replaces it (converts it inplace, if you will)

# Lets load a default dataframe from R's default datasets package and palmerpenguins package
data(penguins)

# Note: the data.table() has no rownames, and so if the data.frame does have rownames, these must be stored in a separate column before converting to data.table
# So, our penguins data has no rownames, but purely for example's sake, we can create rownames before going for
# Normally, you may not need to do this to the penguins data, and we could instead use a dataframe that already has rownames such as mtcars, but we like to keep the ecological context.
rownames(penguins) <- paste(penguins$species, 1:nrow(penguins))
head(penguins)

# Now lets store these row names as a separate column
penguins$penguinid <- rownames(penguins)
rm(trees)

# Now we can convert to data.table using one of the methods we mentioned earlier
penguins_dt <- as.data.table(penguins)
class(penguins_dt)

# Alternatively we can use setDT() to convert it inplace
penguins_copy <- copy(penguins)
setDT(penguins_copy)
class(penguins_copy)

# Conversely, we can convert a data.table back to a data.frame using as.data.frame(dt) or setDF(dt)
setDF(penguins_copy)
class(penguins_copy)

# And vice versa, and vice versa...

# Filtering rows based on conditions ----
# The biggest difference between data.frame and data.table is that data.table is aware of its column names.
# So while filtering, passing only the column names inside the square brackets is perfect suitable, and very handy.
# Dataframe syntax
penguins[penguins$species == "Adelie" & penguins$body_mass_g > 4000, c("species", "island", "body_mass_g")]

# Datatable syntax
penguins_dt[species == "Adelie" & body_mass_g > 4000, ]
# This saves a good amount of time in the long run and is a major advantage

# syntax diagram

# How to select given columns ----
# Let's now investigate how to subset columns
# Different to data.frame, you cannot select a column by its numbered position
penguins[, 1]
# Returns first column in a data frame
# Using data.table, better practice is to pass in the column name
penguins_dt[, species]

# How to select multiple columns using a character vector ----
# If your column name is present as a string in another variable (vector), you cannot call the column directly.
# Instead, you will need to additionally pass with=FALSE
myvar <- "species"
penguins_dt[, myvar, with=F]
# Returns species column

# The same applies when you want to select multiple columns
columns <- c('species', 'sex', 'island')
penguins_dt[, columns, with=F]
# Without with=F the above command will not work

# Roger that? If you want to select multiple columns directly, then enclose all the required column names in a list
penguins_dt[, .(species, sex, island)]

# How to drop columns ----
# We can drop columns by placing the column names into a vector and use the ! in front of them - returning all columns except those present in the vector.
drop_cols <- c("species", "sex", "island")
penguins_dt[, !drop_cols, with = FALSE]

# How to rename columns ----
# For this, we can use the setnames() function as normal for both data.table and data.frame.
# The setnames() function takes the current name and new name as arguments and changes the column names in place without any copying of data.
setnames(penguins_dt, 'penguinid', 'observation')
colnames(penguins_dt)
# 'penguinid' column is renames to 'observation'

# Creating a new column from existing columns ----
# You can indeed create a new column as you normally might with data.frame, but with data.table, you can create a column from within square brackets - saving keystrokes
# data.frame syntax (also works on data.table)
penguins_dt$flipper_body_ratio <- penguins_dt$flipper_length_mm / penguins_dt$body_mass_g

# data.table syntax
penguins_dt[, flipper_body_ratio := flipper_length_mm / body_mass_g]
penguins_dt
# Pretty neat

#To create multiple new columns at once, use the  special assignment symbol as a function
penguins_dt[, `:=`(bill_body_ratio = bill_length_mm / body_mass_g, 
                   bill_volume = pi * (bill_depth_mm / 2)^2 * bill_length_mm)]
penguins_dt

# Grouping ----
# Let us now move on to the second major and awesome feature of R data.table: grouping using by.
# In base R, grouping is achieved by using the aggregate() function.
# This basic syntax can be a bit cumbersome and hard to remember
# While not sacrificing any functionality, we can use the by argument within square brackets.
# For example, in penguins data, how to get the mean body mass for either sex?
# Since you want to see the body mass by sex, set by = 'sex' inside the square brackets
# Mean body mass in grams by 'sex'
penguins_dt[, .(mean_bodymass=mean(body_mass_g)), by=sex]
# Now that is just brilliant - a proper light-bulb moment if you ask me

# You can even add multiple columns to the'by' argument.
penguins_dt[, .(mean_bodymass=mean(body_mass_g)), by=.(sex, species)]

# Great, now you should feel more confident on how to use data.table to further you data manipulation expertise