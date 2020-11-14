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


GetDataCohortTableCustom <- function(translog, x, z, fun){
  data <- translog %>% 
    group_by(cohort, get(x)) %>% 
    summarise_at(.vars = z, .funs = fun) %>% 
    rename(period = `get(x)`) %>%
    mutate(cohort = as.factor(cohort)) %>% 
    mutate(cohort = factor(cohort, levels = rev(levels(cohort)))) %>% 
    setDT()
  
  setnames(data, old = z, new = "z")
  return(data)
}

GetDataCohortTableOfNumPurchases(dt, x = "orderPeriod", z = "amountSpent", fun = median)
