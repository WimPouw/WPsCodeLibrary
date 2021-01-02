library(rstudioapi)
library(igraph)
library(dtw)
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
parentfolder <- (dirname(rstudioapi::getSourceEditorContext()$path))           #what is the current folder
TS <- read.csv(paste0(dirname(parentfolder), "/DATA_PROCESSED/MT_p.csv"))      #Load the processed data

#GESTURE NETWORK ANALYSIS
  #initialialize network variables and properties
  sizenetwork <- length(unique(TS$gesture_ID[!is.na(TS$gesture_ID)]))        #how many gesture events are there? (36 in this case)
  networkmatrix <- matrix(nrow = sizenetwork, ncol = sizenetwork)            #make a matrix that is 36*36 large (1296 cells!)
  list_gestures <- unique(TS$gesture_ID[!is.na(TS$gesture_ID)])              #list all gesture_ID's for looping
  gtypes <- character()                                                      #initialize some attribute data (e.g., gesture types)
  
  #construct the weighted matrix with dynamic time warping distances (normalized)
  for(a in list_gestures)
  {
    #save attribute (gesture_type) of this gesture
    gtypes <- c(gtypes, as.character(unique(TS$gesture_t[which(TS$gesture_ID==a)])))
    
    #now make comparisons for all other gestures in the ensemble
    
    for(b in list_gestures)
    {
      #get indices (i.e., locations) for each gesture in dataset
      indexa <- which(list_gestures == a)
      indexb <- which(list_gestures == b)
      
      #velocity profile DTW analyses
      dtwR <- dtw(TS$speed[which(TS$gesture_ID==a)], TS$speed[which(TS$gesture_ID==b)])     #perform dynamic time warping and save in object
      allignment <- dtwR$normalizedDistance                                                 #get the normalized distance
      networkmatrix[indexa,indexb] <- allignment                                            #fill the matrix with distances
    }
    print(paste0("completing gesture ID:", a)) #get some info on how the loop progresses
  }
  #after looping set column names of the network to g_types
  colnames(networkmatrix) <-   gtypes
  
  #plot networks for gesture typology
  gt <- graph.adjacency( networkmatrix ,                 #make an igraph network object with network matrix
                         mode="undirected",              #undirected graph as comparisons of gesture 1 and gesture 2 is the same as the comparisons of gesture 2 with gesture 1   
                         weighted=TRUE,                  #the comparison is continunous (DTW distance) and thus edges are "weighted"
                         diag = FALSE)                   #the diagonal's of the matrix are non-informative as they are 0; the DTW distance of (gesture 1 versus gesture 1) = 0               
  lt <- layout_with_mds(gt, dist = networkmatrix)        #apply multidimensional scaling for network layout (so that layout reflects distance) #
  vcol <- ifelse(gtypes == "REP", "red", "cyan" )        #make a color variable based on gesture type for the plot later non
  plot(gt, layout=lt, vertex.label=NA, vertex.size = 6, vertex.color=vcol)

  #average distance for beat-beat gestures and beat-iconic gestures and iconic-iconic gestures
  mean(networkmatrix[which(gtypes=="BEAT"),which(gtypes=="BEAT")]) #AVERAGE BEAT-BEAT GESTURE DISTANCE
  mean(networkmatrix[which(gtypes=="BEAT"),which(gtypes=="REP")])  #AVERAGE BEAT_ICONIC GESTURE DISTANCE

  

  