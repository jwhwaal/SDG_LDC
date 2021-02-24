library(tidyverse)
names <- c( "fonds")
MSCI_EU_nonfin <- MSCI_EU_nonfin %>%  select(X1)
MSCI_EFM_Africa <- MSCI_EFM_Africa %>% select(X1)
colnames(MSCI_EU_nonfin) <- names
colnames(MSCI_EFM_Africa) <- names
write.csv(MSCI_EU_nonfin, "MSCI_EU_nonfin")
write.csv(MSCI_EFM_Africa, "MSCI_EFM_Africa")

