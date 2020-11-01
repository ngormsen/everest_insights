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


# Plot C3Function ----------------------------------------------------------------
dtPlt <- dt[, .N, by = .(cohort, orderPeriod)]

if (cohortType == "Monthly Cohorts"){
  dtPlt[, period := as.Date(paste0(orderPeriod, "-01"))]
} else if (cohortType == "Yearly Cohorts"){
  dtPlt[, period := orderPeriod]
} else if (cohortType == "Quarterly Cohorts"){
  dtPlt[, period := orderPeriod]
}

# We need to add an additional row for each cohort with the dependent variable
# equal to zero, such that the chart doesn't have these weird-looking "steps"
# whenever a new cohort joins.
cohorts <- unique(dtPlt$cohort)

# Compute period before acquisition
if (cohortType == "Monthly Cohorts"){
  # Monthly Cohorts: string "yyyy-mm"
  cohortsTemp <- as.Date(paste0(cohorts, "-01"))
  periodBeforeAcquisition <- cohortsTemp %m-% months(1)
} else if (cohortType == "Quarterly Cohorts"){
  # Quarterly Cohorts: string "yyyy.q"
  periodBeforeAcquisition <- sapply(cohorts, function(cohort) {
    year <- as.numeric(str_extract(cohort, "[0-9]+"))
    qrtr <- as.numeric(str_sub(cohort, -1, -1))
    if (qrtr == 1) {
      periodBeforeAcquisition <- as.numeric(paste0(year-1, ".", 4))
    } else {
      periodBeforeAcquisition <- as.numeric(paste0(year, ".", qrtr-1))
    }
    return(periodBeforeAcquisition)
  })
} else if (cohortType == "Yearly Cohorts"){
  # Yearly Cohorts: string "yyyy"
  periodBeforeAcquisition <- as.character(as.numeric(cohorts) - 1)
}

tempRows <- data.table(
  cohort = cohorts,
  period = periodBeforeAcquisition,
  N = 0 # dependent variable
)


dtPlt <- rbind(dtPlt[, c("cohort", "period", "N")], tempRows)

if (cohortType == "Yearly Cohorts") {
  dtPlt$period <- as.numeric(dtPlt$period)
}
if (cohortType == "Quarterly Cohorts") {
  dtPlt$period <- sapply(dtPlt$period, function(x) QuarterToTimestamp(x))
}
dtPlt %>% 
  mutate(cohort = as.factor(cohort)) %>% 
  mutate(cohort = fct_reorder(cohort, desc(cohort))) %>% 
  ggplot(aes(x = period, y = N, fill = cohort)) +
  geom_area(position = "stack", alpha = 0.8) +
  geom_line(position = "stack", alpha=0.5) +
  theme_bw() +
  ylab("Number of Customers") +
  xlab("Period")

# 
# date <- as.Date("2020-12-01")
# dateQuarter <- lubridate::quarter(date, with_year = T)
# 
# yr <-   as.numeric(str_extract(dateQuarter, "[0-9]+"))
# qrtr <- as.numeric(str_sub(dateQuarter, -1, -1))
