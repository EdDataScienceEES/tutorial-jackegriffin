## Welcome to my R Coding Club tutorial on Advanced Package Literacy in `R`!


## Tutorial Aims

### <a href="#section1"> 1. Introduction</a>

### <a href="#section2"> 2. High-Performance Data Manipulation using `data.table`</a>

### <a href="#section3"> 3. Efficient workflows with `purrr`</a>


---------------------------

You can get all of the resources for this tutorial from <a href="https://github.com/EdDataScienceEES/tutorial-jackegriffin.git">this GitHub repository</a>. Clone and download the repo as a zip file, then unzip it.


## <a name="section1"> 1. Introduction</a>

`R` is an incredibly powerful tool, but let's face it - the true magic of `R` lies in the rich ecosystem of packages available. Think of each `R` package as a specialised toolbox, with each one tailored for specific tasks. 
From wrangling messy data sets to building beautiful visualisations or running complex statistical models, there is likely a package that can make your life easier. Yet from this we can be susceptible to something called **package fatigue** (I may coin this term as my own). With a wide range of choices comes an uncertainty as to what to use. 
Alas, this tutorial is here to help you navigate some of the less used packages to help you build confidence and get to grips with the package world of `R`. 

The `tidyverse` is a widely used and powerful set of R packages designed for data analysis, but it is not without its drawbacks. One of the main concerns with the `tidyverse` is its performance on very large datasets. Since `tidyverse` packages like `dplyr` process data in memory, they can struggle when working with datasets that exceed the available memory. This can lead to slow performance compared to alternatives like `data.table`, which is optimized for speed and memory efficiency. In this tutorial you will be using specialised packages such as: `data.table`, `purrr`, `broom`, `janitor`, `lubridate`

So, let's make a start and start thinking about packages we may have not even heard of. Open `RStudio`, clone into the GitHub repository and create a new script by clicking on `File/ New File/ R Script` set the working directory and we are ready to go. 

Today we will be using data from the **Living Planet Index** which is free, open source data and is a key indicator used to measure the state of global biodiversity by tracking changes in the population sizes of vertebrate species over time. Information regarding the Living Planet Index's licensing policy can be found in the GitHub repositories **README**. Other data we will be using will be imported from the web, or directly from an `R` package itself.

## <a name="section2"> 2. High-Performance Data Manipulation Using `data.table`</a>

### Introduction to `data.table`
`data.table` is a package designed for fast and memory-efficient manipulation of large datasets. It provides a simple syntax to filter, summarize, and transform data, allw ithin a single framework. Unlike `dplyr`, when you perform an operation on a `data.table`, the changes are applied to the same object in memory, avoiding the overhead of duplicating the data. But we don't need to worry about that too much. Furthermore, `data.table` excels with it's speed and handling of massive datasets and is most often used when joining large tables or quickly summarizing data.

So, follow along with this tutorial and code to better understand `data.table`

First, let us load our libraries
```
# Loading libraries ----
library(tidyverse)
install.packages("palmerpenguins")
library(palmerpenguins)
```
It's recommended to run `install.packages()` to get the latest version of `data.table` on the CRAN repository. But if you want to get the latest development version however, you can get it from GitHub as well.
```
# Install using CRAN
install.packages(data.table)

# Install Dev version from GitHub
install.packages("data.table", repos="https://Rdatatable.gitlab.io/data.table")
data.table::update.dev.pkg()

# Don't worry if this doesn't work, you can revert back to the CRAN version of data.table using:
remove.packages("data.table")
install.packages("data.table")
library(data.table)
```
#### Importing data using `data.table`

The way we work with data.tables is quite different to how we would normally work with data.frames. Before we gain mastery over this package, lets understand the differences first. 
The `fread()` function (short for fast read) is data.tables equivalent to `read.csv()`. 
Akin to `read.csv`, it works from a file in your local computer as well as file hosted on the internet. On top of this, it is at least 20 times faster! This is especially useful when working with very large datasets (millions of rows).  
Run the code below, and see how fast `fread()` is. It creates a 1M rows csv file, then reads it back again. The time taken by `fread()` and `read.csv()` gets printed in the console.
```
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
```
IMPORTANT: Do not attempt to open the m2.csv or push it to github as it will crash your session - it is a very large dataset and I know this from experience...

Let's import some data based on forest fires using `fread()`
```
ff <- fread("https://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv")
head(ff)
class(ff)
```
The imported is stored directly as a `data.table`. As you can see from the `class(ff)` output, the `data.table` inherits from a `data.frame` class and therefore is a `data.frame` by itself. This means that any functions you may normally use on `data.frame` will also work just fine on `data.table`. Because the dataset we imported was relatively small, the `read.csv()`'s speed was good enough.

#### Converting `data.frame` to `data.table`
You can convert any `data.frame` into `data.table` using any one of these two approaches:
1. `data.table(df)` or `as.data.table(df)`, where `(df)` is your chosen data frame
2. `setDT(df)`  

The difference between these two approaches is that `data.table(df)` will create a copy of `(df)` and convert it to a `data.table`, whereas `setDT(df)` converts it to a `data.table` and fully replaces it (converts it inplace, if you will)
```
# Lets load a default dataframe from R's default datasets package and palmerpenguins package
data(penguins)
```
Note: the `data.table()` has no rownames, and so if the `data.frame` does have rownames, these must be stored in a separate column before converting to `data.table`.
So, our `penguins` data has no rownames, but purely for example's sake, we can create rownames before going forward.
Normally, you may not need to do this to the `penguins` data, and we could instead use a dataframe that already has rownames such as `mtcars`, but we like to keep the ecological context.
```
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
```
And vice versa, and vice versa...

#### Filtering rows based on conditions
The biggest difference between `data.frame` and `data.table` is that `data.table` is aware of its column names.
So while filtering, passing only the column names inside the square brackets is perfect suitable, and very handy.
```
# Dataframe syntax
penguins[penguins$species == "Adelie" & penguins$body_mass_g > 4000, c("species", "island", "body_mass_g")]

# Datatable syntax
penguins_dt[species == "Adelie" & body_mass_g > 4000, ]
# This saves a good amount of time in the long run and is a major advantage
```
# SYNTAX DIAGRAM

#### How to select given columns
Let's now investigate how to subset columns.
Different to `data.frame`, you cannot select a column by its numbered position.
```
penguins[, 1]
# Returns first column in a data frame
```
Using `data.table`, better practice is to pass in the column name.
```
penguins_dt[, species]
```
#### How to select multiple columns using a character vector
If your column name is present as a string in another variable (vector), you cannot call the column directly.
Instead, you will need to additionally pass `with=FALSE`.
```
myvar <- "species"
penguins_dt[, myvar, with=F]
# Returns species column

# The same applies when you want to select multiple columns
columns <- c('species', 'sex', 'island')
penguins_dt[, columns, with=F]
# Without with=F the above command will not work
```
Roger that? If you want to select multiple columns directly, then enclose all the required column names in a list
```
penguins_dt[, .(species, sex, island)]
```
#### How to drop columns
We can drop columns by placing the column names into a vector and use the `!` in front of them - returning all columns except those present in the vector.
```
drop_cols <- c("species", "sex", "island")
penguins_dt[, !drop_cols, with = FALSE]
```
#### How to rename columns
For this, we can use the `setnames()` function as normal for both `data.table` and `data.frame`.
The `setnames()` function takes the current name and new name as arguments and changes the column names in place without any copying of data.
```
setnames(penguins_dt, 'penguinid', 'observation')
colnames(penguins_dt)
# 'penguinid column is renamed to 'observation'
```
#### Creating a new column from existing columns
You can indeed create a new column as you normally might with `data.frame`, but with `data.table`, you can create a column from within square brackets - saving keystrokes
```
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
```
#### Grouping
Let us now move on to the second major and awesome feature of R `data.table`: grouping using `by`.
In base `R`, grouping is achieved by using the `aggregate()` function. This basic syntax can be a bit cumbersome and hard to remember
While not sacrificing any functionality, we can use the `by` argument within square brackets.
For example, in `penguins` data, we can use these functions to find out how to get the mean body mass for either sex.
Since we want to see the body mass by sex, set `by = sex` inside the square brackets
```
# Mean body mass in grams by 'sex'
penguins_dt[, .(mean_bodymass=mean(body_mass_g)), by=sex]
# Now that is just brilliant - a proper light-bulb moment if you ask me

# You can even add multiple columns to the'by' argument.
penguins_dt[, .(mean_bodymass=mean(body_mass_g)), by=.(sex, species)]
```
Super, now you should feel more confident on how to use data.table to further you data manipulation expertise.

For now, take a breather, grab a cup of tea or drink of your choice before we change the subject a tad and look at how we can use `purrr` to build efficient workflows

## <a name="section3"> 3. Efficient workflows with `purrr`</a>
### Introduction to `purrr`
The `purrr` package is part of the `tidyverse` and focuses on functional programming, which is all about using functions to work with data. If you're not familiar with this concept, don't worry—it's just a way of automating repetitive tasks, similar to using functions like `apply()` in base `R`.
At its core, `purrr` is designed to help you work with lists and perform iterations—that is, applying the same function to multiple elements, one at a time. Think of it as the `tidyverse`'s answer to base `R`'s `apply()` family, but with a more modern, flexible, and of course, tidy approach.
If you’ve ever thought `purrr` seems too complicated to learn, this section will make it easier for you! We'll start with the `map()` functions, which are the foundation of `purrr`. By the end, you’ll see how powerful lists can be and how `purrr` can simplify your code.
To get the most out of `purrr`, it helps to understand lists, the main type of data it works with. Here's how lists fit into `R`:
```
my_first_list <- list(my_number = 5,
                      my_vector = c("a", "b", "c"),
                      my_dataframe = data.frame(a = 1:3, b = c("q", "b", "z"), c = c("pandas", "are", "silly")))
my_first_list
```
### Map functions: Easier iteration in `R`
A map function is a tool that lets you apply the same action or function to every element of an object. This could mean applying a function to each entry of a list, each element of a vector, or even each column of a data frame.
If you’ve used base `R`'s `apply()` functions, you already know how map functions work. 

The `apply()` family (like `lapply()`, `sapply()`, etc.) is great for performing repetitive tasks without writing a for-loop. However, these functions can be tricky because:
- Their syntax is inconsistent (each one works slightly differently).
- It’s sometimes unclear what type of object they’ll return (e.g., `sapply()` might return a list or vector).

In `purrr`, the name of the map function tells you what type of output it will produce. For example:
- `map(.x, .f)` is the main mapping function and returns a list
- `map_df(.x, .f)` returns a data frame
- `map_dbl(.x, .f)` returns a numeric (double) vector
- `map_chr(.x, .f)` returns a character vector
- `map_lgl(.x, .f)` returns a logical vector

Consistent with the way of the `tidyverse`, the first argument of each mapping function is always the data object that you want to map over.
The second argument is always the function that you want to iteratively apply to each element of the input object.
The input object to any map function is always either a vector (of any type), a list, or a data frame.

Since the first argument is always the data, pipes (`%>%`) come in very handy, allowing us to string together many functions by piping an object into the first argument of the next function.

#### Simplest usage: Reapeated looping with map
Fundamentally, maps are for iteration. In the below example, we will iterate through the vector `c(1, 4, 7)` by adding 10 to each entry.
This function applied to a single number, which we will call .x can be defined as:
```
library(tidyverse)
addTen <- function(.x) {
  return(.x + 10)
}
```
Then we can use the `map()` function which will iterate `addTen()` across all entries of the vector, `.x = c(1, 4, 7)`, and return the output as a list.
```
map(.x = c(1, 4, 7),
    .f = addTen)
```
What's even better is that you don't need to specify the argument names.
```
map(c(1, 4, 7), addTen)
# We can see the output applies the condition to each element of the vector: 1 = 11, 4 = 14, 7 = 17
```
No matter if the input object is a vector, a list or a data frame, `map()` always returns a list.
```
map(list(1, 4, 7), addTen)
map(data.frame(a = 1, b = 4, c = 7), addTen)
# Roger that?
```

If we wanted the output to be some other object type, we need to use a different function. For instance to map the input to a numeric (double vector), you can use the `map_dbl()` ("map to double") function.
```
map_dbl(c(1, 4, 7), addTen)
```
Using the same logic, we can map to a character vector using `map_chr()` ("map to a character").
```
map_chr(c(1, 4, 7), addTen)
```
If we wanted to return a data frame then we can use the `map_df()` function.
But tread carefully and make sure that for each iteration you have consistent column names.
`map_df` will automatically bind the rows of each iteration.
For the code below, we want to return a data frame where the columns correspond to the original number and the number plus ten.
```
map_df(c(1, 4, 7), function(.x) {
  return(data.frame(old_number = .x, 
                    new_number = addTen(.x)))
})
```
The function `modify()` is similar in nature to `map()` functions, but always returns an object the same type as the input object.
```
modify(c(1, 4, 7), addTen)
modify(list(1, 4, 7), addTen)
modify(data.frame(1, 4, 7), addTen)
```
Modify also has `modify_if()` that only applies the function to elements that satisfy a specific criteria.
This is specified by a "predicate function", the second argument called `.p`  
```
modify_if(.x = list(1, 4, 7),
          .p = function(x) x > 5,
          .f = addTen)
```
Looking at the output for the above code, we can see that only the third entry is modified as it is greater than 5.

#### The tilde-dot shorthand for functions
To make the code more concise you can use the tilde-dot shorthand for anonymous functions.
In 'R', an anonymous function is a function that is created on the fly without being given a name. Instead of defining it separately and assigning it to a variable, you define it directly in the code where it's needed. This is particularly useful in `purrr` when you need to apply a quick custom operation inside a map function.
Unlike normal function arguments that can by be anything you like, the tilde-dot function argument is always `.x`.
Thus, instead of defining the `addTen()` function separately, we could use the tilde-dot shorthand..
```
map_dbl(c(1, 4, 7), ~{.x + 10})
```
For the next section of this tutorial we will use the LPI birds dataset from the Living Planet Index. This can be accessed through the <a href="https://github.com/EdDataScienceEES/tutorial-jackegriffin.git">GitHub repository</a>.
For this task, some functions will first be demonstrated using a simple, non-consequantial numeric example just to get a feel for what is going on.
Then, the functions will be demonstrated using a more complex practical example based on the LPI dataset.
So:
```
# Import data
LPI_data_orig <- read.csv("data/LPI_birds.csv")

# And we can define a copy of the original dataset that we will clean and operate on
LPI_data <- LPI_data_orig
# I find it handy to look between the original and working dataset copy to see the changes you have made

# Thankfully, this data is already pretty tidy though there are a few NAs, we can drop rows that have NAs using base R's na.omit() function
LPI_data <- na.omit(LPI_data)

# We also need to reshape the data into long format
LPI_data <- LPI_data %>%
  pivot_longer(cols = 25:69,
               names_to = 'year',
               values_to = 'pop')

# And now extract the numeric values from the year column
LPI_data <- LPI_data %>%
  mutate(year = as.numeric(gsub("X", "", year)))
```
Since LPI_data is a data frame, the `map_()` functions will iterate over each column. An example of simple usage of the `map_()` functions is to summarize each column. 
For instance, you can identify the type of each column by applying the `class()` function to each column. 
Since the output of the `class()` function is a character, we will use the `map_chr()` function.
Apply the `class()` function to each column
```
LPI_data %>% map_chr(class)
```
This is very handy to get a quick snapshot of what you're working with in a dataset.
Also, using pipes is great to use instead of adding the data again as an argument.

Similarly, if you want to identify the number of distinct values in each column, you could apply the `n_distinct()` function from the `dplyr` package to each column.
Since the output of `n_distinct()` is a numeric (a double), you may want to use the `map_dbl()` function. This would provide the results of each iteration as a concatenation in a numeric vector.
Apply the `n_distinct()` function to each column.
```
LPI_data %>% map_dbl(n_distinct)
```

We can make this a bit more complicated by combining a few different summaries using `map_df()`.
When making things a bit more complicated we normally also have to define anonymous function to apply to each column.
We can do this using the tilde-dot notation too.
Then, once the columns have been iterated through, the `map_df()` function combines the data frames row-wise into a single data frame.
```
LPI_data %>% map_df(~(data.frame(n_distinct = n_distinct(.x),
                                  class = class(.x))))
# Note that here we have lost the variable names

# We can tell map_df() to include the variable names using the .id argument
LPI_data %>% map_df(~(data.frame(n_distinct = n_distinct(.x),
                                  class = class(.x))),
                     .id = "variable")
# Sweet
```
#### Maps with multiple input objects
Now, enough messing about. Time for some fancier stuff.
Let's say we want to perform a map that iterates through two objects.
The following code uses map functionns to create a list of plots.
To do this, the map function that maps over two objects instead of just 1 is called `map2()`
The first two arguments are the two objects you want to iterate over, and the third is the function (with two arguments, one for each object)
```
map2(.x = object1, # the first object to iterate over
     .y = object2, # the second object to iterate over
     .f = plotFunction(.x, .y))
```
ERROR: Dont worry, this code wont run, and is purely exemplary - object1 and object2 need to be properly defined when putting this into practice.
First, you need to define a vector (or list) and a paired vector (or list) that you want to iterate through.
In this example, using LPI data:
- the first iteration will correspond to the first family in the family vector and the first year in the year vector
- the second iteration will correspond to the second family in the family vector and the second year in the year vector

First, let's get our vectors of family and years, starting by obtaining all distinct combinations of families and years that appear in the data
```
cfyear <- LPI_data %>%
  distinct(Family, year) # Use the names consistent with how you've formatted the columns in your dataset
cfyear

# Then extract the continent and year pairs as separate vectors
family <- cfyear %>%
  pull(Family) %>%
  as.character
years <- cfyear %>%
  pull(year)
```

When using the tilde-dot short-hand, the anonymous arguments will be `.x` for the first object being iterated over, and `.y` for the second object being iterated over.
Before jumping into this, however, it is a good idea to first figure out what the code will be for just the first iteration.
```
.x <- family [1]
.y <- years[1]
```

Now let's make a scatterplot of population vs common names.
```
LPI_data %>%
  filter(Family == .x,
         year == .y) %>%
  ggplot() +
  geom_point(aes(x = pop, y = Common.Name)) +
  ggtitle(glue::glue(.x, " ", .y))
```

This seems to have worked so now we can copy and paste the code into the `map2()` function.
```
plot_list <- map2(.x = family,
                  .y = years,
                  .f = ~{
                    LPI_data %>%
                      filter(Family == .x,
                             year == .y) %>%
                      ggplot() +
                      geom_point(aes(x = pop, y = Common.Name)) +
                      ggtitle(glue::glue(.x, " ", .y))
                  })
```
We can look at a few of the entries of the list to see that they make sense.
```
plot_list[[1]]
plot_list[[22]]
plot_list[[76]]
```

#### List columns and nested data frames
Tibbles are `tidyverse` dataframes.
Some crazy stuff starts happening when you learn that tibble columns can be lists (as opposed to vectors, which is what they are usually).
This is where the difference between tibbles and data frames becomes very real.

For instance, a tibble can be "nested" where the tibble is essentially split into separate data frames based on a grouping variable, and these separate data frames are stored as entries of a list (that is then stored in the data column of the data frame).
Here we can nest the data frame by a chosen column.
```
LPI_nested <- LPI_data %>%
  group_by(Family) %>%
  nest()
LPI_nested
```
Looking at the output, the first column is the variable that we grouped by, `Family`, and the second column is the rest of the data frame corresponding to that group (as if you had filtered the data frame to the specific family).
To better understand this, we can visualise it with the following code showing that the first entry in the first entry in the data column corresponds to the entire dataset for the first family: "Phasianidae".
```
LPI_nested$data[[1]]
```
We can get the same output using `dplyr`'s `pluck()` function.
```
LPI_nested %>%
  pluck("data", 1)
```

At this point, rightly so, you may be asking why would you ever want to nest your data frame?
Until you realise that you now have the power to use dplyr manipulations on more complex objects that can be stored in a list.
However, since actions such as `mutate()` are applied directly to the entire column (which is usually a vector, which is fine), we run into issues when we try to manipulate a list.
For instance, since columns are usually vectors, normal vectorized functions work just fine on them.
```
tibble(vec_col = 1:10) %>%
  mutate(vec_sum = sum(vec_col))
```

But when the column is a list, vectorized functions don't know what to do with them, and we get an error that says `Error in sum(x) : invalid 'type' (list) of argument`.
Try,
```
tibble(list_col = list(c(1, 5, 7), 
                       5, 
                       c(10, 10, 11))) %>%
  mutate(list_sum = sum(list_col))
```













