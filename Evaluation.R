# install.packages('Hmisc')

source("submission.R") # by Taylor Pospisil & Lee Richardson

rm(list = setdiff(ls(), "speech")) # cleanup

object.size(speech) # 7512 bytes

## Speed-test
library(microbenchmark)
microbenchmark(speech(300))
# Unit: milliseconds
#        expr      min       lq     mean   median       uq      max neval
# speech(300) 91.98673 100.7441 124.6164 107.5808 129.2657 360.9954   100

microbenchmark(speech(300), times = 100L, unit = "s")
# Unit: seconds
#        expr        min         lq      mean     median        uq       max neval
# speech(300) 0.09041056 0.09584361 0.1077692 0.09853412 0.1061209 0.2233293   100

set.seed(0)
submission <- speech(300)
# For some reason first 795 characters = a list of URLs
submission <- substr(submission, 796, 1e4)

## Write to text file.
writeLines(submission, "entry.txt")

## Convert text to speech.
# $> sudo port install lame
system('say -f "entry.txt" -o entry.aiff;
       lame --quiet -m m entry.aiff entry.mp3;
       rm -rf entry.aiff')
