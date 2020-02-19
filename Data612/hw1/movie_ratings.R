##wrkdir
#wkdir=file.path("C://Users//talha//Documents//Training//CUNY Classes//Data612//Week1//ML-latest-small")
#setwd(wkdir)
##Load packages
library(tidyr)
library(dplyr)
library(ggplot2)
library(caTools)
library(MLmetrics)

############
### 1. Read and explore the data
##read and download the files
temp <- tempfile()
temp2<-tempfile()
download.file("http://files.grouplens.org/datasets/movielens/ml-latest-small.zip",temp)
unzip(temp, exdir=temp2)
ratings<-read.csv(file.path(paste0(temp2,"\\ml-latest-small","\\ratings.csv")),header=TRUE,sep=",")
movies<-read.csv(file.path(paste0(temp2,"\\ml-latest-small","\\movies.csv")),header=TRUE,sep=",")
unlink(temp)
unlink(temp2)

##head of the data
head(movies)
head(ratings)

############
### 2. Process the data

##data processing
ratings$date<-ratings$timestamp/(24*60*60)
ratings$date<-as.Date(floor(ratings$date),origin="1970-01-01")
##summarize movie ratings
rs_sum<-ratings %>% group_by(movieId) %>% summarize(num_rat=n()) 
rs_sum<-rs_sum[order(rs_sum$num_rat,decreasing = TRUE),]
##select movies with more 100 user ratings
rs_sum_s<-rs_sum %>% filter(num_rat>100)
## filter out the ratings
rt_filt<-right_join(ratings,rs_sum_s,by="movieId")

############
### 3. Split the data into train and test
train=sample.split(rt_filt[,c("userId")],SplitRatio=3/4)
rtngs_train=rt_filt[train,]
rtngs_test=rt_filt[!train,]

############
### 4. Calculate raw average for train and test
rtngs_train$avg_rating<-apply(matrix(rtngs_train[,c("rating")]),2,mean)
rtngs_test$avg_rating<-apply(matrix(rtngs_test[,c("rating")]),2,mean)
#RMSE 
a_train<-RMSE(rtngs_train$avg_rating,rtngs_train$rating)
a_test<-RMSE(rtngs_test$avg_rating,rtngs_test$rating)

############
### 5. Calculate Bias by User and Movies
#by user for training
tmp1<-rtngs_train %>% group_by(userId) %>% summarize(useravg=mean(rating))
#by movie for training
tmp2<-rtngs_train %>% group_by(movieId) %>% summarize(movieavg=mean(rating))
rtngs_train<-left_join(rtngs_train,tmp1,by="userId")
rtngs_train<-left_join(rtngs_train,tmp2,by="movieId")
#delete intermediate data
rm(tmp1,tmp2)

#by user for testing
tmp1<-rtngs_test %>% group_by(userId) %>% summarize(useravg=mean(rating))
#by movie for testing
tmp2<-rtngs_test %>% group_by(movieId) %>% summarize(movieavg=mean(rating))
rtngs_test<-left_join(rtngs_test,tmp1,by="userId")
rtngs_test<-left_join(rtngs_test,tmp2,by="movieId")
#delete intermediate data
rm(tmp1,tmp2)

############
### 6. Calculate Baseline Predictor
#ratings train
rtngs_train<-rtngs_train %>% mutate(baseline_diff=((useravg-avg_rating)+(movieavg-avg_rating)),
                                                  baseline_pred=avg_rating+baseline_diff)
#ratings test
rtngs_test<-rtngs_test %>% mutate(baseline_diff=((useravg-avg_rating)+(movieavg-avg_rating)),
                                    baseline_pred=avg_rating+baseline_diff)
#top fill and bottom fill the values
rtngs_train[rtngs_train$baseline_pred>5,c("baseline_pred")]<-5
rtngs_train[rtngs_train$baseline_pred<0.5,c("baseline_pred")]<-0.5

#RMSE 
b_train<-RMSE(rtngs_train$baseline_pred,rtngs_train$rating)
b_test<- RMSE(rtngs_test$baseline_pred,rtngs_test$rating)

#Final Summary
data.frame(Type = c("Average","Baseline"), Training = c(a_train,b_train), Test = c(a_test,b_test)) %>% kable("html",caption='<b> RMSE Error </b>') %>% kable_styling(full_width=F)

#prediction
rtngs_train %>% select("rating","baseline_pred") %>% 
  gather("metric","value") %>%  ggplot( aes(x=value, fill=metric)) +
  geom_histogram(bins=40,color="#e9ecef", alpha=0.6, position = 'identity') +
  scale_fill_manual(values=c("#69b3a2", "#404080"))+labs(fill="Prediction")

############
### 7. References
#1. F. Maxwell Harper and Joseph A. Konstan. 2015. The MovieLens Datasets: History and Context. ACM Transactions on Interactive Intelligent Systems (TiiS) 5, 4: 19:1-19:19. 
#https://doi.org/10.1145/2827872
#2. https://stackoverflow.com/questions/3053833/using-r-to-download-zipped-data-file-extract-and-import-data
#3. https://stackoverflow.com/questions/56951752/kable-caption-in-rmarkdown-file-in-html-in-bold
#4. http://haozhu233.github.io/kableExtra/awesome_table_in_html.html#overview