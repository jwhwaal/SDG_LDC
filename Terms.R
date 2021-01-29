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


#IMPORT FORBES 2000 (2017)
library(readxl)
SDG_Forbes17 <- read_excel("SDG_Forbes17.xlsx")
fb <- SDG_Forbes17
check <- fb %>% select(GICS4, sectorname) %>% group_by(GICS4)

#convert numerical values to factors
fb$GICS4 <- as.factor(fb$GICS4)
fb$gri4 <- as.factor(fb$gri4)
fb$aa1000 <- as.factor(fb$aa1000)
fb$iirc <- as.factor(fb$iirc)
fb$gl <- as.factor(fb$gl)
fb$ass <- as.factor(fb$ass)
fb$ir <- as.factor(fb$ir)
fb$gc <- as.factor(fb$gc)
fb$newsam <- as.factor(fb$newsam)

#make new variables
fb1 <- fb %>% mutate(GICS2 = as.factor(substr(fb$GICS4,1,4)), 
                     GICS1 = as.factor(substr(fb$GICS4,1,2)),
                     size = log10(marketvalue), 
                     s = log10(sdgf),
                     p = log10(pages),
                     sdg = ifelse(sdgf>0,1,0))

#make various plots
fb1 %>% ggplot(aes(sdgf, GICS2)) + geom_boxplot()
fb1 %>% ggplot(aes(sdgf, GICS2)) + geom_bar(stat = "identity")
fb1 %>% filter(pages>0) %>% ggplot(aes(pages, GICS2)) + geom_boxplot()
fb1 %>% filter(pages>0 & iirc == 0) %>% ggplot(aes(pages)) + geom_histogram(binwidth = 25)

fb1 %>% ggplot(aes(size, GICS2)) + geom_boxplot()
fb1 %>% ggplot(aes(size, GICS4)) + geom_boxplot()
fb1 %>% filter(sdgf>0) %>% ggplot(aes(s, countrygrpname)) + geom_boxplot()
fb1 %>% filter(sdgf>0) %>% ggplot(aes(s, GICS2)) + geom_boxplot()
fb1 %>% filter(sdgf>0) %>% ggplot(aes(sdgf, newsam)) + geom_boxplot() 
fb1 %>% filter(sdgf>0) %>% ggplot(aes(s, GICS1)) + 
  geom_boxplot() + 
  facet_grid(gc ~ countrygrpname)
fb1 %>% filter(sdgf>0) %>% ggplot(aes(size, s, color = GICS1 )) +
                                    geom_point() +
                                    facet_wrap( ~ countrygrpname)
fb1 %>% filter(sdgf>0) %>% ggplot(aes(p, s, color = GICS1 )) +
  geom_point() 
fb1 %>% filter(sdgf>0) %>% ggplot(aes(uai, s, color = countrygrpname )) +
  geom_point() 

#check problems with GICS-classification (NAs)
fb1 %>% select(pkcompany, GICS4) %>% filter(is.na(GICS4))
