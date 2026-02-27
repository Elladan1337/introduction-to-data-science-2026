# Key sources and acknowledgements:
# Nathaniel D. Phillips. (2018). YaRrr! The Pirate’s Guide to R.  https://bookdown.org/ndphillips/YaRrr/
# Wickham, H., Çetinkaya-Rundel, M., & Grolemund, G. (2023). R for Data Science: Import, tidy, transform, visualize, and model data. O’Reilly. 
# https://r4ds.hadley.nz
# Without these publications the course would not be possible


# Part 1. The Big Picture -------------------------------------------------

# Installs the yarrr package. Packages are extensions that expand our possibilities.
# They do so mainly by adding functions (explained later). Now we however use it for data.
# You only have to install a package once.
install.packages('yarrr')

# Load the package
library(yarrr)

# Look at the first few rows of the data
head(pirates)

# What are the names of the columns?
names(pirates)

# View the entire dataset in a new window
View(pirates)

# Documentation
?pirates

# What is the mean age?
mean(pirates$age)

# What was the tallest pirate?
max(pirates$height)

# How many pirates are there of each sex?
table(pirates$sex)

# Calculate the mean age, separately for each sex
aggregate(x = age ~ sex,
          data = pirates,
          FUN = mean)

# But should it not be gender instead?
# What to do?
colnames(pirates)[colnames(pirates) == "sex"] <- "gender"
View(pirates)
# WHAT?!
# This is the code that you can find by google (or generated)
# But you don't understand it, which is a problem - if anything goes wrong


# Let's see what we've got ------------------------------------------------

# Create a basic scatterplot
plot(x = pirates$height,        # X coordinates
     y = pirates$weight)        # y-coordinates

# Create a nicer scatterplot
plot(x = pirates$height,        # X coordinates
     y = pirates$weight,        # y-coordinates
     main = 'My first scatterplot of pirate data!',
     xlab = 'Height (in cm)',   # x-axis label
     ylab = 'Weight (in kg)',   # y-axis label
     pch = 16,                  # Filled circles
     col = gray(.0, .1))        # Transparent gray

# Create a very nice scatterplot
plot(x = pirates$height,        # X coordinates
     y = pirates$weight,        # y-coordinates
     main = 'My first scatterplot of pirate data!',
     xlab = 'Height (in cm)',   # x-axis label
     ylab = 'Weight (in kg)',   # y-axis label
     pch = 16,                  # Filled circles
     col = gray(.0, .1))        # Transparent gray

grid()        # Add gridlines

# Create a linear regression model
model <- lm(formula = weight ~ height, 
            data = pirates)

abline(model, col = 'blue')      # Add regression to plot

# Create a kind of boxplot called "Pirateplot"
pirateplot(formula = age ~ sword.type, 
           data = pirates,
           main = "Pirateplot of ages by favorite sword")

pirateplot(formula = height ~ gender,               # Plot weight as a function of gender
           data = pirates,                       
           main = "Pirateplot of height by gender",
           pal = "pony",                         # Use the info color palette
           theme = 3)                            # Use theme 3

# Into hypothesis testing -------------------------------------------------

# Age by headband t-test
t.test(formula = age ~ headband,
       data = pirates,
       alternative = 'two.sided')

#Height - Weight correlation test
cor.test(formula = ~ height + weight,
         data = pirates)


# Create tattoos model
tat.sword.lm <- lm(formula = tattoos ~ sword.type,
                   data = pirates)

# Get ANOVA table
anova(tat.sword.lm)

# Create a linear regression model: DV = tchests, IV = age, weight, tattoos
tchests.model <- lm(formula = tchests ~ age + weight + tattoos,
                    data = pirates)

# Show summary statistics
summary(tchests.model)


# Part 2. Where we start comprehending what we just did -------------------

# Variables ---------------------------------------------------------------

# Integer
a = 0L
integer <- 12L
a <- 0L
# Whole numbers	e. g. 1, 100, -9

# Numeric
b <- 0
# Decimals	0.1, -0.09, 234.567

# Character
c <- "a" 
# Text	“A”, “hello”, “welcome”

# Logical
d <- TRUE
# Booleans TRUE or FALSE

a
b
c
d

# Let's go back to pirates

View(pirates)


# Copying and modifying --------------------------------------------------

# Create a variable
e <- 1
e

# Copy a variable
f <- e
f

# Modify a variable
e
e <- 2
e
f

# Functions ---------------------------------------------------------------
# R is a functional language. Programmers don't like it.
# R is a functional language. Researchers like it!

print("Hello world!")

# Congratulations, you are a ~~wizard~~ programmer

# R is a calculator!

1 / 200 * 30
(59 + 73 + 2) / 3

a <- 59
b <- 73
c <- 2
d <- 3

(a + b + c) / d

# Functions take input(s) and return something

add <- function(x, y){
  x + y
}

add(76, 37)
add(e, f)
e + f

# Maybe this function isn't very useful, but it's our function

# A more useful function?

spocti.odmenu <- function(odmena_ukon, plny_ukon, pul_ukon){
  (plny_ukon * odmena_ukon) + 
    (pul_ukon * odmena_ukon) * 0.5 +
    (300 * (plny_ukon + pul_ukon))
}

spocti.odmenu(odmena_ukon = 1500, plny_ukon = 6, pul_ukon = 2)

# Not extremely helpful, but you get the idea.
# For the most part, however, you will be using already existing functions
# Many functions however take VECTORS as an input


# Switching types ---------------------------------------------------------

# Let's try changing variable types
as.numeric("0")
as.character(0)
as.numeric("ab")
as.character(TRUE)
as.logical("0")
as.logical(0)
as.integer(0.4)
as.integer("0.4")

# Some work, some don't. Sometimes we have to change things up.

"1" + "1"
as.numeric("1") + as.numeric("1")

# Now write a function that calculates BMI from height and weight,
# which will not break if I give it a string number like "20".

bmi <- function(height, weight){
  height <- as.numeric(height)
  weight <- as.numeric(weight)
  weight / ((height / 100) ^ 2) 
}


# Vectors -----------------------------------------------------------------

# A vector is an ordered group of variables of the same kind
# or 1D collection of variables of the same type
# or a combination of several scalars stored as a single object.

c(1, 4, 7)

# We can assign vectors

# Combine
numbers <- c(1, 4, 7)
numbers

# Range
numbers_2 <- 1:5
numbers_2

# Sequence
numbers_3 <- seq(from = 0, to = 12, by = 4)
numbers_3

# Repetition
numbers_4 <- rep(3, times = 10)
numbers_4

# Vectors of all kinds!

course <- c("Introduction", "to", "data", "science")
byte <- rep(FALSE, times = 8)


# Vectors and Functions !? ------------------------------------------------
# Let's get a vector of data
heights <- pirates$height

# Check it
typeof(heights)

# Manage your memory (you actually don't have to)
heights <- as.integer(heights)
typeof(heights)

# Sum it all
sum(heights)
# The smallest
min(heights)
# The tallest
max(heights)
# The mean
mean(heights)
# The median
median(heights)
# Range in one function
summary(heights)
# Frequencies
table(heights)


# Types of research data --------------------------------------------------

# 1. Continuous
# In R we code them as numeric() i. e. as doubles or integers. 
# 2. Ordinal
# In R we code them as factors with levels

# We simulate some data on the 5-point Likert scale
answers <- c(rep("agree", 100), rep("strongly agree", 100),
             rep("disagree", 100), rep("strongly disagree", 100),
             rep("neutral", 100))

# Take a sample
answers_sample <- sample(answers, 25)

# See what we've got
table(answers_sample)

# The scale is ordinal, however
likert_scale <- c("strongly disagree", "disagree", "neutral", "agree", "strongly agree")

# By using the factor function with the levels set to the likert_scale we fix this
ordinal_answers <- factor(answers_sample, levels = likert_scale)
table(ordinal_answers)

# This will save you a lot of pain when visualizing and modeling
# 3. Categorical
# Simply categories, should be coded as strings
# 4. Missing
# 5. Censored
# We will discuss the difference next time


# And that's it for today