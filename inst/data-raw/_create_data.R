# source ("_create_data.R")

# Load raw data from .csv file
proteins21 <- read.csv("proteins21.csv")
# Apply preprocessing...
# Save the cleaned data in the required R package location
save(proteins21,file ="../data/proteins21.rda")
