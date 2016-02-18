#       GETTING AND CLEANING DATA COURSE PROJECT

##      Creating a directory
if (!file.exists("wearables")) {
        dir.create ("wearables")
}
setwd("wearables")

##      Retrieving and unzipping the data

library(downloader)
download("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
         dest="./wearables.zip", 
         mode="wb")
list.files()
unzip("./wearables.zip", exdir = "./wearables data")
file.remove("./wearables.zip")
setwd("./wearables data")

##  1: "Merges the training and the test sets to create one data set."
train <- read.table("./UCI HAR Dataset/train/X_train.txt")
test <- read.table("./UCI HAR Dataset/test/X_test.txt")
merged_data <- rbind(train, test)
head(merged_data, 2)

##  2: "Extracts only the measurements on the mean and standard 
#deviation for each measurement."
labels <- read.table("UCI HAR Dataset/features.txt", col.names=c("id", "name"))
mean_std <- labels[grepl("mean()", labels$name, fixed=TRUE) |
                           grepl("std()", labels$name, fixed=TRUE),]
mean_std_data <- merged_data[, mean_std$name]

head(mean_std_data, 2)
names(mean_std_data)

##  3: "Uses descriptive activity names to name the activities in the data set"
activity <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("id", "name"))
train_activity <- read.table("UCI HAR Dataset/train/y_train.txt", col.names="id")
test_activity <- read.table("UCI HAR Dataset/test/y_test.txt", col.names="id")
merged_activity <- rbind(train_activity, test_activity)
merged_activity$name <- activity[merged_activity$id,]$name
merged_activity <- merged_activity[,"name", drop=FALSE]
head(merged_activity,2)

##  4: "Appropriately labels the data set with descriptive variable names"
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names="id")
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names="id")
merged_subject <- rbind(train_subject, test_subject)
merged_subject$id <- as.factor(merged_subject$id)
merged_data <- cbind(mean_std_data, merged_subject, merged_activity)
names(merged_data) <- c(as.character(mean_std$name), "subject", "activity")
names(merged_data)<-gsub("^t", "time", names(merged_data))
names(merged_data)<-gsub("^f", "frequency", names(merged_data))
names(merged_data)<-gsub("Acc", "Accelerometer", names(merged_data))
names(merged_data)<-gsub("Gyro", "Gyroscope", names(merged_data))
names(merged_data)<-gsub("Mag", "Magnitude", names(merged_data))
names(merged_data)<-gsub("BodyBody", "Body", names(merged_data))

###     Removing special characters
names(merged_data)<-gsub("\\(", "", names(merged_data))
names(merged_data)<-gsub("\\)", "", names(merged_data))
names(merged_data)<-gsub("\\-", " ", names(merged_data))
head(merged_data, 2)
names(merged_data)

##  5: "From the data set in step 4, creates a second, independent tidy data set with 
#the average of each variable for each activity and each subject.
library(dplyr)

tidy_data<-aggregate(. ~subject + activity, merged_data, mean)
head(tidy_data, 2)

write.table(tidy_data, file = "./TidyData.txt", row.name = FALSE)
