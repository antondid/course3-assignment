library(data.table)
library(plyr)

##setting a path
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

##downloading zip file from the net and unzipping it in the specific folder
zdata <- "ZipData.zip"
if (!file.exists(zdata)) {
  download.file(url, zdata)
}

z <- "UCI HAR Dataset"
if (!file.exists(z)) {
  unzip(zdata)
}


## reading the features and extracting only mean and standart deviation values
features <- read.table(file.path(path, z, "features.txt"))[,2]
mean_std <- grepl("mean|std", features)

## reading the activity file and setting tidy names to the columns
activity <- read.table(file.path(path, z, "activity_labels.txt"))
setnames(activity, colnames(activity), c("activity-id", "activity-type"))


## working with TRAIN data

# reading the data
train_labels <- read.table(file.path(path, z, "train", "y_train.txt"))
train_full <- read.table(file.path(path, z, "train", "X_train.txt"))
train_sub <- read.table(file.path(path, z, "train", "subject_train.txt"))

# setting tidy names
setnames(train_labels, colnames(train_labels), "activity-id")
setnames(train_full, colnames(train_full), as.character(features))
setnames(train_sub, colnames(train_sub), "subject-id")

# extracting only mean and standart deviation values
train_set <- train_full[, mean_std == TRUE]

# making the final train data
train_data <- cbind(train_labels, train_sub, train_set)


## working with TEST data

test_labels <- read.table(file.path(path, z, "test", "y_test.txt"))
test_full <- read.table(file.path(path, z, "test", "X_test.txt"))
test_sub <- read.table(file.path(path, z, "test", "subject_test.txt"))

setnames(test_labels, colnames(test_labels), "activity-id")
setnames(test_full, colnames(test_full), as.character(features))
setnames(test_sub, colnames(test_sub), "subject-id")

test_set <- test_full[, mean_std == TRUE]

# making the final test data
test_data <- cbind(test_labels, test_sub, test_set)


# merging datasets together to make the big one
big_data <- rbind(train_data, test_data)
merged_data <- merge(activity, big_data, by = "activity-id")[,-1]

# setting tidy names to the columns
names(merged_data) <- gsub("\\()", "", names(merged_data))
names(merged_data) <- gsub("^t", "Time", names(merged_data))
names(merged_data) <- gsub("^f", "Frequency", names(merged_data))
names(merged_data) <- gsub("Acc", "Accelerometer", names(merged_data))
names(merged_data) <- gsub("Gyro", "Gyroscope", names(merged_data))
names(merged_data) <- gsub("meanFreq", "meanFrequency", names(merged_data))
names(merged_data) <- gsub("Body|BodyBody", "\\.Body\\.", names(merged_data))
names(merged_data) <- gsub("Gravity", "\\.Gravity\\.", names(merged_data))
names(merged_data) <- gsub("Mag", "\\.Magnitude", names(merged_data))
names(merged_data) <- gsub("Jerk", "\\.Jerk", names(merged_data))
names(merged_data) <- make.names(names(merged_data))

# making a tidy data 
tidy_data <- ddply(merged_data, names(merged_data)[c(1,2)], numcolwise(mean))

# writing table to txt file
write.table(tidy_data, file.path(path, "tidy_data.txt"), row.names = FALSE)
