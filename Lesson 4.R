# Part 7. Joins -------------------------------------------------------------------

# So imagine that the data is not in one table.

library(tidyverse)
library(nycflights13)

flights
planes
airports
weather
airlines

# Let's talk about keys
# https://r4ds.hadley.nz/diagrams/relational.png

flights2 <- flights %>%
  select(year, time_hour, origin, dest, tailnum, carrier)

# https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

# The purpose of the left join is that is adds additional data to the rows of the origin (left) table
# Find the full name of the airlines
flights2 %>%
  left_join(airlines)

left_join(flights2, airlines, by = "carrier")

# Find the temperature and wind speed on departure
flights2 %>% 
  left_join(weather %>% select(origin, time_hour, temp, wind_speed))

# Find the size of the plane
flights2 %>% 
  left_join(planes %>% select(tailnum, type, engines, seats))

# So far we have not been specifying keys. But what if columns have the same names and mean different things.

flights2 %>% 
  left_join(planes)

# Year means different things, so we need to specify we only care about the tail number
flights2 %>% 
  left_join(planes, join_by(tailnum))

# Keys can have different names, and therefore different results as well 
flights2 %>% 
  left_join(airports, join_by(dest == faa))

flights2 %>% 
  left_join(airports, join_by(origin == faa))

# Right join, inner join and outer join work similarly in code but have a different relationship between the
# joining tables. Best shown visually.

# A semi-join is a filtering join. It only keeps the rows of the left table, that have a match in the right table.
# It doesn't actually join the tables.

airports %>% 
  semi_join(flights2, join_by(faa == origin))

airports %>% 
  semi_join(flights2, join_by(faa == dest))

# An anti-join filters conversely. It only keeps the rows of the left table, that DO NOT HAVE a match in the right table.

# Airports we have no metadata on
flights2 %>% 
  anti_join(airports, join_by(dest == faa)) %>% 
  distinct(dest)

# Airplanes we have no metadata on
flights2 %>%
  anti_join(planes, join_by(tailnum)) %>% 
  distinct(tailnum)

# And that's it for joins. For much more detail look at: https://r4ds.hadley.nz/joins



# Part 8. Visualization ---------------------------------------------------

install.packages("palmerpenguins")
install.packages("ggthemes")
library(palmerpenguins)
library(ggthemes)

# https://r4ds.hadley.nz/data-visualize_files/figure-html/unnamed-chunk-7-1.png
glimpse(penguins)

ggplot(data = penguins) # What data are we looking at

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g) # What axes do we want
)

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()  # Add a geom - geometrical object to represent our data 

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species) # We add a color aesthetic
) +
  geom_point()


ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm") # We add a linear model

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g) # We only want colors to affect points, so we move from global
) +
  geom_point(mapping = aes(color = species)) + # To only having it locally for the geom_point
  geom_smooth(method = "lm")

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) + # Now we add shapes
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) + # Labs makes sure have nice labels for the graph
  scale_color_colorblind() # Colorblind theme helps communicate our data

# Ta-daa, now we can put it in a paper

# The typical way to call ggplot is

penguins %>% # data pipe
  ggplot(aes(x = flipper_length_mm, y = body_mass_g)) + # ggplot(aes()) +
  geom_point() # geoms, labs, themes and scales on separate lines

# Visualizing distributions
# For categorical variables like species, we like bar charts
ggplot(penguins, aes(x = species)) +
  geom_bar()

# For numerical variables like body mass, we like histograms
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)

# We can also look at density
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density()

# A lot of the time, however, we are interested in looking at the relationship between variables

# When we have a categorical (species) and a numeric (mass), we like boxplots
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()

# Or we can one again use density
ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.5)

# For two categorical variables, we can use a stacked boxplot

ggplot(penguins, aes(x = island, y = species)) +
  geom_count()

# For two numerical variables, we like to use scatterplots

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

# Even more variables, specifically 2 numeric and 2 categorical

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island))

# Facets can help make things clearer
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) +
  facet_wrap(~island)

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species), size = 3.5, alpha = 0.5) +  # Larger, semi-transparent points
  facet_wrap(~island) +  # Faceting by island
  scale_color_manual(values = c("Adelie" = "#1f77b4", "Chinstrap" = "#ff7f0e", "Gentoo" = "#2ca02c")) +  # Custom colors
  theme_minimal(base_size = 15) +  # Clean theme with bigger text
  labs(
    title = "Penguin Flipper Length vs. Body Mass",
    subtitle = "Grouped by species & faceted by island",
    x = "Flipper Length (mm)",
    y = "Body Mass (g)",
    color = "Species",
    shape = "Species"
  ) +
  theme(
    strip.text = element_text(size = 16, face = "bold"),  # Bigger facet labels
    plot.title = element_text(hjust = 0.5, face = "bold", size = 20),  # Centered title
    axis.title = element_text(size = 16),  # Bigger axis labels
    axis.text = element_text(size = 14),  # Bigger tick labels
    legend.position = "top",  # Move legend to the top for better readability
    legend.text = element_text(size = 14)
  )
# Data visualization is a skill that requires patience, practice and reading the documentation.
# The cheatsheet provided at the beginning of this lesson is rather helpful in this.
# You can also read: https://ggplot2-book.org