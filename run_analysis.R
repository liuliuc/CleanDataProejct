# load libraries
    library(data.table)
    library(dplyr)

# check current work directory and download file and unzip it
    getwd()
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, "datafile.zip")
    unzip(zipfile = "datafile.zip")

# set the current work directory to be the same directory as the datasets were extracted.
    setwd("./UCI HAR Dataset")

# insert `activity labels` and subjects columns to test data set, rename col 1:2
    xtest = fread("./test/X_test.txt")
    ytest = fread("./test/y_test.txt")
    subject_test = fread("./test/subject_test.txt")
    test = cbind(subject_test,ytest,xtest)
    colnames(test)[1] = "subject"
    colnames(test)[2] = "activity"
    
# insert `activity labels` and subjects columns to train, rename col 1:2
    xtrain = fread("./train/X_train.txt")
    ytrain = fread("./train/y_train.txt")
    subject_train = fread("./train/subject_train.txt")
    train = cbind(subject_train,ytrain,xtrain)
    colnames(train)[1] = "subject"
    colnames(train)[2] = "activity"
    
# merge "read" and "train" data sets by rbind
    mergeddata = rbind(train, test)
    
# rename mergeddata column 3:563 with feature names 
    features = fread("./features.txt")
    colnames(mergeddata) [3:563] <- c(features$V2)
    
# extract columns with mean and standard deviation(std)
    colnames = colnames(mergeddata)
    selectedcol = c(colnames[1:2], colnames[grep("mean|std", colnames)])
    selecteddata = mergeddata[, ..selectedcol]
    
# convert both activity columns to factors
    activitylabels = fread("./activity_labels.txt")
    activityfac = factor(activitylabels$V2, as.factor(activitylabels$V2))
    selectedfac = factor(selecteddata$activity)

# replace `activity labels` with `activity names`
    selecteddata[["activity"]] = factor(selecteddata[,activity]
                                        , levels(selectedfac)
                                        , levels(activityfac))

# convert subject col to factor
    selecteddata[["subject"]] = factor(selecteddata[,subject])
    
# re-shaping data format by melting and re-casting with mean values
    datamelt = melt(selecteddata, id=c("subject", "activity"))
    datadcast = dcast(datamelt, subject + activity ~ variable, mean)
    
# save as a new txt file named tidydata
    # fwrite(datadcast, "tidydata.txt")
    write.table(datadcast, "tidydata.txt", row.name=FALSE)

# create a new updated feature txt file
    featurenames = list(names(datadcast)[3:81])
    fwrite(featurenames, "features_update.txt")    
