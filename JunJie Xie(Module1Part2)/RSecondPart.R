#library

install.packages("tm")
install.packages("stringr")
install.packages("wordcloud")
install.packages("Snowball")
install.packages("slam")
install.packages("quanteda")
install.packages("arules")
install.packages("proxy")
install.packages("tidytext")
install.packages("plyr")
install.packages("factoextra")
install.packages("mclust")
install.packages("gofastr")

library(tm)
library(stringr)
library(wordcloud)
library(slam)
library(quanteda)
library(SnowballC)
library(arules)
library(proxy)
library(cluster)
library(stringi)
library(proxy)
library(Matrix)
library(tidytext) # convert DTM to DF
library(plyr) ## for adply
library(ggplot2)
library(factoextra) # for fviz
library(mclust) # for Mclust EM clustering
library(gofastr)   ## for removing your own stopwords


## load in the documents (the corpus)
# "/Users/junjiexie/Downloads/FedPapers"
dir = getwd()
NovelsCorpus_path = paste(dir, "/Downloads/FedPapers", sep = "")
NovelsCorpus <- Corpus(DirSource(NovelsCorpus_path))
(getTransformations())
(ndocs<-length(NovelsCorpus))

##The following will show you that you read in all the documents
(summary(NovelsCorpus))
(meta(NovelsCorpus[[1]]))
(meta(NovelsCorpus[[1]],5))

# ignore extremely rare words i.e. terms that appear in less then 1% of the documents
(minTermFreq <- ndocs * 0.0001)

# ignore overly common words i.e. terms that appear in more than 50% of the documents
(maxTermFreq <- ndocs * 1)

(MyStopwords <- c("maggie", "philip", "tom", "glegg", "deane", "stephen","tulliver","and","but"))
#stopwords))

Novels_dtm <- DocumentTermMatrix(NovelsCorpus,
                                 control = list(
                                   stopwords = TRUE, 
                                   wordLengths=c(4, 10),
                                   removePunctuation = TRUE,
                                   removeNumbers = TRUE,
                                   tolower=TRUE,
                                   #stemming = F,
                                   #stemWords=TRUE,
                                   remove_separators = TRUE,
                                   #stem=TRUE,
                                   stopwords("english"),
                                   bounds = list(global = c(minTermFreq, maxTermFreq))
                                 ))

# Remove more stopwords
(remove_stopwords(Novels_dtm, stopwords = MyStopwords))

## Have a look
Novels_dtm <- weightTfIdf(Novels_dtm, normalize = TRUE)

## Look at word freuqncies
(WordFreq <- colSums(as.matrix(Novels_dtm)))
# print out the top 10 most frequent words（task2）
(head(sort(WordFreq, decreasing = TRUE), n=10))

(length(WordFreq))
ord <- order(WordFreq)
(WordFreq[head(ord)])
(WordFreq[tail(ord)])

## Create a normalized version of Novels_dtm
Novels_M <- as.matrix(Novels_dtm)
Novels_M_N1 <- apply(Novels_M, 1, function(i) i/sum(i))
## transpose
Novels_Matrix_Norm <- t(Novels_M_N1)

#create a labeled data frame and a matrix（task1）
(Novels_M[c(1:85),c(1:5)])

## Convert to matrix and view
Novels_dtm_matrix = as.matrix(Novels_dtm)
str(Novels_dtm_matrix)
(Novels_dtm_matrix[c(1:3),c(2:4)])

#count the number of words in each document(task3)
getNumberWords = function(data) {
  n = ncol(data)
  for(row in rownames(data)) {
    count = 0
    for(col in 1:n) {
      if(data[row,col] != 0) {
        count = count + 1
      }
    }
    cat("The word number of", row, "is\t" )
    cat(count,"\n")
  }
}

getNumberWords(Novels_dtm_matrix)






# get Hamilton matrix
temp = t(Novels_dtm_matrix)
Hamilton = str_detect(colnames(temp),"Hamilton")
Hamilton_dtm_matrix = t(subset(x=temp,select=Hamilton))
#Hamilton_dtm_matrix = (Novels_dtm_matrix[c(12:62),c(1:6953)])

# get Madison matrix
Madison = str_detect(colnames(temp),"Madison")
Madison_dtm_matrix = t(subset(x=temp,select=Madison))

## Also convert to DF
Novels_DF <- as.data.frame(as.matrix(Novels_dtm))
str(Novels_DF)
(Novels_DF$said)
(nrow(Novels_DF))

#Hamilton wordcloud(task4)
wordcloud(colnames(Hamilton_dtm_matrix), Hamilton_dtm_matrix, max.words = 200)
#Madison wordcloud(task4)
wordcloud(colnames(Madison_dtm_matrix), Madison_dtm_matrix, max.words = 200)


