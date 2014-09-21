# Download the data file. 
if (!file.exists("data.zip")) {
   fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
   download.file(fileURL, destfile="data.zip", method = "curl")
   list.files()
}

# Unzip the data file. 
unzip("./data.zip")

# Check the data files. 
dir()

# Load the packages 
library(reshape2)
library(data.table)

# Read the test data set. 
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt", as.is=T)
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt", as.is=T)
subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt", as.is=T)

# Read the training data set.
xtrain <- read.table("./UCI HAR Dataset/train/x_train.txt", as.is=T)
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt", as.is=T)
subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", as.is=T)

# Read the features file. 
features <- read.table("./UCI HAR Dataset/features.txt", as.is=T)

# Read the activity labels file.
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", as.is=T)

# Rename the colnames to avoid duplicate names. 
names(subjecttest) <- "Subject"
names(subjecttrain) <- "Subject"

names(ytrain) <- "Activity"
names(ytest) <- "Activity"

# Use the features to rename the colnames in test and training data 
featurenames <- c(features$V2)
names(xtest) <- featurenames
names(xtrain) <- featurenames

# Add another column to distinguish the data in the merged set. 
xtest$DSource <- "Test"
xtrain$DSource <- "Train"

# Filter the mean or std data for test and train data after joining the xdata
xjoin <- rbind(xtest, xtrain)
xfilter <- colnames(xjoin)[grep("mean|std|Dsource",colnames(xjoin))]
xfiltered <- xjoin[,xfilter]

# Join the data for the Subject and the row as well for test and training. 
yjoin <- rbind(ytest, ytrain)
subjectjoin <- rbind(subjecttest, subjecttrain)

# Rename the activities from the identifier to the activity description in activities
yjoin[,"Activity"] <- activities[match(yjoin[,"Activity"],activities[,"V1"]),2]

# Join Subject and Activity with Mean and SD data
filteredjoin <- cbind(subjectjoin, yjoin, xfiltered)

# Clean up the colnames

headers <- names(filteredjoin)

headers <- sub("^t","Time",headers)
headers <- sub("^f","Frequency",headers)
headers <- sub("Acc","Accelerometer",headers)
headers <- sub("-mean..","Mean",headers)
headers <- sub("-X","Xaxis",headers)
headers <- sub("-Y","Yaxis",headers)
headers <- sub("-Z","Zaxis",headers)
headers <- sub("-std..","StandardDeviation",headers)
headers <- sub("Gyro","Gyroscope",headers)
headers <- sub("BodyBody","Body",headers)
headers <- sub("Mag","Magnitude",headers)

names(filteredjoin) <- headers

# Produce the means by Subject and activity

cleandata <- with(filteredjoin, aggregate(filteredjoin[,3:81], list(Subject=Subject, Activity=Activity), mean))

#Write the clean data to the file. 
write.table(cleandata, file = "TidyData.txt")
print("File TidyData.txt has been stored in the working directory")

# This file can be read into R using the instruction "read.table("./tidyData.txt",stringsAsFactors=FALSE)"
