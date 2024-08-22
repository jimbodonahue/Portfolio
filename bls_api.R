### Users of the public API should cite the date that data were accessed or retrieved using the API. Users must clearly state that “BLS.gov cannot vouch for the data or analyses derived from these data after the data have been retrieved from BLS.gov.” The BLS.gov logo may not be used by persons who are not BLS employees or on products (including web pages) that are not BLS-sponsored.  ###

### Set up some globals
output <- "~/R/BLS/output.json"

# https://github.com/mikeasilva/blsAPI


library(blsAPI,rjson)

'registrationKey' = '702ca6c1c6d74d209de622450bcb198b'


### Let's make variables the easy(?) way
## in the loop, add smu first
states  <-  list(
  '01' '06', '36', '39', '47'
  ) # State codes are alphabetical, 00 is whole country
zip <- '00000' # zeros gives whole state
industry <- list('10000000', '15000000', '20000000', '30000000', '31000000', '32000000', '40000000', '41000000', '42000000', '43000000', '50000000', '55000000', '60000000', '65000000', '70000000', '80000000'
  )
datatype <- list('03','02','01') # 1=thousand employees, 2=ave wk hrs, 3=hourly wages


seriesid <- list() # this list stores the completed IDs
result <- list()   # this list stores the results, 1 item per state
varlist <- list()  # stores variable list, for unpacking
# loop to combine above data into full strings
for (a in length(states):1) {
  statename <- states[[1]]
  for (b in length(zip):1) {
    for (c in length(industry):1) {
      for (d in length(datatype):1) {
        seriesid [[length(seriesid) +1]] <- paste('SMU', statename, zip[c(b)], industry[c(c)], datatype[c(d)], sep="")
        # varlist[[length(varlist) +1]] <- paste('var', seriesid[[length(seriesid)]],sep="")
      }
    }
  }
}
length(seriesid) # to check how many IDs were created, limit is 50

payload <- list(
  'seriesid'=seriesid,
  'startyear'=2015,  # limit 20 years
  'endyear'=2024,
  'registrationKey' = 'registrationKey'
)
response <- blsAPI(payload, 2, TRUE) # payload, API 2.0, true=dataframe, false=json
## If json, uncomment next two lines
# json <- fromJSON(response)  # if json file
# result[[length(result) +1]] <- json
# }
### end gathering loop



### If json, this is a function that
apiDF <- function(data){
  df <- data.frame(year=character(),
                   period=character(),
                   periodName=character(),
                   value=character(),
                   stringsAsFactors=FALSE)

  i <- 0
  for(d in data){
    i <- i + 1
    df[i,] <- unlist(d)
  }
  return(df)
}


# Reference:
# https://github.com/cran/blsAPI
