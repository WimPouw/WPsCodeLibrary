library(rstudioapi)
library(WaveletComp)
library(ggplot2)
library(plotly)

#author/questions?: Wim Pouw (wimpouw@gmail.com)

#CITATION OF TUTORIAL: 
#    Trujillo, J. P., & Pouw, W. (2019). Using video-based motion tracking to quantify speech-gesture synchrony.
#    Proceedings of the 6th meeting of Gesture and Speech in Interaction. Paderborn, Germany.

#CITATION OF CODE:
#    Pouw, W., Trujillo, J. P. (2019). Tutorial Gespin2019 - Using video-based motion tracking to quantify speech-gesture 
#     synchrony. doi: 10.17605/OSF.IO/RXB8J


#for info about wavelet and cross-wavlet analysis see: 
#for a tutorial: http://www.hs-stat.com/projects/WaveletComp/WaveletComp_guided_tour.pdf
#CRAN package information: https://cran.rstudio.com/web/packages/WaveletComp/WaveletComp.pdf

#FOLDER LOCATIONS
parentfolder <- (dirname(rstudioapi::getSourceEditorContext()$path))  #what is the current folder
TS <- read.csv(paste0(dirname(parentfolder), "/DATA_PROCESSED/MT_p.csv"))      #Load the processed data


#CROSS-WAVELET analysis
  # select a particular section of the retelling of the cartoon (e.g., 15-30 seconds)
      #save the following indices for later use (the indices that belong to 15 to 30 seconds of the Time series)
  snippet_indices <-  which(TS$time_ms < 30000 & TS$time_ms > 15000)

  #lets plot the selected portion of the timeseries and the amplitude envelope
  p_a <- ggplot(TS[  snippet_indices,], aes(x= time_ms-min(time_ms), y = speed)) + geom_line() + theme_bw()
  p_b <- ggplot(TS[ snippet_indices,], aes(x= time_ms-min(time_ms), y = env)) + geom_line(color = "red") + theme_bw()
  
    #plot them together
  subplot(ggplotly(p_a), ggplotly(p_b), nrows = 2)


#CROSS-WAVELET ANALYSIS
  my.data <- data.frame(x = TS$speed[snippet_indices], TS$env[snippet_indices])           #make an data.frame with the two relevant vectors
  my.w <- analyze.coherency(my.data, 
                            loess.span = 0,                         #does the series need to be smoothed?
                            dt = 1/100,                             #what are time units (100Hz, i., 0.01 seconds)
                            dj = 1/50,                              #what is the resolution in the frequecy domain that you want have?
                            lowerPeriod = 0.125,                    #the fastest period of interest we set at 8Hz (faster than the average syllable)
                            upperPeriod = 0.5,                      #the slowest period of interest we set at 2Hz (about the average length of a stroke)
                            make.pval = FALSE)                      #CWA allows you to produce p-values via monte carlo simulations, we are going to ignore this
    #speed wavelet power
  wt.image(my.w, my.series = 1)
    #envelope wavelet power
  wt.image(my.w, my.series = 2)
    #cross-wavelet power
  wc.image(my.w, which.image = "wp")            #cross-wavelet power plot
  wc.avg(my.w)                                  #what is the distribution of cross-wavelet power averaged over time?
  my.w$Period[which.max(my.w$Power.xy.avg)]     #which period is the dominant frequency at which gesture and speech couple 
  
  #over the frequency domain of 2-8Hz what is the average correlation strength (coherency) for these two time series?
  print(mean(my.w$Coherence.avg))
  

  