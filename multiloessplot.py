def multiloessplot(x, index=0, low=0.1, high=0.9, step=0.01, tick_step=0.1, title=""):
    """

    multiloessplot

    Plot multiple loess smoothers for motion picture shot length data.

    Parameters
    ----------
    x : a data frame in wide format containing shot length data for a motion picture.

    index : the index of the data column in the data frame to be plotted.
            Note that the index is in python format and begins at 0.

    low : the minimum value of the loess smoothers.

    high : the maximum value of the loess smoothers.

    step : the increment in the span of the loess smoothers.

    tick_step : specifies the distance between tick marks on the colour bar in the legend. 
                The lower and upper limits of the colour bar are set by low and high, respectively.

    title : a title for the plot.

    Returns
    -------
    a plot of the multiple loess smoothers, with the cumulative running time as a percentage plotted 
    against the fitted values of the local regression

    Examples
    --------
    # Load a .csv file containing shot length data
    import pandas as pd
    df = pd.read_csv('path/to/file/data.csv', delimiter=',')

    multiloessplot(df, index=0, low=0.1, high=0.9, step=0.01, tick_step = 0.1, title = "Movie title")
    """

    import numpy as np
    import pandas as pd
    import seaborn as sns
    from statsmodels.nonparametric.smoothers_lowess import lowess
    from matplotlib import cm, colorbar, colors

    SL = x.iloc[:, index].dropna(axis=0, how='any')
    times = np.cumsum(SL)
    times = 100 * (times/np.max(times))

    spans = np.round(np.arange(low, high+step, step).tolist(), 2)

    # Collect the results of fitting multiple smoothers
    column_names = ["span", "times", "fit"]
    dat_out = pd.DataFrame(columns=column_names)

    for s in spans:
        fit = pd.Series(lowess(SL, times, is_sorted=True, frac=s, it=0)[:, 1])
        span = pd.Series(np.repeat(s, len(times)))
        dat_res = pd.DataFrame({"span": span, "times": times, "fit": fit})
        dfs = [dat_out, dat_res]
        dat_out = pd.concat(dfs, ignore_index=True)

    # Create the plot
    sns.set_theme(style="whitegrid", font_scale=1.2)
    p = sns.relplot(data=dat_out, x="times", y="fit", hue="span", kind="line",
                    palette="viridis",
                    legend=False, height=6, aspect=1.3)
    p.set(title=title, xlabel="Running time (%)", ylabel="Fitted values (s)")
    p.figure.colorbar(
        cm.ScalarMappable(
            norm=colors.Normalize(vmin=dat_out['span'].min(),
                                  vmax=dat_out['span'].max(),
                                  clip=False), cmap='viridis'),
        ticks=np.arange(low, high+step, tick_step),
        label=r'Span', orientation='horizontal', shrink=0.8, aspect=20, pad=0.15)
