"""
    MultiLoessPlot(df; index, low, step, high, title)

Fit multiple loess smoothers to motion picture shot length data and visualise the result.

# Arguments:
- `df`: a data frame containing shot length data in wide format.
- `index::Integer=1`: the index of the data frame column containing the shot length data to be visulaised.
- `low::Float`=0.1: the minimum loess span.
- `step::Float=0.01`: the increment of the span of the loess smoothers.
- `high::Float=0.9`: the maximum loess spans.
- `title::Char`: the title of the plot.

# Example:
```Julia
# Load a .csv file containing shot length data
using CSV
using DataFrames
df = CSV.read("./path/to/file/file.csv", DataFrame; header=1)

# Display the smoothers
using ColorSchemes
using Gadfly
using Loess
p = MultiLoessPlot(df; index=1, low=0.1, step=0.01, high=0.9, title="Movie Title")

# Save as a .png file
using Cairo
using Fontconfig
p |> PNG("./plot.PNG")
```
"""
function MultiLoessPlot(df; index=1, low=0.1, step=0.01, high=0.9, title="")

    # select data and calculate shot times
    dat = dropmissing(select(df, index))
    SL = dat[!, 1]
    times = cumsum(dat[!, 1])
    times = round.(100 * (times / maximum(times)); digits=2)

    # empty data frame to store the result
    dat_out = DataFrame(span=Float64[], times=Float64[], fit=Float64[])

    # iterte over spans of loess smoothers
    spans = [low:step:high;]

    for s in spans

        model = loess(times, SL, span=s)
        fitted = round.(predict(model, times); digits=2)
        dat_res = DataFrame(span=s, times=times, fit=fitted)
        dat_out = vcat(dat_out, dat_res, cols=:union)

    end

    # create the plot
    cpalette(p) = get(ColorSchemes.viridis, p)

    plot(dat_out,
        x=:times, y=:fit, group=:span, color=:span, Geom.line,
        Scale.color_continuous(colormap=cpalette, minvalue=low, maxvalue=high),
        Guide.title(title), Guide.xlabel("Running time (%)"), Guide.ylabel("Fitted values (s)"),
        Guide.colorkey(title="Span"),
        Guide.xticks(ticks=[0:20:100;]),
        Gadfly.Theme(background_color="white", grid_color="#808080", grid_line_style=:solid,
            key_title_font="Arial", major_label_font="Arial", key_position=:right))

end
