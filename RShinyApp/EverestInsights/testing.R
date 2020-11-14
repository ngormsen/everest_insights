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


data <- GetDataCohortTableOfNumPurchases(dt, x = "orderPeriod")

dt %>% 
  group_by(cohort, orderPeriod) %>% 
  count() %>% 
  ggplot(aes(x = orderPeriod, y = reorder(cohort, desc(cohort)), fill = n)) +
  geom_raster() +
  geom_text(aes(label = n), color = "black") +
  scale_fill_continuous(high = "#239af6", low = "#e7f4fe") +
  theme_classic() +
  ggtitle("Number of Purchases") +
  theme(
    axis.text = element_text(color = "grey50", size = 12),
    axis.text.x = element_text(angle = 60, hjust = .5, vjust = .5, face = "plain"),
    axis.title = element_text(color = "grey30", size = 12, face = "bold"),
    axis.title.y = element_text(angle = 0),
    axis.line = element_line(color = "grey50"), 
    legend.position = "none"
  )

data <- dt %>% 
  group_by(cohort, orderPeriod) %>% 
  count() %>% 
  mutate(cohort = as.factor(cohort)) %>% 
  mutate(cohort = factor(cohort, levels = rev(levels(cohort))))

PlotCohortTableOfNumPurchases(data)
