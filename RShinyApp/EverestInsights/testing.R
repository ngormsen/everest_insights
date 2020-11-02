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

# PlotCohortAgeLinechart(dt)
PlotC3(dt, "Monthly Cohorts")

clv <- ComputeCLV(dt)
PlotCLVDensity(clv)



# Recency Frequency -------------------------------------------------------

# most recent purchase by customer
dt[, recentPurchaseTimestamp := max(orderTimestamp), by = custId]

frequency <- dt[, .N, by = .(custId, orderPeriod)]
frequency[, avgNumPurchasesPerMonth := mean(N), by = custId]
frequency <- unique(frequency, by = "custId")
frequency[, c("custId", "avgNumPurchasesPerMonth")]

# join
out <- merge(dt, frequency, all.x = T, by = "custId")
out <- out[, c("custId", "avgNumPurchasesPerMonth", "recentPurchaseTimestamp")]
out <- unique(out, by = "custId")
setnames(out,
         old = c("avgNumPurchasesPerMonth", "recentPurchaseTimestamp"),
         new = c("frequency", "recency"))


ggplot(out, aes(x = recency, y = frequency)) +
  geom_point()
