#So far, we have only been looking at nice datasets from libraries
#How does this compare to real life? It depends...

# Let's look at two datasets
# https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025429%2F1493899967
# https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025429%2F1493900249

# We need libraries, eventually:
library(tidyverse)

# Where are we?
getwd()

read_csv("cro.csv") # what's wrong? what do we do?
spec(cro)
glimpse(cro)

table(cro$organizace)
table(cro$tituly)

tlumocnici <- read_csv("tlumocnici.csv")
# That doesn't seem right
tlumocnici <- read_csv2("tlumocnici.csv")
problems(tlumocnici)
tlumocnici %>% slice(c(...))

# What could interest us, is the number of licensed persons
count(tlumocnici)
length(unique(tlumocnici$IČO))

# And perhaps more usefully, how many translators, are in each language, we could even visualize it
# What we need is a function, which takes a delimiter argument, and uses it generate another row for each of the elements
# This is where it is very useful to consult with an LLM
?separate_longer_delim
tlumocnici %>% separate_longer_delim(cols = "Jazyky", delim = "|") %>% View()

#Victory?
tlumocnici %>% 
  separate_longer_delim(cols = "Jazyky", delim = "|") %>%
  group_by(Jazyky) %>%
  summarize(count = n()) %>%
  View()

# Discrimination - 
# arrange(Jazyky, .locale = "cs")
library(stringi)

pocet_opravneni <- tlumocnici %>%
  separate_longer_delim(cols = "Jazyky", delim = "|") %>%
  group_by(Jazyky) %>%
  summarize(Počet = n()) %>%
  arrange(Jazyky, .locale = "cs") #%>%
  View()

pocet_opravneni %>%
ggplot(aes(x = reorder(Jazyky, Počet), y = Počet, fill = Jazyky)) + 
  geom_bar(stat = "identity", width = 0.6, show.legend = FALSE) +  
  geom_text(aes(label = Počet), vjust = -0.5, size = 5, fontface = "bold") +  # Labels on bars
  labs(
    title = "Tlumočnická oprávnění",
    subtitle = "",
    x = "Jazyky",
    y = "Počet",
    caption = "Zdroj: Ministerstvo spravedlnosti"
  ) +
  theme_minimal(base_size = 14) +  # Clean theme with larger text
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 12),
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    panel.grid.minor = element_blank()
  ) +
  coord_flip()
