# Data 612 - Global Baseline Predictors and RMSE

This dataset (ml-latest-small) describes 5-star rating and free-text tagging activity from MovieLens, a movie recommendation service. It contains 100836 ratings and 3683 tag applications across 9742 movies. These data were created by 610 users between March 29, 1996 and September 24, 2018. This dataset was generated on September 26, 2018.

Users were selected at random for inclusion. All selected users had rated at least 20 movies. No demographic information is included. Each user is represented by an id, and no other information is provided.

The data are contained in the files links.csv, movies.csv, ratings.csv and tags.csv. 

## Project 1
> In this first assignment, we’ll attempt to predict ratings with very little information. 
> We’ll first look at just raw averages across all (training dataset) users. We’ll then account for “bias” by normalizing across users and across items.

As a first step I used and downloaded the above dataset. See R code on the attached. 

![](images/top10movies.png)


![](images/rating_hist.png)

![](images/summary.png)

### References
1. F. Maxwell Harper and Joseph A. Konstan. 2015. The MovieLens Datasets: History and Context. ACM Transactions on Interactive Intelligent Systems (TiiS) 5, 4: 19:1–19:19. 
https://doi.org/10.1145/2827872
2. https://stackoverflow.com/questions/3053833/using-r-to-download-zipped-data-file-extract-and-import-data
3. https://stackoverflow.com/questions/56951752/kable-caption-in-rmarkdown-file-in-html-in-bold
4. http://haozhu233.github.io/kableExtra/awesome_table_in_html.html#overview