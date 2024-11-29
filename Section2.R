# Introduction to purrr----

# The purrr package is part of the tidyverse and focuses on functional programming, which is all about using functions to work with data. If you're not familiar with this concept, don't worry—it's just a way of automating repetitive tasks, similar to using functions like apply() in base R.
#At its core, purrr is designed to help you work with lists and perform iteration—that is, applying the same function to multiple elements, one at a time. Think of it as the tidyverse's answer to base R's apply() family, but with a more modern, flexible, and tidy approach.
#If you’ve ever thought purrr seems too complicated to learn, this section will make it easier for you! We'll start with the map() functions, which are the foundation of purrr. By the end, you’ll see how powerful lists can be and how purrr can simplify your code.
#To get the most out of purrr, it helps to understand lists, the main type of data it works with. Here's how lists fit into R:
my_first_list <- list(my_number = 5,
                      my_vector = c("a", "b", "c"),
                      my_dataframe = data.frame(a = 1:3, b = c("q", "b", "z"), c = c("pandas", "are", "silly")))
my_first_list

# Map Functions: Easier Iteration in R
#A map function is a tool that lets you apply the same action or function to every element of an object. This could mean applying a function to each entry of a list, each element of a vector, or even each column of a data frame.
#If you’ve used base R's apply() functions, you already know how map functions work. The apply() family (like lapply(), sapply(), etc.) is great for performing repetitive tasks without writing a for-loop. However, these functions can be tricky because:
# - Their syntax is inconsistent (each one works slightly differently).
# - It’s sometimes unclear what type of object they’ll return (e.g., sapply() might return a list or vector).

# In purrr, the name of the map function tells you what type of output it will produce. For example:
# - map(.x, .f) is the main mapping function and returns a list
# - map_df(.x, .f) returns a data frame
# - map_dbl(.x, .f) returns a numeric (double) vector
# - map_chr(.x, .f) returns a character vector
# - map_lgl(.x, .f) returns a logical vector
# Consistent with the way of the tidyverse, the first argument of each mapping function is always the data object that you want to map over
# The second argument is always the function that you want to iteratively apply to each element of the input object
# The input object to any map function is always either a vector (of any type), a list, or a data frame

# Since the first argument is always the data, pipes (%>%) come in very handy, allowing us to string together many functions by piping an object into the first argument of the next function

# Simplest usage: repeated looping with map
# Fundamentally, maps are for iteration. In the below example, we will iterate through the vector c(1, 4, 7) by adding 10 to each entry.
# This function applied to a single number, which we will call .x can be defined as:
addTen <- function(.x) {
  return(.x + 10)
}

# Then we can use the map() function which will iterate addTen() across all entries of the vector, .x = c(1, 4, 7), and return the output as a list
library(tidyverse)
map(.x = c(1, 4, 7),
    .f = addTen)

# What's even better is that you don't need to specify the argument names
map(c(1, 4, 7), addTen)
# We can see the output applies the condition to each element of the vector: 1 = 11, 4 = 14, 7 = 17
# No matter if the input object is a vector, a list or a data frame, map() always returns a list
map(list(1, 4, 7), addTen)
map(data.frame(a = 1, b = 4, c = 7), addTen)
# Roger that?

# If we wanted the output to be some other object type, we need to use a different function. For instance to map the input to a numeric (double vector), you can use the map_dbl() ("map to double") function
map_dbl(c(1, 4, 7), addTen)

# Using the same logic, we can map to a character vector using map_chr() ("map to a character")
map_chr(c(1, 4, 7), addTen)

# If we wanted to return a data frame then we can use the map_df() function.
# Be sure that for each iteration you have consistent column names
# map_df will automatically bind the rows of each iteration
# For the code below, we want to return a data frame where the columns correspond to the original number and the number plus ten
map_df(c(1, 4, 7), function(.x) {
  return(data.frame(old_number = .x, 
                    new_number = addTen(.x)))
})

# The function modify() is similar in nature to map() functions, but always returns an object the same type as the input object
library(tidyverse)
modify(c(1, 4, 7), addTen)
modify(list(1, 4, 7), addTen)
modify(data.frame(1, 4, 7), addTen)

# Modify also has modify_if() that only applies the function to elements that satisfy a specific criteria
# This is specified by a "predicate function", the second argument called .p
modify_if(.x = list(1, 4, 7),
          .p = function(x) x > 5,
          .f = addTen)
# Here, only the third entry is modified as it is greater than 5

# The tilde-dot shorthand for functions ----
# To make the code more concise you can use the tilde-dot shorthand for anonymous functions
# In R, an anonymous function is a function that is created on the fly without being given a name. 
# Instead of defining it separately and assigning it to a variable, you define it directly in the code where it's needed. 
# This is particularly useful in purrr when you need to apply a quick custom operation inside a map function.
# Unlike normal function arguments that can by be anything you like, the tilde-dot function argument is always .x.
# Thus, instead of defining the addTen() function separately, we could use the tilde-dot shorthand
map_dbl(c(1, 4, 7), ~{.x + 10})

# For the next section of this tutorial we will use the LPI birds dataset from the Living Planet Index.
# For this task, each function will first be demonstrated using a simple numeric example, and then will be demonstrated using a more complex practical example based on the forestfires dataset

# Import data
LPI_data_orig <- read.csv("data/LPI_birds.csv")

# And we can define a copy of the original dataset that we will clean and operate on
LPI_data <- LPI_data_orig

# Thankfully, this data is already pretty tidy though there are a few NAs, we can drop rows that have NAs using base R's na.omit() function
LPI_data <- na.omit(LPI_data)

# We also need to reshape the data into long format
LPI_data <- LPI_data %>%
  pivot_longer(cols = 25:69,
               names_to = 'year',
               values_to = 'pop')

# And now extract the numeric alues from the year column
LPI_data <- LPI_data %>%
  mutate(year = as.numeric(gsub("X", "", year)))

# We should also create a new column to normalize the population outputs (scale the values to a range of 0 to 1)
LPI_data$scalepop <- (LPI_data$pop - min(LPI_data$pop, na.rm = TRUE)) / 
  (max(LPI_data$pop, na.rm = TRUE) - min(LPI_data$pop, na.rm = TRUE))

# Finally, we should make the common name and family columns factors so we can later use these in a model
LPI_data$Common.Name <- as.factor(LPI_data$Common.Name)
LPI_data$family <- as.factor(LPI_data$Family)

# Since LPI_data is a data frame, the map_() functions will iterate over each column.
# An example of simple usage of the map_() functions is to summarize each column.
# For instance, you can identify the type of each column by applying the class() function to each column.
# Since the output of the class() function is a character, we will use the map_chr() function
# Apply the class() function to each column
LPI_data %>% map_chr(class)
# This is very handy to get a quick snapshot of what you're working with in a dataset
# Also, using pipes is great to use instead of adding the data again as an argument

# Similarly, if you want to identify the number of distinct values in each column, you could apply the n_distinct() function from the dplyr package to each column.
# Since the output of n_distinct() is a numeric (a double), you may want to use the map_dbl() function.
# This would provide the results of each iteration as a concatenation in a numeric vector
# Apply the n_distinct() function to each column
LPI_data %>% map_dbl(n_distinct)

# We can make this a bit more complicated by combining a few different summaries using map_df()
# When making things a bit more complicated we normally also have to define anonymous function to apply to each column
# We can do this using the tilde-dot notation too.
# Then, once he columns have been iterated through, the map_df() function combines the data frames row-wise into a single data fram
LPI_data %>% map_df(~(data.frame(n_distinct = n_distinct(.x),
                                  class = class(.x))))
# Note that here we have lost the variable names
# We can tell map_df() to include them using the .id argument
LPI_data %>% map_df(~(data.frame(n_distinct = n_distinct(.x),
                                  class = class(.x))),
                     .id = "variable")

# Maps with multiple input objects ----
# Now time for some fancier stuff
# For example, say if we want to perform a map that iterates through two objects
# The following code uses map functions to create a list of plots

# The map function that maps over two objects instead of 1 is called map2().
# The first two arguments are the two objects you want to iterate over, and the third is the function (with two arguments, one for each object)
map2(.x = object1, # the first object to iterate over
     .y = object2, # the second object to iterate over
     .f = plotFunction(.x, .y))
# Note that this code wont run, and is purely exemplary - object1 and object2 need to be properly defined
# First, you need to define a vector (or list) and a paired vector (or list) that you want to iterate through.
# In this example:
# - the first iteration will correspond to the first island in the island vector and the first year in the year vector
# - the second iteration will correspond to the second island in the island vector and the second year in the year vector

# First, let's get our vectors of family and years, starting by obtaining all distinct combinations of families and years that appear in the data
cfyear <- LPI_data %>%
  distinct(Family, year)
cfyear

# Then extract the family and year pairs as separate vectors
family <- cfyear %>%
  pull(Family)
years <- cfyear %>%
  pull(year)

# When using the tilde-do short-hand, the anonymous agruments will be .x for the first object being iterated over,a nd .y for the second object being iterated over
# Before jumping into this, however, it is a good idea to first figure out what the code will be for just the first iteration
.x <- family [1]
.y <- years[1]

# Make a scatterplot of population vs common names
LPI_data %>%
  filter(Family == .x,
         year == .y) %>%
  ggplot() +
  geom_point(aes(x = scalepop, y = Common.Name)) +
  ggtitle(glue::glue(.x, " ", .y))

# This seems to have worked, so now we can copy and paste the code into the map2 function
plot_list <- map2(.x = family,
                  .y = years,
                  .f = ~{
                    LPI_data %>%
                      filter(Family == .x,
                             year == .y) %>%
                      ggplot() +
                      geom_point(aes(x = scalepop, y = Common.Name)) +
                      ggtitle(glue::glue(.x, " ", .y))
                  })

# We can look at a few of the entries of the list to see that they make sense
plot_list[[1]]
plot_list[[22]]
plot_list[[76]]

# List columns and Nested data frames ----
# Tibbles are tidyverse. 
# Some crazy stuff starts happening when you learn that tibble columns can be lists (as opposed to vectors, which is what they are usually).
# This is where the difference between tibbles and data frames becomes very real

# For instance, a tibble can be "nested" where the tibble is essentially split into separate data frames based on a grouping variable, and these separate data frames are stored as entries of a list (that is then stored in the data column of the data frame)
# Here we can nest the data frame by a chosen column
LPI_nested <- LPI_data %>%
  group_by(Family) %>%
  nest()
LPI_nested
# Looking at the output, the first column is the variable that we grouped by, Family, and the second column is the rest of the data frame corresponding to that group (as if you had filtered the data frame to the specific continent).

# To see this, the following code shows that the first entry in the first entry in the data column corresponds to the entire gaminder dataset for Asia
LPI_nested$data[[1]]

# We can get the same output using dplyr's pluck() function
LPI_nested %>%
  pluck("data", 1)

# At this point, and rightly so, you may be asking why would you ever want to nest you data frame?
# Until you realise that you now have the power to use dplyr manipulations on more complex objects that can be stored in a list.
# However, since actions such as mutate() are applied directly to the entire column (which is usually a vector, which is fine), we run into issues when we try to manipulate a list
# For instance, since columns are usually vectors, normal vectorized functions work just fine on them
tibble(vec_col = 1:10) %>%
  mutate(vec_sum = sum(vec_col))

# But when the column is a list, vectorized functions don't know what to do with them, and we get an error that says Error in sum(x) : invalid 'type' (list) of argument
# Try,
tibble(list_col = list(c(1, 5, 7), 
                       5, 
                       c(10, 10, 11))) %>%
  mutate(list_sum = sum(list_col))
# See the error appear

# To apply mutate functions to a list-column, you need to wrap the function you want to apply in a map function
tibble(list_col = list(c(1, 5, 7), 
                       5, 
                       c(10, 10, 11))) %>%
  mutate(list_sum = map(list_col, sum))
# And since map() returns a list itself, the list_sum column is itself a list
tibble(list_col = list(c(1, 5, 7), 
                       5, 
                       c(10, 10, 11))) %>%
  mutate(list_sum = map(list_col, sum)) %>% 
  pull(list_sum)

# And if we wanted it to be vector we could use the map_dbl() function instead
tibble(list_col = list(c(1, 5, 7), 
                       5, 
                       c(10, 10, 11))) %>%
  mutate(list_sum = map_dbl(list_col, sum))

# Nesting the LPI data ----
# Let's return to the LPI dataset
# I want o calculate the average population within each family and add it as a new column using mutate().
# Based on the example above, can you explain why the following code doesn't work?
LPI_nested %>%
  mutate(avg_pop = mean(data$Family))
# We were hoping that this code would extract the Family column from each data frame
# But I'm applying the mutate to the data column, which itself doesn't have an entry called Family since it's a list of data frame

# How can we access the Family column of the data frames stored in the data list?
# Using a map function of course!

# Think of an individual data frame as .x.
# Again, we will first figure out the code for calculating the mean life expectancy for the first entry of the column.
# The following code defines .x to be the first entry of the data column (this is the data frame for Phasianidae)

# The first entry of the "data" column
.x <- LPI_nested %>%
  pluck("data", 1)
.x

# Then to calculate the average population for Phasianidae, we could write
mean(.x$scalepop)

# So, if we copy and paste this into the tilde-dot anonymous function argument of the map_dbl() function within mutate(), we can get what we want
LPI_nested %>%
  mutate(avg_pop = map_dbl(data, ~{mean(.x$scalepop)}))

# This code iterates through the data frames stored in the data column, returns the average life expectancy for each data frame, and concatenates the results into a numeric vector (which is then stored as a column called avg_pop)
# You may be right in saying this is something we could have done a lot more easily using standard dplyr commands (such as summarise()).
# Fair enough I say, but hopefully it helped you understand why you need to wrap mutate functions inside map functions when applying them to list columns

# If you don't find the example above totally inspiring - worry not.
# I ensure you, this next example will blow you away

# The next example will demonstrate how to fit a model separately for each family,a nd evaluate, all within a single tibble
# First, let's fit a linear model for eahc continent and store it as a list-column.
# If the data frame for a single family is .x, then I want to fit lm(scalepop ~ year + Common.Name, data = .x).
# Lets check if this works first.
lm(scalepop ~ year + Common.Name, data = .x)
# OK nice

# We can now copy and pate this model into the map() function within the mutate()
# Fit a model separately for each family
LPI_nested <- LPI_nested %>%
  mutate(lm_obj = map(data, ~lm(scalepop ~ year + Common.Name, data = .x)))
# Unfortunately, we run into an error here
# We get an error because the Common.Name variable has only one level in one or more groups, which makes it invalid as a predictor in the lm() function
# Because we are trying to keep this tutorial relevant to Ecology, the data we are using isn't great, and while we are able to adapt it and make it work, perhaps when you do this with your own data that contains multiple numeric factors it will all make sense

# We can diagnose and fix the issue by doing the following:
problematic_groups <- LPI_nested %>%
  mutate(n_unique_names = map_int(data, ~n_distinct(.x$Common.Name))) %>%
  filter(n_unique_names < 2)
problematic_groups
# Prints out all families that have only 1 factor level

# Filter out problematic groups and only include those that can be used in the model
LPI_nested <- LPI_nested %>%
  mutate(n_unique_names = map_int(data, ~n_distinct(.x$Common.Name))) %>%
  filter(n_unique_names > 1) %>%
  select(-n_unique_names) # Remove helper column

# Now let's try again with the model
LPI_nested <- LPI_nested %>%
  mutate(lm_obj = map(data, ~lm(scalepop ~ year + Common.Name, data = .x)))
LPI_nested

# Where the first linear model (for Phasianidae) is
LPI_nested %>% pluck("lm_obj", 1)

# We can then predict the response for the data stored in the `data` column using the corresponding linear model.
# So we have two objects we want to iterate over: the data and the linear model object.
# This means we want to use map2().
# When things get a bit more complicated, it is good to use multiple function arguments, so we are going to use a full anonymous function rather than the tilde-dot shorthand
# Predict the response for each family
LPI_nested <- LPI_nested %>%
  mutate(pred = map2(lm_obj, data, function(.lm, .data) predict(.lm, .data)))
LPI_nested

# And now we can calculate the correlation between the predicted response and the true response, this time using the map2()_dbl function since we want the output to be a numeric vector rather than a list of single elements.
# Calculate the correlation between observed and predicted response for each family
LPI_nested <- LPI_nested %>%
  mutate(cor = map2_dbl(pred, data, function(.pred, .data) cor(.pred, .data$scalepop)))
LPI_nested

# Now you might be a little bit over it now, and I thank you for your focus and perseverance, but can we just say that that is pretty cool.












































