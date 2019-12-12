function datacheck(path)
    if !isfile(path)
        processdata = joinpath(splitdir(@__FILE__())[1],"processdata.sh")
        if isfile(processdata)
            run(`$processdata`)
        end
        if !isfile(path)
            error("The data $(path) is not available. Contact the authors of this package if you would like to use this data.")
        end
    end
end

function get_values(file, dx=nothing)
    datacheck(file)
    x_values = open(file) do f
        floats = parse.(Float64,readlines(file))
    end
    if dx==nothing
        dx = sort(abs.(diff(x_values)))
        dx = dx[findfirst(dx .> 0)]
        # dx = 15011/15
    end
    x_values_norm = x_values/dx
    x_min = minimum(x_values_norm)
    x_values_shift = x_values_norm .- x_min
    x_values_int = round.(Int,x_values_shift)
    @assert sum(abs.(x_values_int-x_values_shift)) < 1e-5
    x_values_int.+1, dx
end

dataloc = Dict(:BE=>["BEx_values.txt","BEy_values.txt","BEheights.txt"],
    :NL => ["NLx_values.txt","NLy_values.txt","NLheights.txt"],
    :BENELUX => ["x_values.txt","y_values.txt","heights.txt"])
function get_datamatrix(country=:BENELUX)
    datacheck(joinpath(splitdir(@__FILE__())[1],dataloc[country][3]))
    heights = open(joinpath(splitdir(@__FILE__())[1],dataloc[country][3])) do f
        lines = readlines(f)
        floats = zeros(length(lines))
        for (line_index,line) in enumerate(lines)
            t = NaN
            if line=="nan"
                nothing
            else
                t = parse(Float64,line)
                # there is are some errors in the data
                t < -20 && (t = NaN)
            end
            floats[line_index] = t
        end
        floats
    end

    x_values, dx = get_values(joinpath(splitdir(@__FILE__())[1],dataloc[country][1]))
    y_values, dy = get_values(joinpath(splitdir(@__FILE__())[1],dataloc[country][2]))

    x_min = minimum(x_values)
    x_max = maximum(x_values)
    y_min = minimum(y_values)
    y_max = maximum(y_values)

    A = NaN*zeros(y_max, x_max)
    for index in 1:length(x_values)
        A[y_values[index], x_values[index]] = heights[index]
    end
    A
end
