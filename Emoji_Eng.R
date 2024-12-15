#Install necessary packages
install.packages("dplyr","lme4","glmer","ggplot2","tidyr","languageR","sciplot","stats","plyr","lattice","lmerTest","car","ordinal")
library(lme4)
library(ggplot2)
library(dplyr)

setwd("C:/Users/magda/rstudio/emoji")

#Importing the critical dataset + bio (change filepath to your own)
Emoj_EN <- read.csv("Emoji_Eng.csv", header=TRUE, sep=",")
Emoj_Bio <- read.csv("Emoji_Eng_Bio.csv", header=TRUE, sep=",")

#Combine Datasets
Emoj_EN <- left_join(Emoj_EN, Emoj_Bio, by = "ID")

#See what the top 5 rows of your dataset look like
head(Emoj_EN)

#Turn the relevant dimensions into factors
Emoj_EN$ID <-as.factor(Emoj_EN$ID)
Emoj_EN$Condition <-as.factor(Emoj_EN$Condition)
Emoj_EN$Item_Num <-as.factor(Emoj_EN$Item_Num)
Emoj_EN$Answer <-as.factor(Emoj_EN$Answer)
Emoj_EN$Gender <-as.factor(Emoj_EN$Gender)
Emoj_EN$Use <-as.factor(Emoj_EN$Use)
Emoj_EN$Rec <-as.factor(Emoj_EN$Rec)

#Look at summary of dataset to make sure everything worked.
summary(Emoj_EN)

#See the total number of answers given per condition
table(Emoj_EN$Condition, Emoj_EN$Answer)

# Create a contingency table
answer_table <- table(Emoj_EN$Condition, Emoj_EN$Answer)

# Convert to percentages by row
answer_percent <- prop.table(answer_table, margin = 1) * 100

#See percentage of answers given per condition to 2 decimal places
round(answer_percent, 2)  

#Make subgroups to graph different representations

Pos_Initial = subset(Emoj_EN, Emoj_EN$Condition %in% c("Pos_Initial"))
Neg_Initial = subset(Emoj_EN, Emoj_EN$Condition %in% c("Neg_Initial"))
Pos_Final = subset(Emoj_EN, Emoj_EN$Condition %in% c("Pos_Final"))
Neg_Final = subset(Emoj_EN, Emoj_EN$Condition %in% c("Neg_Final"))


#Plot your data - proportions of answers given per condition
ggplot(Emoj_EN, aes(x = Condition, fill = Answer)) +
  geom_bar(position = "fill", color = "black") +
  scale_y_continuous(labels = scales::percent) +  # Convert y-axis to percentages
  labs(
    x = "Condition",
    y = "Proportion",
    fill = "Answer",
    title = "Proportional Distribution of Answers by Condition"
  ) +
  theme_minimal()


#Pos_Initial Graph of Choices
ggplot(Pos_Initial, aes(x = Condition, fill = as.factor(Answer))) +
  geom_bar(position = "dodge", color = "black", width = 0.6) +
  scale_fill_manual(values = c("Subject" = "red", "Object" = "skyblue", "Sender" = "green")) +
  labs(
    x = "",
    y = "Count",  # Reflects counts of values
    title = "Count of Answer Values by Pos_Initial",
    fill = "Answer Levels"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  )

#Neg_Initial Graph of Choices
ggplot(Neg_Initial, aes(x = Condition, fill = as.factor(Answer))) +
  geom_bar(position = "dodge", color = "black", width = 0.6) +
  scale_fill_manual(values = c("Subject" = "red", "Object" = "skyblue", "Sender" = "green")) +
  labs(
    x = "",
    y = "Count",  # Reflects counts of values
    title = "Count of Answer Values by Neg_Initial",
    fill = "Answer Levels"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  )

#Pos_Final Graph of Choices
ggplot(Pos_Final, aes(x = Condition, fill = as.factor(Answer))) +
  geom_bar(position = "dodge", color = "black", width = 0.6) +
  scale_fill_manual(values = c("Subject" = "red", "Object" = "skyblue", "Sender" = "green")) +
  labs(
    x = "",
    y = "Count",  # Reflects counts of values
    title = "Count of Answer Values by Pos_Final",
    fill = "Answer Levels"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  )

#Neg_Final Graph of Choices
ggplot(Neg_Final, aes(x = Condition, fill = as.factor(Answer))) +
  geom_bar(position = "dodge", color = "black", width = 0.6) +
  scale_fill_manual(values = c("Subject" = "red", "Object" = "skyblue", "Sender" = "green")) +
  labs(
    x = "",
    y = "Count",  # Reflects counts of values
    title = "Count of Answer Values by Neg_Final",
    fill = "Answer Levels"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  )

#We will try some models


#First create binary factors for given answers
Emoj_EN$Object = ifelse(Emoj_EN$Answer == "Object", 1, 0)
Emoj_EN$Subject = ifelse(Emoj_EN$Answer == "Subject", 1, 0)
Emoj_EN$Sender = ifelse(Emoj_EN$Answer == "Sender", 1, 0)


#This model assesses the selection of Object (second character) across conditions
#What we find is that Pos_initial is the least favorable condition to choose Object
#Then followed by Neg_initial (which is on the verge of significance)
Obj_model <- glmer(Object ~ Condition + (1 | ID) + (1 | Item_Num), data = Emoj_EN,  family = binomial)
summary(Obj_model)

#This model assesses the selection of Subject (first character) across conditions
#This time - Pos_initial is the most favorable condition to choose Subject 
#Then followed by Pos_Final (which is on the verge of significance)
Subj_model <- glmer(Subject ~ Condition + (1 | ID) + (1 | Item_Num), data = Emoj_EN,  family = binomial)
summary(Subj_model)

#This model assesses the selection of Sender (sender of text) across conditions
#Interestingly, Neg_Final condition is the most favorable condition to choose Sender
Send_model <- glmer(Sender ~ Condition + (1 | ID) + (1 | Item_Num), data = Emoj_EN,  family = binomial)
summary(Send_model)

