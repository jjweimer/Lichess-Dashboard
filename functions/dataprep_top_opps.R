dataprep_top_opps <- function(df){
  opp_counts <- df %>% group_by(opp_name, my_result) %>%
    count(opp_name, my_result)
  opp_counts_raw <- df %>% group_by(opp_name) %>% count(opp_name)
  colnames(opp_counts_raw)[2] <- "total_count"
  opp_counts <- left_join(opp_counts, opp_counts_raw, by = "opp_name")
  opp_counts <- opp_counts %>% arrange(-total_count)
  return(opp_counts)
}