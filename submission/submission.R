## Our approach is just a simple Markov-chain bot.

require(Hmisc) # for inc function

make <- function(filenames) {
    ## Creates self-contained function, takes as argument the list of
    ## filenames containing the speeches

    Words2Numbers <- function(text, lookup) {
        ## Convert words into a set of indices
        
        ## Explicitly construct the reversed dictionary
        rev <- list()
        for(i in seq_along(lookup)) {
            rev[lookup[i]] <- i
        }
        
        return(as.numeric(rev[text]))
    }
    
    Numbers2Words <- function(sequence, lookup) {
        ## Convert sequence of indices into corresponding words
        return(paste0(lookup[sequence], collapse = " "))
    }
    
    LoadData <- function(fileNames) {
        ## Read in the data from the given fileNames, convert to indices,
        ## and return both indices and dictionary
        
        text <- c()
        
        for(file in fileNames) {
            ## Scan can separate words for us
            text <- c(text, scan(file, "string"))
        }
        
        lookup <- unique(text)
        text <- Words2Numbers(text, lookup)
        
        return(list(text = text, lookup = lookup))
    }

    TrainMarkov <- function(text, lookup) {
        ## Creates the transition probability matrix, T[i,j] is the number
        ## of times word j follows word i. No need to standardize since
        ## all functions that use T will implicity standardize
        
        N <- length(lookup)
        T <- matrix(0, N, N)
        
        for(i in 2:length(text)) {
            inc(T[text[i - 1], text[i]]) <- 1
        }
    
        return(T)
    }
    
    SampleMarkov <- function(T, len, start) {
        ## Samples a sequence of length len from the Markov Chain
        ## described by transition matrix T, starting with start.
        
        N <- nrow(T)
        
        out <- rep(NA, len)
        out[1] <- start
        
        for(i in 2:len) {
            out[i] <- sample(1:N, 1, replace = FALSE, prob = T[out[i-1], ])
        }
        
        return(out)
    }
    
    ## Load 
    data <- LoadData(fileNames)
    
    T <- TrainMarkov(data$text, data$lookup)
    
    GenerateSpeech <- function(len) {
        ## Generates a speech of length len
        nums <- SampleMarkov(T, len, 1)
        words <- Numbers2Words(nums, data$lookup)
        return(words)
    }

    return(GenerateSpeech)
}

fileNames <- dir("Documents", full.names = TRUE)

speech <- make(fileNames)
