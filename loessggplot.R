loessggplot <- function(x, low = 0.1, high = 0.9, step = 0.01, title = "", ticks = 0.1){ 
  
  library(ggplot2) 
  
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
    geom_vline(xintercept = seq(25, 75, 25), colour="black", linetype = "longdash") + # add lines to mark quartiles of running time
    theme_classic() +  # edit to change theme used by ggplot2
    xlab("\nRunning time (%)") +  
    ylab("Fitted values (s)\n") + 
    ggtitle(title) + 
    theme(plot.title = element_text(face = "bold")) + 
    guides(colour = guide_colourbar(barwidth = 20, barheight = 1, title.position = "top")) +  
    theme(legend.position = "bottom") + 
    scale_colour_viridis_c(name = "Span", breaks = seq(low, high, ticks)) 
  
 return(p) 
} 