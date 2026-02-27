# Key sources and acknowledgements:
# Nathaniel D. Phillips. (2018). YaRrr! The Pirate’s Guide to R.  https://bookdown.org/ndphillips/YaRrr/
# Wickham, H., Çetinkaya-Rundel, M., & Grolemund, G. (2023). R for Data Science: Import, tidy, transform, visualize, and model data. O’Reilly. 
# https://r4ds.hadley.nz
# Without these publications the course would not be possible


# Part 4. Tidy Data  ------------------------------------------------------
# Paper by Hadley Wickham http://vita.had.co.nz/papers/tidy-data.pdf
# Principles:
# 1. Each variable forms a column.
# 2. Each observation forms a row.
# 3. Each type of observational unit forms a table

# Problem #1 - String data in column names

relig_income

# Now we pivot

relig_income %>%
  pivot_longer(
    cols = !religion, # The columns we want to expand, not religion
    names_to = "income", # Where we put the data in column names
    values_to = "count", # How we call the values 
  ) %>%
  View()

# Problem #2 - Numeric data in column names

billboard

# More pivoting
billboard %>% 
  pivot_longer(
    cols = starts_with("wk"), # Chooses columns to pivot
    names_to = "week", # New name
    names_prefix = "wk", # Eliminates part of the former name, a prefix
    names_transform = as.integer, # Transforms into an integer
    values_to = "rank", # How we call the values
    values_drop_na = TRUE # Drop NAs - we are not interested in the weeks it was not top 100
  ) %>%
  View()

# Problem #3 - Many variables in column names 

who
?who

who %>% 
  pivot_longer(
    cols = new_sp_m014:newrel_f65, # Range of columns
    names_to = c("diagnosis", "gender", "age"), # New column names  
    names_pattern = "new_?(.*)_(.)(.*)", # Regular expression - more on that later
    values_to = "count" # How we call the new values
  )

# We can add another step, because the diagnosis is not clear like this

who %>% 
  pivot_longer(
    cols = new_sp_m014:newrel_f65, # Range of columns
    names_to = c("diagnosis", "gender", "age"), # New column names  
    names_pattern = "new_?(.*)_(.)(.*)", # Regular expression - more on that later
    values_to = "count" # How we call the new values
  ) %>%
  mutate(diagnosis = case_when(
    diagnosis == "rel" ~ "relapse",
    diagnosis == "sn" ~ "negative pulmonary smear",
    diagnosis == "sp" ~ "positive pulomary smear",
    diagnosis == "ep" ~ "extrapulmonary"
  ))

# Fix the age range to be more legible too.

# Problem #4 Multiple observations per row

household

  household %>% 
  pivot_longer(
    cols = !family, 
    names_to = c(".value", "child"), 
    names_sep = "_", 
    values_drop_na = TRUE
  )

# Problem #5 One observation over multiple rows 

trestne_ciny <- read.csv2("tc_rev.csv") %>%
  as_tibble()

# Behold the crime against tidy data
trestne_ciny

# Strenously, we fix it 
widened <- trestne_ciny %>%
  select(Dotazník...ID, Poradie.zápisu, Paragraf.Tr..zák.) %>%
  distinct() %>%
  pivot_wider(id_cols = Dotazník...ID,
              names_from = Poradie.zápisu,
              names_prefix = "TČ.",
              values_from = c(Paragraf.Tr..zák.))

# Which concurrences are common ?

widened %>%
  select(-Dotazník...ID) %>%
  group_by_all() %>%
  filter(!is.na(TČ.2)) %>%
  count(sort = TRUE) %>%
  relocate(n, .before = TČ.1) %>%
  view()


# Part 5. Become a manipulator (of strings) -------------------------------
# https://github.com/rstudio/cheatsheets/blob/main/strings.pdf
install.packages("babynames")
library(babynames)

# Unleash your power

# Concatenate with str_c

str_c("Hello", "there.", "\n", "General", "Kenobi!", sep = " ") %>%
  str_view()

# Glue with str_glue

df <- tibble(name = c("Flora", "David", "Terra", NA))

df

df %>%
  mutate(greeting = str_glue("Hi {name}!")) # Between the {} we can reference.

# Flatten with str_flatten

df <- tribble(
  ~ name, ~ fruit,
  "Carmen", "banana",
  "Carmen", "apple",
  "Marvin", "nectarine",
  "Terence", "cantaloupe",
  "Terence", "papaya",
  "Terence", "mandarin"
)
df %>%
  group_by(name) %>%
  summarize(fruits = str_flatten(fruit, ", "))

# Separate strings into more rows 

# By delimiters
df1 <- tibble(x = c("a,b,c", "d,e", "f"))
df1 |> 
  separate_longer_delim(x, delim = ",")

# By width
df2 <- tibble(x = c("1211", "131", "21"))
df2 |> 
  separate_longer_position(x, width = 1)


# Separate string into more columns
# By delimiters
df3 <- tibble(x = c("a10.1.2022", "b10.2.2011", "e15.1.2015"))
df3 |> 
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", "edition", "year")
  )

# By position
df4 <- tibble(x = c("202215TX", "202122LA", "202325CA")) 
df4 |> 
  separate_wider_position(
    x,
    widths = c(year = 4, age = 2, state = 2)
  )


# By individual letters ---------------------------------------------------

# Let's count length
str_length(c("a", "R for data science", NA))

# And find some weird names
babynames |>
  count(length = str_length(name), wt = n)

babynames |> 
  filter(str_length(name) == 15) |> 
  count(name, wt = n, sort = TRUE)

# Let's subset

x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
str_sub(x, -3, -1)

# And find the first and last letter of all names
babynames |> 
  mutate(
    first = str_sub(name, 1, 1),
    last = str_sub(name, -1, -1)
  )

# And deal with some Czech fun

str_sort(c("a", "c", "ch", "h", "z"))
str_sort(c("a", "c", "ch", "h", "z"), locale = "cs")



# Part 6. Not so regular expressions --------------------------------------

# Regular expressions are a powerful tool in finding strings.
# A regular expression is an abstracted pattern that can be matched with text.
# Example - an email address is always structured as:
# [letters, numbers, dots, underscores]@[letters and numbers].[letters and dots]
# If we want to extract e-mail addresses from text, we need to make the above into a regular expression.
# https://spannbaueradam.shinyapps.io/r_regex_tester/
# Also check ?regex

# Pattern match berry
str_view(fruit, "berry")

# Introduce the metacharacters
# . means any character

str_view(fruit, "a...e")

# ? makes a pattern optional (i.e. it matches 0 or 1 times)
# + lets a pattern repeat (i.e. it matches at least once)
# * lets a pattern be optional or repeat (i.e. it matches any number of times, including 0).

str_view(c("a", "ab", "abb"), "ab?")
str_view(c("a", "ab", "abb"), "ab+")
str_view(c("a", "ab", "abb"), "ab*")

# Character classes are defined by [] and let you match a set of characters, e.g., 
# [abcd] matches “a”, “b”, “c”, or “d”. 
# You can also invert the match by starting with ^: 
# [^abcd] matches anything except “a”, “b”, “c”, or “d”.

str_view(words, "[aeiou]x[aeiou]")
str_view(words, "[^aeiou]y[^aeiou]")

# '|' allows for alternation - once again meaning OR
str_view(fruit, "apple|melon|nut")
str_view(fruit, "aa|ee|ii|oo|uu")


# Making use of regular expressions ---------------------------------------

# str_detect() return TRUE if the pattern matches an element of the character vector and FALSE otherwise
str_detect(c("a", "b", "c"), "[aeiou]")

# Very useful to pair with filter. What does this code do?
babynames %>%
  filter(str_detect(name, "x")) %>%
  count(name, wt = n, sort = TRUE)

# We can also use if with summarize and visualize it no less.
babynames %>%
  group_by(year) %>%
  summarize(prop_x = mean(str_detect(name, "x"))) %>% # The mean of a logical vector = proportion of True to False cases
  ggplot(aes(x = year, y = prop_x)) + 
  geom_line()

# str_count tells you how many times the pattern is matched in the string

x <- c("apple", "banana", "pear")
str_count(x, "p")

# Once a match is found, the pattern seeker moves on to the right, so matches do not overlap.
str_count("abababa", "aba")
str_view("abababa", "aba")

# Let's count some vowels in babynames
babynames %>% 
  count(name) %>% 
  mutate(
    vowels = str_count(name, "[aeiou]"),
    consonants = str_count(name, "[^aeiou]")
  )

# Is that correct?

babynames %>% 
  count(name) %>% 
  mutate(
    vowels = str_count(name, "[aeiouAEIOU]"),
    consonants = str_count(name, "[^aeiouAEIOU]")
  )

# One way to solve. You could also use str_to_lower on name.

# As well as detecting and counting matches, we can also modify them with str_replace() and str_replace_all(). 
# str_replace() replaces the first match
# str_replace_all() replaces all matches.

x <- c("apple", "pear", "banana")
str_replace_all(x, "[aeiou]", "-")

# str_remove_all() is nice shorthand for str_replace_all(x, pattern, "")
x <- c("apple", "pear", "banana")
str_remove_all(x, "[aeiou]")

# This is used mainly when the formatting of the data has some unnecessary characters.

# Time for some extraction:

df <- tribble(
  ~str,
  "<Sheryl>-F_34",
  "<Kisha>-F_45", 
  "<Brandon>-N_33",
  "<Sharon>-F_38", 
  "<Penny>-F_58",
  "<Justin>-M_41", 
  "<Patricia>-F_84", 
)

df %>%
  separate_wider_regex(
    str,
    patterns = c(
      "<", 
      name = "[A-Za-z]+", 
      ">-", 
      gender = ".",
      "_",
      age = "[0-9]+"
    )
  )


# More advanced Regex -----------------------------------------------------
# Only some more advanced Regex is introduced here for the example above
# If you want to learn more: https://r4ds.hadley.nz/regexps


# When you want to match a meta-character, you have to escape it.
# Because of nasty R shenanigans, we need to double escape it with \\

str_view(c("abc", "a.c", "bef"), "a\\.c")

# Now let's find the e-mails in this text
pancakes <- read_lines("pancakes.txt")

email_pattern <- ""

str_view(pancakes, pattern = email_pattern)

# End of Lesson 3. Next we do joins and visualization.