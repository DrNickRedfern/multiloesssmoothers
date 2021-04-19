#' loessggplot
#'
#' The loessggplot function fits a set of LOESS smoothers to the shot length data of a motion picture, 
#' iterating over a range of spans specified by the user and plotting the result using ggplot2, 
#' in order to identify the temporal structure of a film's editing without committing the analyst 
#' to a particular level of smoothing before applying the function.
#' 
#' @param x a numeric vector of shot lengths 
#' @param low the lower bound for the range of spans of the loess smoothers
#' @param high the upper bound for the range of spans of the loess smoothers
#' @param step the increment in the value of the span for each iteration
#' @param title a title for the plot
#' @param ticks control the spacing of the ticks on the guide between low and high
#' 
#' @return a plot of the range of loess smoothers
#' 
#' @import ggplot2
#' 
#' @export
loessggplot <- function(x, low = 0.1, high = 0.9, step = 0.01, title = "", ticks = 0.1){ 
  
  n <- length(x) 
  t <- cumsum(x); t <- 100*t/max(t) # normalize the running time to percent
  
  df <- data.frame() 
  for(s in seq(low, high, step)) { 
    fit <- loess(x ~ t, span = s, degree = 2)$fitted 
    sn <- as.numeric(rep(s, n)) 
    df_a <- data.frame(cbind(sn, t, fit)) 
    df <- rbind(df,df_a) 
  } 
  
  p <- ggplot(data = df, aes(x = t, y = fit, group = sn, colour = sn))+ 
    geom_line() + 
    scale_x_continuous(name = "\nRunning time (%)", breaks = seq(0, 100, 10)) +
    labs(title = title, y  = "Fitted values (s)\n") +
    theme_minimal() +
    theme(legend.position = "bottom",
          plot.title = element_text(face = "bold")) + 
    guides(colour = guide_colourbar(barwidth = 20, barheight = 1, title.position = "top")) +  
    scale_colour_viridis_c(name = "Span", breaks = seq(low, high, ticks)) 
  
  return(p) 
} 
