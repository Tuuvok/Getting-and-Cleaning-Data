# run_analysis.R
# Coursera Course Project "Getting and Cleaning Data"

# get data from the website
ZipDataDir <- "./ZipData"
ZipURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
Filename <- "ZipData.zip"
File <- paste(ZipDataDir, "/", Filename, sep = "")

if (!file.exists(ZipDataDir)) {
    dir.create(ZipDataDir)
    download.file(url = ZipURL, destfile = File)
}

# extract (unzip) data
DataDir <- "./Data"
if (!file.exists(DataDir)) {
    dir.create(DataDir)
    unzip(zipfile = File, exdir = DataDir)
}

# read train and test data
xTest <- read.table("./Data/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./Data/UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./Data/UCI HAR Dataset/test/subject_test.txt")
xTrain <- read.table("./Data/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./Data/UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./Data/UCI HAR Dataset/train/subject_train.txt")

# read activity labels and features
activity_labels <- read.table("./Data/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./Data/UCI HAR Dataset/features.txt")

# select rows based on mean and standard deviation
features_index <- grep(".*mean.*|.*std.*", features[,2])
features_select <- features[features_index,2]

# reduce dataset of "X_test" and "X_train" to columns with mean and sd values
xTest <- xTest[,features_index]
xTrain <- xTrain[,features_index]

# merge the 6 separate datasets (x,y,subject of train/test) to one dataset
TrainData <- cbind(subjectTrain, yTrain, xTrain)
TestData <- cbind(subjectTest, yTest, xTest)
Data <- rbind(TrainData, TestData)

# label dataset
colnames(Data) <- c("Subject", "Activity", features_select)
Data$Activity <- factor(Data$Activity, levels = activity_labels[,1], labels = activity_labels[,2])
Data$Subject <- as.factor(Data$Subject)

# create a tidy dataset
library(reshape2)
tidyData <- melt(Data, id = c("Subject", "Activity"))
tidyData <- dcast(tidyData, Subject + Activity ~ variable, mean)

# write tidy dataset
write.table(tidyData, "./tidyData.txt", row.names = F)
