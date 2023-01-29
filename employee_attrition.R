'''
Name: Sadiq Olusegun Balogun
Topic: Predicting Employee Attrition Using Logistic Regression

'''


#----- Installing necessary libraries --------------

install.packages('caret')       
install.packages('dplyr')       
install.packages('ggplot2')     
install.packages('smotefamily') 
install.packages('purrr')       
install.packages('forcats')     
install.packages('tidyr')       
install.packages('ggcorrplot')  
install.packages('bootStepAIC') 
install.packages('pROC')


#-------- Importing the libraries----------------

library(caret)       # for machine learning
library(dplyr)       # for data manipulation
library(ggplot2)     # for data visualization
library(smotefamily) # for oversampling with SMOTE
library(purrr)       # for data manipulation
library(forcats)     # To handle categorical variables
library(tidyr)       # for data manipulation
library(ggcorrplot)  # for correlation plot
library(bootStepAIC) # for feature selection
library(pROC)        # for ROC plot


# ----------------------- IMPORTING DATA -------------------------

e_attrition <- read.csv("HR-Employee-Attrition.csv", sep = ",",
                        header = TRUE, stringsAsFactors = TRUE)

# ------------------ DATA PRE-PROCESSING ---------------------------------------
# check dimension and first few rows of data
dim(e_attrition)
head(e_attrition)

# Check structure of features
str(e_attrition)

# check for missing and duplicate values
anyNA(e_attrition)
anyDuplicated(e_attrition)

# No missing or duplicate values found

# statistic summary of the features
summary(e_attrition)

# Looking at the summary, EmployeeCount,EmployeeNumber because they are just serial numbers;
# Over18, StandardHours will aslo be removed because they have constant value in all observations

# Removing the columns
e_attrition <- e_attrition %>% 
  dplyr::select(-c(EmployeeCount,EmployeeNumber, Over18, StandardHours))

dim(e_attrition)

# ----------------- EXPLORATORY DATA ANALYSIS -----------------------------------------
# Target Variable Distribution
ggplot(data = e_attrition, mapping  = aes(x=Attrition, fill=Attrition)) +
  geom_bar(show.legend = FALSE) +
  geom_text(
    stat='count',
    aes(label=paste0(round(after_stat(prop*100), digits=1), "%"),group=1),
    vjust=-0.4,
    size=4) + 
  labs( x = "", y = "", title = "Attrition Distribution")

# Attrition by OverTime
ggplot(e_attrition, 
       aes(x = OverTime, group = Attrition)) + 
  geom_bar(aes(y = ..prop.., fill = factor(..x..)), 
           stat="count", 
           alpha = 0.7) +
  geom_text(aes(label = scales::percent(..prop..), y = ..prop.. ), 
            stat= "count", 
            vjust = -.5) +
  labs(y = "Percentage", fill= "OverTime") +
  facet_grid(~Attrition) +
  scale_fill_manual(values = c("#0D0628","#660000")) + 
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
  ggtitle("Attrition by Over Time")

# Attrition by Business Travel
ggplot(e_attrition, 
       aes(x= BusinessTravel,  group=Attrition)) + 
  geom_bar(aes(y = ..prop.., fill = factor(..x..)), 
           stat="count", 
           alpha = 0.7) +
  geom_text(aes(label = scales::percent(..prop..), y = ..prop.. ), 
            stat= "count", 
            vjust = -.5) +
  labs(y = "Percentage", fill="Business Travel") +
  facet_grid(~Attrition) +
  scale_fill_manual(values = c("#0D0628","#660000", "#023618")) + 
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
  ggtitle("Attrition by Business Travel")

# Attrition by Education
  ggplot(e_attrition,
    aes(x = Education, group = Attrition)) + 
  geom_bar(aes(y = ..prop.., fill = factor(..x..)), 
           stat="count", 
           alpha = 0.7) +
  geom_text(aes(label = scales::percent(..prop..), y = ..prop.. ), 
            stat= "count", 
            vjust = -.5) +
  labs(y = "Percentage", fill= "Education") +
  facet_grid(~Attrition) +
  scale_fill_manual(values = c("#0D0628","#660000","#023618","#06BCC1","#175676")) +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
  ggtitle("Attrition by Education")
  
# Attrition by Gender
  
  ggplot(e_attrition,
    aes(x = Gender, group = Attrition)) + 
    geom_bar(aes(y = ..prop.., fill = factor(..x..)), 
             stat="count", 
             alpha = 0.7) +
    geom_text(aes(label = scales::percent(..prop..), y = ..prop.. ), 
              stat= "count", 
              vjust = -.5) +
    labs(y = "Percentage", fill= "Gender") +
    facet_grid(~Attrition) +
    scale_fill_manual(values = c("#660000","#0D0628")) +
    theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
    ggtitle("Attrition by Gender")

# Attrition by Marital Status
  
  ggplot(e_attrition,
    aes(x = MaritalStatus, group = Attrition)) + 
    geom_bar(aes(y = ..prop.., fill = factor(..x..)), 
             stat="count", 
             alpha = 0.7) +
    geom_text(aes(label = scales::percent(..prop..), y = ..prop.. ), 
              stat= "count", 
              vjust = -.5) +
    labs(y = "Percentage", fill= "MaritalStatus") +
    facet_grid(~Attrition) +
    scale_fill_manual(values = c("#0D0628","#660000","#023618"))+
    theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
    ggtitle("Attrition")
  
  

  
  # Avergae Income by Gender
plotdata <- e_attrition %>%
  group_by(Gender) %>%
  summarize(mean_salary = mean(MonthlyIncome))

ggplot(plotdata, 
       aes(x = Gender, y = mean_salary)) +
  geom_bar(stat = "identity", 
           fill = "cornflowerblue") +
  geom_text(aes(label = round(mean_salary,2)), 
            vjust = -0.25, size=3) +
  scale_y_continuous(breaks = seq(0, 3000, 7000)) +
  labs(title = "AVG MonthlyIncome by Gender", x = "",y = "Monthly Income")

# Average Income by Job Role
plotJobRole <- e_attrition %>%
  group_by(JobRole) %>%
  summarize(mean_salary = mean(MonthlyIncome))

JR <- ggplot(plotJobRole, 
             aes(x = reorder(JobRole, -mean_salary), y = mean_salary)) +
  geom_bar(stat = "identity", 
           fill = "cornflowerblue") +
  geom_text(aes(label = round(mean_salary,2)), 
            hjust = .005, size = 3) +
  scale_y_continuous(breaks = seq(0, 3000, 7000)) +
  labs(title = "AVG MonthlyIncome by Job Role", x = "",y = "Monthly Income")+
  theme_classic()
JR + coord_flip()

# Salary distribution
ggplot(e_attrition, aes(x = MonthlyIncome))+
  theme_classic()+
  geom_histogram(binwidth = 1000, fill = "blue")+
  labs(x="Monthly Income", y="",title = "Monthly Income Distribution")


# Age Distribution
ggplot(e_attrition, aes(x = Age))+
  geom_histogram(aes(y=..density..),binwidth = 5, fill = "blue")+
  geom_density(color='black')+geom_rug()+
  labs(x="Age", y="",title = "Age Distribution")

# Scatter plot of Age, Income and Attrition

ggplot(e_attrition)+
  geom_point(aes(x=MonthlyIncome, y=Age, colour= Attrition))+
  ggtitle(label = "Attrition Scatterplot by Income and Age")
# employees with high salaries seems to stay at the company

# correlation of numeric features
numeric_cols <- dplyr::select_if(e_attrition, is.numeric)

# check the correlations of the features
r <- cor(numeric_cols, use="complete.obs")
round(r,2)
ggcorrplot(r, hc.order = TRUE, type = "full",lab = TRUE, lab_size = 2.5)


# -------------- DATA PREPARATION FOR MACHINE LEARNING ALGORITHM ---------------

# Data Type Conversion
e_atn <- e_attrition # making a copy of the dataframe

e_atn <- mutate(e_atn, Attrition = ifelse(Attrition=="Yes",1,0)) 

# convert the categorical data to numeric
e_atn$BusinessTravel <- as.numeric(e_atn$BusinessTravel)
e_atn$Department <- as.numeric(e_atn$Department)
e_atn$EducationField <- as.numeric(e_atn$EducationField)
e_atn$Gender <- as.numeric(e_atn$Gender)
e_atn$JobRole <- as.numeric(e_atn$JobRole)
e_atn$MaritalStatus <- as.numeric(e_atn$MaritalStatus)
e_atn$OverTime <- as.numeric(e_atn$OverTime)


# Data Normalization 
normalize <- function(x) {+ return ((x - min(x)) / (max(x) - min(x))) }

nlzed_df <- as.data.frame(lapply(e_atn[,1:31], normalize))
nlzed_df$Attrition <- as.factor(nlzed_df$Attrition)
View(nlzed_df)

# ------------- BUILDING A LR MODEL WITHOUT FS + UNBALANCED DATA ------------------------
a_lrm <- glm(Attrition ~ ., family=binomial(link='logit'),
             data = nlzed_df)
# Training and Testing Data Split

set.seed(154) 
inTrain = createDataPartition(nlzed_df$Attrition, p = .7)[[1]]

# Assign the 70% of observations to training data 
train <- nlzed_df[inTrain,]
table(train$Attrition)

test <- nlzed_df[-inTrain,] # remaining 30% for test

# Using the training data for LR model
model_all <- glm(Attrition~., data = train, family = 'binomial')
summary(model_all)

# Apply the prediction
predict_all <- predict(model_all, newdata= test, type = "response") 
predict_all <- ifelse(predict_all > 0.5, 1, 0)


# Check the accuracy of the prediction model by printing the confusion matrix
print(confusionMatrix(as.factor(predict_all), test$Attrition))

#Recall

print(confusionMatrix(as.factor(predict_all), test$Attrition, mode = "prec_recall"))


# ROC Plot
rf.Plot1<- plot.roc (as.numeric(test$Attrition),
                    as.numeric(predict_all),
                    lwd=2, type="b", print.auc=TRUE,
                    col ="red",
                    main= "ROC Curve with Unbalanced Data and All Features")

# ------------- BUILDING A LOGISTIC REGRESSION MODEL WITH UNBALANCED DATA + FS---------------------------

# Create a logistic regression model
a_lrm <- glm(Attrition ~ ., family=binomial(link='logit'),
             data = nlzed_df)

# stepwise regression for feature selection
both <- stepAIC(a_lrm, direction = "both")

# new df based on feature selection

newdf <- nlzed_df[, c('Attrition', 'Age', 'DailyRate', 'Department',
                         'DistanceFromHome','EnvironmentSatisfaction','Gender','JobInvolvement','JobLevel', 
                         'JobRole','JobSatisfaction','MaritalStatus',
                         'NumCompaniesWorked','OverTime', 
                         'RelationshipSatisfaction','StockOptionLevel','TotalWorkingYears',
                         'TrainingTimesLastYear','WorkLifeBalance','YearsAtCompany', 
                         'YearsInCurrentRole','YearsSinceLastPromotion','YearsWithCurrManager'
)]

# Training and Testing Data Split

set.seed(194) 
inTrain = createDataPartition(newdf$Attrition, p = .7)[[1]]

# Assign the 70% of observations to training data 
training <- newdf[inTrain,]

testing <- newdf[-inTrain,] # remaining 30% for test

# Build the model
model_unb <- glm(Attrition~., data = training, family = 'binomial')
summary(model_unb)

# Apply the prediction
prediction <- predict(model_unb, newdata= testing, type = "response") 
prediction <- ifelse(prediction > 0.5, 1, 0)


# Check the accuracy of the prediction model by printing the confusion matrix
print(confusionMatrix(as.factor(prediction), testing$Attrition))


#Recall

print(confusionMatrix(as.factor(prediction), testing$Attrition, mode = "prec_recall"))


# ROC Plot
rf.Plot2<- plot.roc (as.numeric(testing$Attrition),
                    as.numeric(prediction),
                    lwd=2, type="b", print.auc=TRUE,
                    col ="red",
                    main= "ROC Curve with Unbalanced Data and 22 Features")


# ----------------- BUILDING LR MODEL WITH OVERSAMPLED DATA + FS --------------------------------

smote_train <- SMOTE(training[-1], training$Attrition)
smote_train <- smote_train$data
table(smote_train$class)

str(smote_train)
# class feature is a character, we'll convert it to numeric
smote_train$class <- as.numeric(smote_train$class)
smote_train$class <- as.factor(smote_train$class)
# LR
smoteLR <- glm(class~., data = smote_train, family = 'binomial')

smote_predict <- predict(smoteLR, newdata= testing, type = "response") 
smote_predict <- ifelse(smote_predict > 0.5, 1, 0)



# Check the accuracy of the prediction model by printing the confusion matrix
print(confusionMatrix(as.factor(smote_predict), testing$Attrition))

print(confusionMatrix(as.factor(smote_predict), testing$Attrition, mode = "prec_recall"))

# ROC Curve
rf.Plot3<- plot.roc (as.numeric(testing$Attrition),
                     as.numeric(smote_predict),
                     lwd=2, type="b", print.auc=TRUE,
                     col ="red",
                     main= "ROC Curve with Balanced Data and 22 Features")



# --------------BUILDING LR MODEL WITH OVERSAMPLED DATA + NO FS -------------------
s_train <- SMOTE(train[-2], train$Attrition)
s_train <- s_train$data
table(s_train$class)

str(s_train)

# LR
s_train$class <- as.numeric(s_train$class)
s_train$class <- as.factor(s_train$class)

sLR <- glm(class~., data = s_train, family = 'binomial')

s_predict <- predict(sLR, newdata= test, type = "response") 
s_predict <- ifelse(s_predict > 0.5, 1, 0)



# Check the accuracy of the prediction model by printing the confusion matrix
print(confusionMatrix(as.factor(s_predict), test$Attrition))

print(confusionMatrix(as.factor(s_predict), test$Attrition, mode = "prec_recall"))

# ROC Curve
rf.Plot4<- plot.roc (as.numeric(test$Attrition),
                     as.numeric(s_predict),
                     lwd=2, type="b", print.auc=TRUE,
                     col ="red",
                     main= "ROC Curve with Balanced Data and All Features")




