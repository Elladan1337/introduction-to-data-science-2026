# Key sources and acknowledgements:
# Nathaniel D. Phillips. (2018). YaRrr! The Pirate’s Guide to R.  https://bookdown.org/ndphillips/YaRrr/
# Wickham, H., Çetinkaya-Rundel, M., & Grolemund, G. (2023). R for Data Science: Import, tidy, transform, visualize, and model data. O’Reilly. 
# https://r4ds.hadley.nz
# Without these publications the course would not be possible


# Part 3. Where we delve deeper -------------------------------------------
# Download our packages
install.packages("tidyverse")
install.packages("nycflights13")

# Load libraries
library(tidyverse)
library(nycflights13)

View(flights)

# Flights is a dataframe
# We like our data in this format, because it's easy to work with
# Our preferred way to work with this data is dplyr: http://127.0.0.1:21965/library/dplyr/doc/dplyr.html

# Rows:
#   filter() chooses rows based on column values.
#   slice() chooses rows based on location.
#   arrange() changes the order of the rows.
# Columns:
#   select() changes whether or not a column is included.
#   rename() changes the name of columns.
#   mutate() changes the values of columns and creates new columns.
#   relocate() changes the order of the columns.
# Groups of rows:
#   summarise() collapses a group into a single row.

# We do like to use the pipe operator %>%
# The pipe operator simply means "and then do the following"

# Behold:

# select() allows for only certain columns to be selected
select(flights, origin, dest) # selects only the airports of origin and destination
relocate(flights, dest) # makes dest to be the first column

# Now to combine them
relocate(select(flights, origin, dest), dest) # Hard to read? Now imagine there's 10 steps.

# Pipe to the rescue
flights %>%               
  select(origin, dest) |>
  relocate(dest)

# Each line takes the output of the previous line as its input, proceeds with the verb

# This is nice, however, so often we want to look for data, by filtering
# And to filter, we have to understand BOOlean logic
# Chapter 12 of R for Data Science covers this


# Boolean Logic -----------------------------------------------------------

TRUE & TRUE
TRUE & FALSE
FALSE & FALSE

TRUE | TRUE
TRUE | FALSE
FALSE | FALSE

! TRUE
! FALSE


# Expressions -------------------------------------------------------------

# Expressions are statements that evaluate either to TRUE or FALSE

1 == 1
1 != 1

"abc" == "cbc"
"abc" != "cbc"

# We can chain these expressions

1 == 1 & "abc" == "abc"
153 * 2 != 306 | sqrt(49) == 7

# Computers are not precise

0.1 + 0.2 == 0.3
print(0.1 + 0.2, digits = 20)

near(0.1 + 0.2, 0.3)

# We can also compare numeric values

5 > 4
5 >= 5
5 < 4
6 <= 7

# Finally we can check against a vector

# A nice vector of colours
colours <- colours()

"gold" %in% colours

"tomato" %in% colours

"pebble" %in% colours

# We could of course do it this way

"pebble" == "gold" | "pebble" == "tomato" | "pebble" == "blue" # etc...

# But we really don't want to


# If, ifelse, case_when ---------------------------------------------------
# We have an expression. If it evaluates to TRUE, we do the stuff in the curly brackets.

if(143 > 100){print("The condition was TRUE")}

x <- 10

if(x >= 20){print("X is greater or equal than 2O")}
if(x >= 10){print("X is greater or equal than 10")}

# Else gives us an alternative, if none of the previous if statements was fulfilled.
if(2 + 2 == 4){
  print("1984 avoided")
}else{
  print("Literally 1984")}

ifelse(2 + 2 == 4, print("1984 avoided"), print("Literally 1984"))
# If else condenses a simple if|else into a single line.
# This is generally quite useful.
# Imagine a dataset where female sex is coded as 1

ifelse(sex == 1, "female", "male")

# Sometimes, however we have a lot of if options, that are exclusive.

test_result <- 73
grade <- ""

if(test_result > 90){
  grade <- "A"
} else if(test_result > 80){
  grade <- "B"
} else if(test_result > 70){
  grade <- "C"
} else if(test_result > 60){
  grade <- "D"
} else if(test_result > 50){
  grade <- "E"
} else{
  grade <- "F"
}

grade

# This hurt to write

grade <- case_when(
  test_result > 90 ~ "A",
  test_result > 80 ~ "B",
  test_result > 70 ~ "C",
  test_result > 60 ~ "D",
  test_result > 50 ~ "E",
  .default = "F"
)

grade

# Still not entirely pleasant, but it is much more legible, and has less brackets
# I recommend using ifelse() and case_when(), unless you are doing something way beyond the scope of this course


# Missing values ----------------------------------------------------------

# Sometimes, data is incomplete, or inapplicable

starwars

# R uses NA to mark missing values

df <- tibble(x = c(TRUE, FALSE, NA))

df %>% 
  mutate(
    and = x & NA,
    or = x | NA
  )

# This might lead to (un)surprising behavior

starwars$hair_color == "blond"

# What if we want to find the NA values
NA == NA
# Even the IDE warns us, actually we want to use the is.na function
is.na(NA)

# Equipped with our newfound skills, we can move on filtering data


# Filter() ----------------------------------------------------------------

# filter keeps the rows that match a condition

# Let's say we only care about characters from Tatooine

starwars %>%
  filter(homeworld == "Tatooine")

# Now we want both Tatooine and Alderaan

starwars %>%
  filter(homeworld == "Tatooine" | homeworld == "Alderaan")

# Now anything but Tatooine

starwars %>%
  filter(homeworld != "Tatooine")

# And we can combine these

starwars %>%
  filter(homeworld == "Tatooine" & species == "Human" & gender == "masculine")

# When choosing what to filter for, it might be useful to glean some more information about the data

starwars %>%
  count(homeworld, sort = TRUE) %>%
  View()

starwars %>%
  count(sex, gender, sort = TRUE)

# However this all depends of the RQs

# Filter flights for all flights departing JFK NYC Airport operated by American Airlines afternoon (past 12:00, THAT INCLUDES 12:00).
flights %>%
  filter(origin == "JFK" & dep_time >= 1200, carrier == "AA") %>%
  View()

# Mutate() ------------------------------------------------------------------

# Mutate changes columns and enables us to add new ones

starwars %>%
  mutate(bmi = mass/((height/100)^2)) %>%
  relocate(bmi, .after = mass) %>%
  view()

# Let's calculate the BMI of the characters. BMI is used because its simple to calculate.
# This script does not endorse blind use of BMI.

starwars_bmi <- starwars %>%
  mutate(bmi = mass/((height/100)^2)) %>%
  relocate(bmi, .after = mass) %>%
  mutate(weight_status = case_when(
    bmi < 18.5 ~ "Underweight",
    bmi < 25 ~ "Healthy weight",
    bmi < 30 ~ "Overweight",
    bmi >= 30 ~ "Obese",
    .default = NA
  )
  ) %>%
  relocate(weight_status, .after = bmi) %>%
  filter(!is.na(bmi))

View(starwars_bmi)

starwars_bmi %>%
  count(sex, gender, weight_status, sort = TRUE)


# Create a speed column for flights, which gives the average speed of the flight in km/h.
flights %>%
  mutate(speed = distance*1.60934/(air_time/60)) %>%
  relocate(speed, 1)

# Write a case_when() statement that uses the month and day columns from flights 
# to label a selection of important  holidays (e.g., New Years Day, 4th of July, Thanksgiving, and Christmas). 
# First create a logical column that is either TRUE or FALSE, 
# and then create a character column that either gives the name of the holiday or is NA.


# Grouping and summarizing ------------------------------------------------

# Let's create some grouped data
by_species <- starwars %>% group_by(species)
by_sex_gender <- starwars %>% group_by(sex, gender)

by_sex_gender %>%
  group_keys

# So what does it do?

summarize(data, mean(mass, na.rm = TRUE))

starwars %>%
  summarize(height = mean(height, na.rm = TRUE))

by_sex_gender %>%
  summarize(mean(height, na.rm = TRUE))

# Summarize compresses the data set to a single line, which is something we like to see.
# When we group the data, it compresses the data set to a single line PER group.
# This allows for comparisons
# However, beware the NA

# Useful functions
#   Center: mean(), median()
#   Spread: sd(), IQR(), mad()
#   Range: min(), max(),
#   Position: first(), last(), nth(),
#   Count: n(), n_distinct()
#   Logical: any(), all()

# Now we can play with grouping and summarizing

# Find the number of flights from each airport
flights %>% 
  group_by(origin) %>% 
  summarize(n())
# Find the mean flight distances per NYC airport in flights
flights %>% 
  group_by(origin) %>% 
  summarize(mean(distance))
# Find the interquartile range of flight time per airline
flights %>%
  group_by(carrier) %>%
  summarize(IQR(air_time, na.rm = TRUE))
# Find the longest delays per airline


# Importing data ----------------------------------------------------------
getwd()

write.csv(flights, "flights.csv")
flights_imported <- read.csv("flights.csv")

# More options

# read.csv2() - semicolon (;) separated values, useful for Czech data
# read_excel() - read in Excel files, might need adjustments
# read_rds() - read in RDS - R files
# read_json() - read in JSON files