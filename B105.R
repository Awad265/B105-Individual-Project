# ============================================
# B105 Applied Statistical Modelling
# Olist Brazilian E-Commerce Analysis
# Single Hypothesis: Does payment_type affect payment_value?
# Dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
# ============================================

# ---- Variables Used ----
# IV: payment_type - nominal categorical, 4 levels (credit_card, boleto, debit_card, voucher)
# DV: payment_value - continuous, ratio-scale (Brazilian Real, R$)
#
# H0: There is no significant difference in mean payment_value across payment types.
# H1: At least one payment type differs significantly in mean payment_value.

# ---- Step 1: Load libraries ----
install.packages("dplyr")
install.packages("car")
install.packages("readr")
library(dplyr)
library(car)
library(readr)

# ---- Step 2: Load data ----
# Files are inside the B105 subfolder in this project
payments <- read_csv("B105/olist_order_payments_dataset.csv")
reviews  <- read_csv("B105/olist_order_reviews_dataset.csv")
items    <- read_csv("B105/olist_order_items_dataset.csv")

# Convert payment_type to factor (readr loads it as character by default)
payments$payment_type <- as.factor(payments$payment_type)

str(payments)
str(reviews)
str(items)

# ---- Step 3: Aggregate and join ----
# NOTE: named df_final (not df) - "df" can be shadowed by R's built-in
# F-distribution function in some sessions, which breaks later functions.

payments_agg <- payments %>%
  group_by(order_id) %>%
  summarise(
    payment_type = first(payment_type),
    payment_installments = first(payment_installments),
    payment_value = sum(payment_value)
  )

items_agg <- items %>%
  group_by(order_id) %>%
  summarise(
    price = sum(price),
    freight_value = sum(freight_value)
  )

reviews_clean <- reviews %>%
  select(order_id, review_score) %>%
  distinct(order_id, .keep_all = TRUE)

df_final <- payments_agg %>%
  inner_join(items_agg, by = "order_id") %>%
  inner_join(reviews_clean, by = "order_id")

nrow(df_final)      # should be 97,916 orders
str(df_final)
summary(df_final)

# ---- Step 4: Data cleaning and quality check ----
# payment_type may contain an empty "not_defined" factor level,
# which breaks statistical tests if left in. Must be dropped first.

df_clean <- df_final %>% filter(payment_type != "not_defined")
df_clean$payment_type <- droplevels(df_clean$payment_type)

table(df_clean$payment_type)
sum(is.na(df_clean$payment_value))

# ============================================
# Test Selection:
# IV is categorical with >2 groups, DV is continuous -> One-Way ANOVA
# is the appropriate primary test. t-test and regression follow as
# supporting checks, not separate hypotheses.
# ============================================

# ---- Descriptive statistics ----
df_clean %>%
  group_by(payment_type) %>%
  summarise(mean_val = mean(payment_value), sd = sd(payment_value), n = n())

# ============================================
# PRIMARY TEST: One-Way ANOVA
# ============================================

# Assumption check: homogeneity of variance
leveneTest(payment_value ~ payment_type, data = df_clean)

# Standard ANOVA
aov_model <- aov(payment_value ~ payment_type, data = df_clean)
summary(aov_model)

# Levene's test is expected to be significant (unequal variances),
# so Welch's ANOVA is used as the trusted result:
oneway.test(payment_value ~ payment_type, data = df_clean, var.equal = FALSE)

# Post-hoc pairwise comparisons
TukeyHSD(aov_model)

# ============================================
# SUPPORTING CHECK A: Independent t-test (credit_card vs boleto)
# ============================================

t_data <- df_clean %>% filter(payment_type %in% c("credit_card", "boleto"))
t_data$payment_type <- droplevels(t_data$payment_type)

leveneTest(payment_value ~ payment_type, data = t_data)
t.test(payment_value ~ payment_type, data = t_data)

# ============================================
# SUPPORTING CHECK B: Simple linear regression
# ============================================

lm_payment <- lm(payment_value ~ payment_type, data = df_clean)
summary(lm_payment)