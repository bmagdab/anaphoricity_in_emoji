#Install necessary packages
install.packages("dplyr","lme4","glmer","ggplot2","tidyr","languageR","sciplot","stats","plyr","lattice","lmerTest","car","ordinal")
library(lme4)
library(ggplot2)
library(dplyr)

setwd("C:/Users/magda/moje/LTE/psycholinguistics/emoji_analysis")
# setwd("/media/magda/9C33-6BBD/emojis")

#Importing the critical dataset + bio (change filepath to your own)
Emoj_Pol <- read.csv("Emoji_Pol.csv", header=TRUE, sep=",")
Emoj_PolBio <- read.csv("Emoji_Pol_Bio.csv", header=TRUE, sep=",")

#Combine Datasets
Emoj_Pol <- left_join(Emoj_Pol, Emoj_PolBio, by = "ID")

#MINE
# removing fillers?
Emoj_Pol %>% filter(Condition != "Filler") -> Emoj_Pol

#See what the top 5 rows of your dataset look like
head(Emoj_Pol)

#Turn the relevant dimensions into factors
Emoj_Pol$ID <-as.factor(Emoj_Pol$ID)
Emoj_Pol$Condition <-as.factor(Emoj_Pol$Condition)
Emoj_Pol$Item_Num <-as.factor(Emoj_Pol$Item_Num)
Emoj_Pol$Answer <-as.factor(Emoj_Pol$Answer)
Emoj_Pol$Gender <-as.factor(Emoj_Pol$Gender)
Emoj_Pol$Use <-as.factor(Emoj_Pol$Use)
Emoj_Pol$Rec <-as.factor(Emoj_Pol$Rec)
Emoj_Pol$iOS <-as.factor(Emoj_Pol$iOS)
Emoj_Pol$Age <-as.factor(Emoj_Pol$Age)

#Look at summary of dataset to make sure everything worked.
summary(Emoj_Pol)

#See the total number of answers given per condition
table(Emoj_Pol$Condition, Emoj_Pol$Answer)

# Create a contingency table
answer_table <- table(Emoj_Pol$Condition, Emoj_Pol$Answer)

# Convert to percentages by row
answer_percent <- prop.table(answer_table, margin = 1) * 100

#See percentage of answers given per condition to 2 decimal places
round(answer_percent, 2)  

#Make subgroups to graph different representations

Pos_InitialP = subset(Emoj_Pol, Emoj_Pol$Condition %in% c("Pos_Initial"))
Neg_InitialP = subset(Emoj_Pol, Emoj_Pol$Condition %in% c("Neg_Initial"))
Pos_FinalP = subset(Emoj_Pol, Emoj_Pol$Condition %in% c("Pos_Final"))
Neg_FinalP = subset(Emoj_Pol, Emoj_Pol$Condition %in% c("Neg_Final"))

#Plot your data - proportions of answers given per condition
png("C:/Users/magda/moje/LTE/psycholinguistics/emoji_analysis/plots/pol_distribution.png", width=700)
ggplot(Emoj_Pol, aes(x = Condition, fill = Answer)) +
  geom_bar(position = "fill", color = "black") +
  scale_y_continuous(labels = scales::percent) +  # Convert y-axis to percentages
  labs(
    x = "Condition",
    y = "Proportion",
    fill = "Answer",
    title = "Proportional Distribution of Answers by Condition"
  ) +
  theme_minimal()
dev.off()


#Pos_Initial Graph of Choices
png("C:/Users/magda/moje/LTE/psycholinguistics/emoji_analysis/plots/pol_pos_initial.png", width=700)
ggplot(Pos_InitialP, aes(x = Condition, fill = as.factor(Answer))) +
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
dev.off()

#Neg_Initial Graph of Choices
png("C:/Users/magda/moje/LTE/psycholinguistics/emoji_analysis/plots/pol_neg_initial.png", width=700)
ggplot(Neg_InitialP, aes(x = Condition, fill = as.factor(Answer))) +
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
dev.off()

#Pos_Final Graph of Choices
png("C:/Users/magda/moje/LTE/psycholinguistics/emoji_analysis/plots/pol_pos_final.png", width=700)
ggplot(Pos_FinalP, aes(x = Condition, fill = as.factor(Answer))) +
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
dev.off()

#Neg_Final Graph of Choices
png("C:/Users/magda/moje/LTE/psycholinguistics/emoji_analysis/plots/pol_neg_final.png", width=700)
ggplot(Neg_FinalP, aes(x = Condition, fill = as.factor(Answer))) +
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
dev.off()

# my plot :)
ggplot(Emoj_Pol %>% group_by(Condition), 
       aes(x = Condition, 
           fill = factor(Answer, levels = c("Subject", "Object", "Sender")))) +
  geom_bar(position = "dodge", color = "black", width = 0.6) +
  labs(
    x = "Conditions",
    y = "Count",  # Reflects counts of values
    fill = "Answer"
  ) + theme_minimal()

#First create binary factors for given answers
Emoj_Pol$Object = ifelse(Emoj_Pol$Answer == "Object", 1, 0)
Emoj_Pol$Subject = ifelse(Emoj_Pol$Answer == "Subject", 1, 0)
Emoj_Pol$Sender = ifelse(Emoj_Pol$Answer == "Sender", 1, 0)


#This model assesses the selection of Object (second character) across conditions
#Just like English - What we find is that Pos_initial (Highly significant***) is the least favorable condition to choose Object.
Obj_modelP <- glmer(Object ~ Condition + (1 | ID) + (1 | Item_Num), data = Emoj_Pol,  family = binomial)
summary(Obj_modelP)

#This model assesses the selection of Subject (first character) across conditions
#Just like English - Pos_initial (Highly significant***) is the most favorable condition to choose Subject 
#However, both Neg_Initial and Pos_Final are signicantly more favored than Neg_Final
Subj_modelP <- glmer(Subject ~ Condition + (1 | ID) + (1 | Item_Num), 
                     data = Emoj_Pol,  
                     family = binomial,
                     control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=2e5)))
summary(Subj_modelP)

#This model assesses the selection of Sender (sender of text) across conditions
#Just like English - Neg_Final condition is the most favorable condition to choose Sender
#Vitally, Pos_initial (Highly significant***) is the least favorable condition to choose Sender
#followed by Pos_Final and then Neg_Initial
Send_modelP <- glmer(Sender ~ Condition + (1 | ID) + (1 | Item_Num), data = Emoj_Pol,  family = binomial)
summary(Send_modelP)

summary(glmer(Sender ~ Condition + 
                (1 | ID) + 
                (1 | Item_Num) + 
                (1 | Rec) + 
                (1 | iOS)
              , data = Emoj_Pol
              , family = binomial
              , control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=2e5))))
