# This script simulates the data pipeline of the app to develop and test
# new functions outside of the app.


# Load and Clean a Transaction Log
translogRaw <- as.data.table(read.csv("data/retail_relay2.csv"))
translogClean <- PreprocessRawTransactionLog(
  data = translogRaw,
  columns = list("custId" = "customerId",
                 "amountSpent" = "amountSpent",
                 "orderTimestamp" = "orderTimestamp")
)

# Create cohort-based data from aclean Transaction Log
cohortType <- "Quarterly Cohorts"

dt <- CreateCohortCols(
  data = translogClean,
  cohortType = cohortType
)


