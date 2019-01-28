## First need to install Praat
#Linux: sudo apt-get install praat
#Mac: brew cask install praat (if you have homebrew)
#Windows: http://www.fon.hum.uva.nl/praat/download_win.html
library(tidyverse)
library(rPraat)
library(retimer) #devtools::install_github("abeith/retimer")

# Extract Pitch Tier
praatSys(paste("D03_maths_extract", "audio", "\\"))

# Resynthesise without changing anything to compare later
file.copy("./outputs/D03_maths_extract.PitchTier", "./outputs/D03_maths_extract_reSynth.PitchTier")
praatSys(paste("D03_maths_extract", "reSynth", "/"), "reSynthPitch.praat")

## Manipulations

# Resynthesise with flat F0 at peak frequency (default)
flatF0("D03_maths_extract")

# With flat F0 at minimum frequency
flatF0("D03_maths_extract", min)

# With half F0 range
convertAudio("D03_maths_extract")

# With quarter F0 range
convertAudio("D03_maths_extract", 0.25)

# With inverted melody
convertAudio("D03_maths_extract", -1)

# Factor = 1: Should be the same as first resynthesis
convertAudio("D03_maths_extract", 1)

## Checks

# Check synthesis: Extract Pitch Tiers from all wav files
list.files("./outputs", pattern = "D03_maths.*wav") %>%
  str_remove(".wav") %>%
  map(~praatSys(args = paste(.x, "outputs", "\\")))

# Get musical interval breaks (12-TET)
breaks <- pianoScale() %>% 
  filter(!str_detect(notes, "#"))

# Plot all contour manipulations
pt.compare("./outputs", "D03") %>%
  filter(!str_detect(id, "extract$|reSynth")) %>%
  mutate(tone = freqToTones(f, 440)) %>%
  ggplot(aes(t, tone)) +
  geom_line() +
  scale_y_continuous(breaks = breaks$tones, labels = breaks$notes) +
  theme(panel.grid.minor.y = element_blank()) +
  facet_grid(id ~ .)

# Plot all densities
pt.compare("./outputs", "D03") %>%
  filter(!str_detect(id, "extract$|reSynth")) %>%
  mutate(tone = freqToTones(f, 440)) %>%
  ggplot(aes(tone)) +
  geom_density() +
  scale_y_continuous(breaks = breaks$tones, labels = breaks$notes) +
  theme(panel.grid.minor.x = element_blank()) +
  facet_grid(id ~ .)


## Compare plots for original and resynthesis without manipulation
pt.compare("./outputs", "D03_maths_extract") %>%
  filter(str_detect(id, "extract$|extract_1$|reSynth")) %>%
  mutate(tone = freqToTones(f, 440)) %>%
  ggplot(aes(t, tone, colour = id)) +
  geom_line(position = "jitter") +
  scale_y_continuous(breaks = breaks$tones, labels = breaks$notes) +
  theme(panel.grid.minor.y = element_blank())

pt.compare("./outputs", "D03_maths_extract") %>%
  filter(str_detect(id, "extract_1$|extract_-1$")) %>%
  mutate(tone = freqToTones(f, 440)) %>%
  ggplot(aes(t, tone, colour = id)) +
  geom_line() +
  scale_y_continuous(breaks = breaks$tones, labels = breaks$notes) +
  theme(panel.grid.minor.y = element_blank())
