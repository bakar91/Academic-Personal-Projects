library(tm)
library(wordcloud)
library(SnowballC)

#File import
text<-read.csv("tourist_accommodation_reviews.csv",header=T)

#Location filter
kamala_s<-subset(text,Location==" Kamala")
kamala_t<-kamala_s$Review 

#Data cleaning
kamala_t<-tolower(kamala_t)
kamala_t<-gsub("^ ","",kamala_t)
kamala_t<-gsub(" $","",kamala_t)
kamala_t<-gsub("[[:digit:]]","",kamala_t)
kamala_t<-gsub("[[:punct:]]","",kamala_t)
kamala_t<-gsub("kamala","",kamala_t)
C_kamala_t<-Corpus(VectorSource(kamala_t))
C_kamala_t<-tm_map(C_kamala_t,removeWords,stopwords("en"))
C_kamala_t<-tm_map(C_kamala_t,stripWhitespace)
inspect(C_kamala_t)
s_kamala_t<-tm_map(C_kamala_t,stemDocument)

#Files for lexicon comparison
pos<-read.csv("positive-lexicon.txt")
neg<-read.csv("negative-lexicon.txt")

#Sentiment analysis
sentiment <- function(stem_corpus)
{
  wordcloud(stem_corpus,
            min.freq = 3,
            colors=brewer.pal(8, "Dark2"),
            random.color = TRUE,
            max.words = 100)
  total_pos_count <- 0
  total_neg_count <- 0
  pos_count_vector <- c()
  neg_count_vector <- c()
    size <- length(stem_corpus)
  for(i in 1:size)
  {
    corpus_words<- list(strsplit(stem_corpus[[i]]$content, split = " "))
    pos_count <- length(intersect(unlist(corpus_words), unlist(pos)))
    neg_count <- length(intersect(unlist(corpus_words), unlist(neg)))
    total_pos_count <- total_pos_count + pos_count 
    total_neg_count <- total_neg_count + neg_count 
  }
  total_pos_count 
  total_neg_count 
  total_count <- total_pos_count + total_neg_count
  overall_positive_percentage <- (total_pos_count*100)/total_count
  overall_negative_percentage <- (total_neg_count*100)/total_count
  overall_positive_percentage 
  df<-data.frame(Review_Type=c("Postive","Negitive"),
                 Count=c(total_pos_count ,total_neg_count ))
  print(df)
  overall_positive_percentage<-paste("Percentage of Positive Reviews:",
                                     round(overall_positive_percentage,2),"%")
  return(overall_positive_percentage)
}
sentiment(s_kamala_t)
