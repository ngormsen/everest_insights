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
  }
  if (cohortType == "Quarterly Cohorts"){
    dt[, cohort := lubridate::quarter(acqTimestamp, with_year = T)]
    dt[, cohortAge := (orderYear - acqYear) * 4 + (orderQuarter - acqQuarter)]
  }
  if (cohortType == "Yearly Cohorts"){
    dt[, cohort := format(acqTimestamp, "%Y")]
    dt[, cohortAge := orderYear - acqYear]
  }
  return(dt[, c("custId", "amountSpent", "orderTimestamp", "orderYearMonth", "cohort", "cohortAge")])
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

PlotC3 <- function(data){
  # Note: works only for monthly periods!!
  dtPlt <- data[, .N, by = .(cohort, orderYearMonth)]
  dtPlt[, orderYearMonth := as.Date(paste0(orderYearMonth, "-01"))]
  
  cohorts <- unique(dtPlt$cohort)
  acqDate <- as.Date(paste0(cohorts, "-01"))
  acqDateAdjusted <- acqDate %m-% months(1)
  
  tempRows <- data.table(
    cohort = cohorts,
    period = acqDateAdjusted,
    N = 0
  )
  
  setnames(dtPlt, old = "orderYearMonth", new = "period")
  dtPlt <- rbind(dtPlt[, c("cohort", "period", "N")], tempRows)
  
  dtPlt %>% 
    mutate(cohort = fct_reorder(cohort, desc(cohort))) %>% 
    ggplot(aes(x = period, y = N, fill = cohort)) +
      geom_area(position = "stack", alpha = 0.8) +
      geom_line(position = "stack", alpha=0.5) +
      theme_bw() +
      ylab("Number of Customers") +
      xlab("Period")
}
