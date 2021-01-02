library(rstudioapi)    #functions for time series functions (e.g., NA.approx)
library(ggplot2)
library(plotly)
#author/questions?: Wim Pouw (wimpouw@gmail.com)

#CITATION OF TUTORIAL: 
#    Trujillo, J. P., & Pouw, W. (2019). Using video-based motion tracking to quantify speech-gesture synchrony.
#    Proceedings of the 6th meeting of Gesture and Speech in Interaction. Paderborn, Germany.

#CITATION OF CODE:
#    Pouw, W., Trujillo, J. P. (2019). Tutorial Gespin2019 - Using video-based motion tracking to quantify speech-gesture 
#     synchrony. doi: 10.17605/OSF.IO/RXB8J


#FOLDER LOCATIONS
parentfolder <- (dirname(rstudioapi::getSourceEditorContext()$path))  #what is the current folder
TS <- read.csv(paste0(dirname(parentfolder), "/DATA_PROCESSED/MT_p.csv"))      #Load the processed data

#TIMING OF PEAK SPEED
TS$peak_speed <- ave(TS$speed, TS$gesture_ID, FUN = max)            #for every gesture determine the maximum observed speed
TS$peak_speed[is.na(TS$gesture_ID)] <-NA                            #only keep actual gesture event peak speed, not NA events
TS$peak_speed <- ifelse(TS$peak_speed == TS$speed, TS$speed, NA)  #keep only one observation of peak speed observation peak speed
  #we also want the timings for those peaks in speed
TS$timing_peak_speed <- ifelse(!is.na(TS$peak_speed), TS$time_ms, NA)

#mark the time for each gesture where the peak ENV was reached (NOTE this is defined by the time window of the gesture itself; so suboptimal)
TS$peak_env <- ave(TS$env, TS$gesture_ID, FUN = max)            #for every gesture determine the maximum observed speed
TS$peak_env[is.na(TS$gesture_ID)] <-NA                            #only keep actual gesture event peak speeds, not NA events
TS$peak_env <- ifelse(TS$peak_env == TS$env, TS$time_ms, NA)

#we only want the time at which the peak in speed was reached
TS$timing_peak_env <- ifelse(!is.na(TS$peak_env), TS$time_ms, NA)

#make a timing dataset
asynchrony <- TS$timing_peak_speed[!is.na(TS$timing_peak_speed)]-TS$timing_peak_env[!is.na(TS$timing_peak_env)] #asynchrony in time
g_type <- TS$gesture_t[!is.na(TS$peak_env)] #gesture_types
peak_speed <- TS$peak_speed[!is.na(TS$peak_speed)] #peak speed
peak_env <- TS$peak_env[!is.na(TS$peak_env)]       #peak envelope

  #make a data frame object that combines info about asynchrony with g_type (just pasting it as columns next to each other)
t_dat <- cbind.data.frame(asynchrony, g_type, peak_speed, peak_env)

#what are the means for the timing distributions between beat and rep gestures? (note that negative numbers mean gesture precedes speech)
mbeat <- mean(t_dat$asynchrony[t_dat$g_type=="BEAT"])
mrep <- mean(t_dat$asynchrony[t_dat$g_type=="REP"])

    #make a density plot
p_time <- ggplot(t_dat, aes(x= asynchrony, color = g_type)) + geom_density() +
  geom_vline(xintercept =mbeat, color = "red") +  geom_vline(xintercept =mrep, color = "cyan") + xlim(-800,800) +
   theme_bw()
ggplotly(p_time)


  ##########################IF WE HAVE TIME
  #NOTE that the above density analysis is not really ideal because the peak is determined within a gesture event
  #we would rather have the nearest peak of the amplitude envelope, rather than the max peak within a gesture event window
  #another cool way is to go for a more continuous approach: what if we look at all the trajectories of the envelope
  #around the moment (-+ 250 milliseconds) that a peak in speed emerged.
  
mfield <- data.frame() #initialize a data.frame for all the trajectories
for(ID in unique(TS$gesture_ID[!is.na(TS$gesture_ID)])) #loop through all gesture ID's
{
  temp <- subset(TS, gesture_ID==ID)                                      #select a time series chunk having that gesture ID
  TS$time_temp <- TS$time_ms-temp$time_ms[!is.na(temp$timing_peak_speed)] #subtract from a temporary time vector in the original TS the timing of the peak speed of that gesture 
  tempTS <- TS[abs(TS$time_temp) < 250 & TS$gesture_ID==ID,]              #now keep only the original TS where 250 millisecond after and before the peak speed
  mfieldtemp <- data.frame(matrix(nrow=length(tempTS$env)))               #
  mfieldtemp$time <-  tempTS$time_temp                                    #save the time vector (time intervals may be unique to this chunk)
  mfieldtemp$ENV <-   tempTS$env                                          #save the amplitude envelope trajectory for this particular chunk of TS
  mfieldtemp$g_type <- unique(tempTS$gesture_t[!is.na(tempTS$gesture_t)]) #save the gesture_type
  mfieldtemp$g_ID <- ID                                                   #save the ID
  mfield <- rbind.data.frame(mfield, mfieldtemp)                          #save this loop-cycle's result into a full dataset containing all data
}

#what is mean field for of the amplitude envelope around the peak (250 ms) in speed depending on the gesture
p1 <- ggplot(mfield, aes(x=time, y = ENV, color = g_type, group = as.factor(g_ID))) + geom_line(alpha=0.7) + theme_bw()
p2 <- ggplot(mfield, aes(x=time, y = ENV, color = g_type)) + geom_smooth(size = 2) + theme_bw()
 
#plot
subplot(ggplotly(p1), ggplotly(p2)) #left panel shows the different trajectories around peak speed/
                                    #right panel shows the mean field (smoothed)



##############################################IF WE HAVE TIME#########################################
  #what is the relation between the value of the peak in envelope and the value of the peak in speed
p_corr <- ggplot(t_dat, aes(x= peak_speed, y = peak_env, color = g_type)) + geom_point() + geom_smooth(method = "lm") + theme_bw()
ggplotly(p_corr)
  

