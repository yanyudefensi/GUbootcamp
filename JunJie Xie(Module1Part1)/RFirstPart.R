#/Users/junjiexie/Documents/R/pre_class/saveFirstPart.txt
#"/Users/junjiexie/Downloads/TitanicDataset.csv"

#start record the result in txt(must create in advance)
dir = getwd()
sink_path = paste(dir, "/saveFirstPart.txt", sep = "")
sink(sink_path)

#load data and check it

#Please put your data in Rstudio working path
cat("clean data and check it\n\n")
file_path="/TitanicDataset.csv"
new_file_path = paste(dir, file_path, sep = "")
TitanicDF <- read.csv(new_file_path, na.string=c(""))
(head(TitanicDF, n=5))
cat("\n\n")
(str(TitanicDF))
cat("\n\n")

#clean data part1
TitanicDF$Pclass=factor(TitanicDF$Pclass)

TitanicDF <- subset(TitanicDF,select = -PassengerId)
TitanicDF <- subset(TitanicDF,select = -Name)
TitanicDF <- subset(TitanicDF,select = -c(Cabin,Ticket))

TitanicDF$Fare=round(TitanicDF$Fare,digits = 2)
cat("clean data Part1\n\n")
(head(TitanicDF, n=5))
cat("\n\n")

#clean data part2
cat("clean data Part2\n\n")
cat("The Titanic dataset has a total of ", nrow(TitanicDF), "rows.\n")
cat("The Titanic dataset has a total of ", ncol(TitanicDF), "columns.\n\n")

cat("\nfind the number of columns which are not Null\n\n")
(nrow(TitanicDF[complete.cases(TitanicDF),]))
TitanicDF <- TitanicDF[complete.cases(TitanicDF),]

#Aggregate FamilyNum
cat("Aggregate FamilyNum\n\n")
TitanicDF$FamilyNum = TitanicDF$SibSp + TitanicDF$Parch
TitanicDF <- subset(TitanicDF,select = -c(SibSp,Parch))

#EDA Part1
printVarable = function(TitanicDF) {
  colNames = names(TitanicDF)
  for(i in colNames) {
    cat("the col is",i,"\n\n")
    print(table(TitanicDF[i]))
    cat("\n")
  }
}

cat("\nEDA part1\n\n")
cat("print table for each variable\n\n")
printVarable(TitanicDF)

printSummary = function(TitanicDF) {
  for(i in names(TitanicDF)) {
    if(class(TitanicDF[[i]]) == "numeric") {
      cat("The mode of ", i, "is\t" )
      cat(which.max(table(TitanicDF[i])),"\n")
      print(summary(TitanicDF[i]))
    } else {
      cat("The mode of ", i, "is\t" )
      # find the mode when it's not numeric
      cat(names(sort(-table(TitanicDF[i])))[1],"\n")
    }
  }
}


cat("\nSummary of each col\n\n")
printSummary(TitanicDF)

# t-test of Age and Sex
cat("\n\nt-test of Age and Sex\n\n")
t.test(TitanicDF$Age~TitanicDF$Sex)
cat("\n\n")
head(TitanicDF)

#Visual EDA
install.packages("ggplot2")
library("ggplot2")

ggplot(TitanicDF,aes(x=Survived,y=Survived,color="red"))+geom_point()+annotate("text",x = 0.5 , y = 0.5,parse = T, label = "showSurvived") 
ggplot(TitanicDF,aes(x=Pclass,y=Pclass,color="red"))+geom_jitter()+annotate("text",x = 2 , y = 3,parse = T, label = "ShowPClass")
ggplot(TitanicDF,aes(x=Sex,y=Sex,color="red"))+geom_line()+annotate("text",x = 1.5 , y = 0.5,parse = T, label = "ShowSex")
ggplot(TitanicDF,aes(x=Age,y=Age,color="red"))+geom_area()+annotate("text",x = 40 , y = 40,parse = T, label = "ShowAge")
ggplot(TitanicDF,aes(Fare,color="red"))+geom_histogram(binwidth = 1)+annotate("text",x = 250 , y = 75,parse = T, label = "ShowFare")
ggplot(TitanicDF,aes(x=Embarked,y=Embarked,color="red"))+geom_boxplot()+annotate("text",x = 2 , y = 3,parse = T, label = "ShowEmbarked")
ggplot(TitanicDF,aes(FamilyNum,color="red"))+geom_freqpoly()+annotate("text",x = 4 , y = 400 , parse = T, label = "ShowFare")



ggplot(TitanicDF,aes(x=Pclass,y=Fare))+geom_violin()

ggplot(TitanicDF,aes(x=Sex,y=Survived,color="red"))+geom_violin()+annotate("text",x = 1.5 , y = 1.5 , parse = T, label = "TheFemaleHasHigherSurvivedPossibility")

#Feature Generation

createAgeBin = function(TitanicDF) {
  j = 1
  for (i in TitanicDF$Age) {
    if (i <= 11) {
      TitanicDF$AgeBin[j] = "Child"
    } else if(i >= 12 && i <= 19) {
      TitanicDF$AgeBin[j] = "Teen"
    } else if(i >= 20 && i <= 45) {
      TitanicDF$AgeBin[j] = "middle"
    } else if(i >= 46) {
      TitanicDF$AgeBin[j] = "Late"
    }
    j = j + 1
  }
  return(TitanicDF)
}

TitanicDF = createAgeBin(TitanicDF)

cat("\n\n")
cat("Feature Generation\n\n")
head(TitanicDF,n=20)

#File I/O Part1
#end record the result in txt
sink() 

#save a clean dataframe to csv file
write.table(TitanicDF,"/Users/junjiexie/Documents/R/pre_class/CleanTitanicDF.csv")
