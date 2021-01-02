library(rstudioapi)
library(ggplot2)
library(plotly)

#author/questions?: Wim Pouw (wimpouw@gmail.com)

#CITATION OF TUTORIAL: 
#    Trujillo, J. P., & Pouw, W. (2019). Using video-based motion tracking to quantify speech-gesture synchrony.
#    Proceedings of the 6th meeting of Gesture and Speech in Interaction. Paderborn, Germany.

#CITATION OF CODE:
#    Pouw, W., Trujillo, J. P. (2019). Tutorial Gespin2019 - Using video-based motion tracking to quantify speech-gesture 
#     synchrony. doi: 10.17605/OSF.IO/RXB8J


####################################FUNCTIONS
#this function loads into a time series annotations dataframes with columns (begintime, endtime, annotation)
load.in.event <- function(time_ms_rec, g_d)
{
  output <- character(length = length(time_ms_rec))
  output <- NA
  for(i in g_d[,1])
  {
    print(i)
    output <- ifelse((time_ms_rec >= g_d[,1][g_d[,1] == i] & time_ms_rec <= g_d[,2][g_d[,1] == i]), as.character(g_d[,3][g_d[,1]==i]), output)
  }
  return(output)
}

###########################FOLDER LOCATIONS
parentfolder <- (dirname(rstudioapi::getSourceEditorContext()$path))  #what is the current folder
data_to_process <- paste0(dirname(parentfolder), "/DATA_TO_PROCESS/") #get the folder for MT and SOUND data
data_processed <- paste0(dirname(parentfolder), "/DATA_PROCESSED/") #get the folder for final saving
##########LOAD IN FILES
annot <-  read.csv(paste0(data_to_process, "annot_gesture_right.csv"))
MT <-  read.csv(paste0(data_to_process, "merged_GS.csv"))
############################

#load in for each row of the the time series whether a gesture event ocurred
  #first the annotations themselves (REP vs. BEAT)
MT$gesture_t <- load.in.event(MT$time_ms, annot)

  #we also just want for each gestur event a unique identifier so we can later loop through them
annot_new_ID <- annot
annot_new_ID[,3] <- as.character(1:length(annot_new_ID[,3])) #this just replaces the annotaitons with stringifield identifiers from 1 to N gestures
MT$gesture_ID <- load.in.event(MT$time_ms, annot_new_ID) #now add the identifier to the MT dataframe

      #NOW WE CAN SELECT RELEVANT Time series chunks! lets select a gesture and plot amplitude envelope with speed
      whichgesture <- "2"
      Pspeed <- ggplot(MT[MT$gesture_ID == whichgesture,], aes(x=time_ms, y = speed)) + geom_point(color = "blue") + theme_bw() + ylab("gesture speed")
      Penv <- ggplot(MT[MT$gesture_ID == whichgesture,], aes(x=time_ms, y = env)) + geom_point(color = "black") + theme_bw()+ ylab("speech amplitude")
      subplot(ggplotly(Pspeed), ggplotly(Penv), nrows=2,titleY = TRUE)

#SAVE THE FINAL PROCESSED DATASET
write.csv(MT, paste0(data_processed, "MT_p.csv"))
