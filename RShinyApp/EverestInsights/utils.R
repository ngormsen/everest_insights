
# Computations ------------------------------------------------------------
PreprocessRawTransactionLog <- function(data, columns){
  # only select relevant columns
  dtOut <- data[, c(columns[["custId"]],
                    columns[["amountSpent"]],
                    columns[["orderTimestamp"]]), with=F]
  
  # rename columns
  setnames(dtOut, new = names(columns))
  
  # Fix datatypes
  dtOut[, orderTimestamp := as.Date(orderTimestamp)]
  return(dtOut)
}

CreateCohortCols <- function(data, cohortType){
  dt <- copy(data)
  
  dt[, acqTimestamp := min(orderTimestamp), by = .(custId)]
  
  dt[, acqMonth := lubridate::month(acqTimestamp)]
  dt[, acqQuarter := lubridate::quarter(acqTimestamp)]
  dt[, acqYear := lubridate::year(acqTimestamp)]
  
  minAcqMonth <- min(dt$acqMonth)
  minAcqQuarter <- min(dt$acqQuarter)
  minAcqYear <- min(dt$acqYear)
  
  dt[, orderMonth := lubridate::month(orderTimestamp)]
  dt[, orderQuarter := lubridate::quarter(orderTimestamp)]
  dt[, orderYear := lubridate::year(orderTimestamp)]
  dt[, orderYearMonth := format(orderTimestamp, "%Y-%m")]
  
  if (cohortType == "Monthly Cohorts"){
    dt[, cohort := format(acqTimestamp, "%Y-%m")]
    dt[, cohortAge := (orderYear - acqYear) * 12 + (orderMonth - acqMonth)]
    dt[, orderPeriod := format(orderTimestamp, "%Y-%m")]
  }
  if (cohortType == "Quarterly Cohorts"){
    dt[, cohort := lubridate::quarter(acqTimestamp, with_year = T)]
    dt[, cohortAge := (orderYear - acqYear) * 4 + (orderQuarter - acqQuarter)]
    dt[, orderPeriod := lubridate::quarter(orderTimestamp, with_year = T)]
  }
  if (cohortType == "Yearly Cohorts"){
    dt[, cohort := format(acqTimestamp, "%Y")]
    dt[, cohortAge := orderYear - acqYear]
    dt[, orderPeriod := lubridate::year(orderTimestamp)]
  }
  return(dt[, c("custId", "amountSpent", "orderTimestamp", "orderPeriod", "orderYearMonth", "cohort", "cohortAge")])
}

ComputeCLV <- function(transLog) {
  dt <- copy(transLog)
  dt[, avgAmountSpentPerOrder := mean(amountSpent), by = custId]
  dt[, numOrdersPerMonth := .N, by = .(custId, orderYearMonth)]
  dt[, avgNumOrdersPerMonth := mean(numOrdersPerMonth), by = custId]
  dt[, avgRevenuePerMonth := avgAmountSpentPerOrder * avgNumOrdersPerMonth]
  dt[, retentionRate := 0.8]
  dt[, discRateYearly := 0.1]
  dt[, discRateMonthly := discRateYearly^(1/12)]
  dt[, marginMultiplier := 1 / (1 - (retentionRate/(1 + discRateMonthly)))]
  
  dataPerCustomer <- unique(dt, by = "custId")
  dataPerCustomer[, clv := avgRevenuePerMonth * marginMultiplier]
  
  return(dataPerCustomer[, c("custId", "clv")])
}

# Plots -------------------------------------------------------------------
PlotC3 <- function(data, cohortType){
  # Note: works only for monthly periods!!
  dtPlt <- data[, .N, by = .(cohort, orderPeriod)]
  
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
}

PlotCohortAgeLinechart <- function(data){
  dtPlt <- data[, .N, by = .(cohort, cohortAge)]
  dtPlt[, cohort := as.character(cohort)]
  #        cohort cohortAge N
  # 1: 2009-01-11         0 2
  # 2: 2009-01-11         1 5
  dtPlt %>% 
    mutate(cohort = fct_reorder(cohort, desc(cohort))) %>% 
    ggplot(aes(x = cohortAge, y = N, color = cohort)) +
    geom_line() +
    theme_bw()
}

PlotCLVDensity <- function(dataCLV) {
  ggplot(clvs, aes(x = clv)) +
    geom_density(color = "white", fill = "purple", alpha = 0.5) +
    geom_rug() +
    theme_bw()
}



# Small Help Functions ---------------------------------------------------------------
QuarterToTimestamp <- function(yearDotQuarter){
  year <- as.numeric(str_extract(yearDotQuarter, "[0-9]+"))
  qrtr <- as.numeric(str_sub(yearDotQuarter, -1, -1))
  if (qrtr == 1) monthDay <- "01-01" # 1.Jan - 31. März
  if (qrtr == 2) monthDay <- "04-01" # 1.April - 30.Juni
  if (qrtr == 3) monthDay <- "07-01" # 1. Juli - 30. Sept
  if (qrtr == 4) monthDay <- "10-01" # 1. Okt - 31.Dez
  return(as.Date(paste0(year, "-", monthDay)))
}
