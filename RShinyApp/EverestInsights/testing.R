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
cohortType <- "Monthly Cohorts"

dt <- CreateCohortCols(
  data = translogClean,
  cohortType = cohortType
)


# Cohort Chart -----------------------------------------------------------
PlotCohortAgeLinechart(dt)
clv <- ComputeCLV(dt)
PlotCLVDensity(clv)
PlotRecencyFrequency(ComputeRecencyFrequency(dt))

x <- GetDataCohortTableCustom(dt, x = "orderPeriod", var = "amountSpent", fun = mean, relativeTo = "acq")
PlotCohortTableCustom(x, perc = T)

acqRev <- dt %>%
  group_by(cohort) %>% 
  summarise(acqRev = var) %>% 
  filter(orderId = min(orderId))

GetDataCohortTableOfNumPurchases(dt, x = "orderPeriod", z = "amountSpent", fun = median)
