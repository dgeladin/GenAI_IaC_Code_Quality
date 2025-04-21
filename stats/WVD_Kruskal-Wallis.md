WVD Kruskal-Wallis
================
Daniel Geladin
2025-04-18

``` r
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("ggpubr")

data=read.csv("data/WVD.csv")
head(data)
```

    TRUE                Model       WVD
    TRUE 1 Amazon_Q_Developer  6.588235
    TRUE 2 Amazon_Q_Developer 74.094718
    TRUE 3 Amazon_Q_Developer 58.280374
    TRUE 4 Amazon_Q_Developer 45.566038
    TRUE 5 Amazon_Q_Developer 32.434783
    TRUE 6 Amazon_Q_Developer 24.130435

``` r
library(dplyr)
```

    TRUE Warning: package 'dplyr' was built under R version 4.4.3

    TRUE 
    TRUE Attaching package: 'dplyr'

    TRUE The following objects are masked from 'package:stats':
    TRUE 
    TRUE     filter, lag

    TRUE The following objects are masked from 'package:base':
    TRUE 
    TRUE     intersect, setdiff, setequal, union

``` r
library(ggplot2)
```

    TRUE Warning: package 'ggplot2' was built under R version 4.4.3

``` r
library(ggpubr)
```

    TRUE Warning: package 'ggpubr' was built under R version 4.4.3

``` r
clean_data <- na.omit(data)

# Group by Model and run Shapiro-Wilk test on WVD
normality_results <- clean_data %>%
  group_by(Model) %>%
  summarise(
    p_value = shapiro.test(WVD)$p.value,
    .groups = "drop"
  )
normality_results
```

    TRUE # A tibble: 6 × 2
    TRUE   Model              p_value
    TRUE   <chr>                <dbl>
    TRUE 1 Amazon_Q_Developer 0.615  
    TRUE 2 Anthropic_Claude   0.178  
    TRUE 3 ChatGPT            0.00410
    TRUE 4 Gemini             0.242  
    TRUE 5 Github_Copilot     0.161  
    TRUE 6 Mistral            0.0987

``` r
#pval greater than 0.05, assumes normality. Anything lower than 0.05 can NOT assume normality. 

clean_data <- clean_data %>%
  mutate(log_WVD = log1p(WVD))  # log(1 + WVD)

# Check normality for each model
normality_results <- clean_data %>%
  group_by(Model) %>%
  summarise(
    p_value = shapiro.test(log_WVD)$p.value,
    .groups = "drop"
  )

data$Group <- ifelse(data$Model == "Amazon_Q_Developer", "Amazon_Q",
                    ifelse(data$Model == "Anthropic_Claude", "Anthropic",
                           ifelse(data$Model == "ChatGPT", "ChatGPT",
                                  ifelse(data$Model == "Gemini", "Gemini",
                                         ifelse(data$Model == "Github_Copilot", "Github_Copilot",
                                                ifelse(data$Model == "Mistral", "Mistral", NA))))))

# Print normality results
print(normality_results)
```

    TRUE # A tibble: 6 × 2
    TRUE   Model              p_value
    TRUE   <chr>                <dbl>
    TRUE 1 Amazon_Q_Developer  0.123 
    TRUE 2 Anthropic_Claude    0.0990
    TRUE 3 ChatGPT             0.245 
    TRUE 4 Gemini              0.334 
    TRUE 5 Github_Copilot      0.0575
    TRUE 6 Mistral             0.748

``` r
#compare (log-transformed) models
anova_result <- aov(log_WVD ~ Model, data = clean_data)
summary(anova_result)
```

    TRUE             Df Sum Sq Mean Sq F value Pr(>F)
    TRUE Model        5   0.72   0.144    0.14  0.982
    TRUE Residuals   54  55.63   1.030

``` r
#no significant difference in means between models

#comparing models using a test that doesn't assume normality 
kruskal_result <- kruskal.test(WVD ~ Model, data = clean_data)
kruskal_result
```

    TRUE 
    TRUE    Kruskal-Wallis rank sum test
    TRUE 
    TRUE data:  WVD by Model
    TRUE Kruskal-Wallis chi-squared = 0.96464, df = 5, p-value = 0.9654

``` r
#no significant difference in means between models
```

graphs

``` r
library(ggplot2)
# WVD Boxplot
ggplot(data, aes(x = factor(Group), y = WVD, fill = factor(Group))) +
  geom_boxplot() +
  labs(title = "WVD by Group", x = "Group", y = "WVD") +
  theme_minimal()
```

![](WVD_Kruskal-Wallis_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
# Histograms for WVD by group
ggplot(data, aes(x = WVD, fill = factor(Group))) +
  geom_histogram(position = "dodge", bins = 20) +
  labs(title = "Histogram of WVD by Group", x = "WVD", y = "Frequency") +
  theme_minimal()
```

![](WVD_Kruskal-Wallis_files/figure-gfm/unnamed-chunk-2-2.png)<!-- -->
