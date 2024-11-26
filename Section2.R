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
# What's even better is that you don't need to specify he argument names
map














































































