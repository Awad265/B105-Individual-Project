# B105 Applied Statistical Modelling

## Overview
This repositary contains the R script and supporting files for the B105 Applied Statistical Modelling individual final project.

## Dataset
- **Source:** Brazilian E-Commerce Public Dataset by Olist (Kaggle)
- **URL:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- **Tables used:** order payments, order reviews, order items (joined on order_id)
- **Size:** 97,916 orders after aggregation and joining

## How to Reproduce
1. Download the three required CSVs from the Kaggle link or uploaded "Data" folder. 
2. Open `B105.R` in RStudio, Posit Cloud, or an R-enabled Colab notebook.
3. Install required packages if not already installed: `install.packages(c("dplyr", "car"))`.
4. Adjust file paths if needed to match where the CSVs are stored, then source the script top to bottom.

## Creator 
Muhammad Awad Nadeem - Student at Gisma University of Applied Sciences
