library(tidyverse)
library(pdftools)
library(stringr)
library(tidytext)
library(tm)

#REFERENCES
#https://data.library.virginia.edu/reading-pdf-files-into-r-for-text-mining/
#https://cran.r-project.org/web/packages/tidytext/vignettes/tidying_casting.html

getwd()
setwd("~/Sentiment_SR")
#files <- list.files(path=getwd())

#pdf_file <- file.path("CSV19_nestle.pdf")


#get all pdfs in working directory
files <- list.files(pattern = "pdf$")



#Read pdf corpus, every string is a page, split in lines
#corpus <- lapply(files, pdf_text)
#length(corpus)
#lapply(corpus, length) 

#read in the corpus
corp <- VCorpus(URISource(files),
               readerControl = list(reader = readPDF))

corp <- tm_map(corp, removeNumbers)


#create term-document matrix TDM:(bounds werkte niet met 3, dus aar 1 gezet, toen werkte het wel(.))
sr.tdm <- TermDocumentMatrix(corp, 
                                   control = 
                                     list(removePunctuation = TRUE,
                                          stopwords = TRUE,
                                          tolower = TRUE,
                                          stemming = TRUE,
                                          removeNumbers = TRUE,
                                          bounds = list(global = c(1, Inf)))) 
write.csv(sr.tdm, "tdm.csv")
#inspecteren
inspect(sr.tdm) 

#frequencies
findFreqTerms(sr.tdm, lowfreq = 100, highfreq = Inf)

#zoeken naar bepaalde woorden

#my_words <- c("africa", "ghana", "ivoire", "burkina", "mali", "niger", "congo", "chad", "senegal", "nigeria", "hygiene", "potable", "detergent", "maggi")
LDC <- read_csv("LDC.txt", col_names = FALSE) 
#LDC<- tm.map(LDC, tolower)

my_words <- unlist(LDC) %>% str_to_lower() #niet vergeten de hoofdletters naar kleine letters om te zetten.


sr.dtm <- DocumentTermMatrix(corp, control=list(dictionary = my_words))
inspect(sr.dtm)

#tidying the Document-Term Matrix
td_sr <- tidy(sr.dtm)
str(td_sr)
td_corp <- tidy(corp) 
write.csv(td_sr, "td.csv")

read.csv("td.csv")
td_sr %>% ggplot(aes(term, count, fill = document)) +
  geom_bar(stat = "identity") + coord_flip() +
  theme_light()

words <- iconv(corp, "ASCII", "UTF-8", sub="byte") %>% tidy()
del(words)
str(words)

td_bi <- td_corp %>% unnest_tokens(bigram, text, token = "ngrams", n = 3, stopwords = TRUE)
td_bi %>% select(id, bigram) 
