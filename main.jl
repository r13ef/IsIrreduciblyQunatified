using JSON

include("./src/ComSemi.jl")
inter_list = JSON.parsefile("data_sets/size_5.json")

for inter in inter_list
    n::Int64 = inter["n"]
    edges::Vector{Vector{Vector{Int64}}} = inter["edges"]
    
    if length(edges) > 0 
        csemi = ComSemi.new(n,edges)
        if ComSemi.is_cancellative(csemi) && ComSemi.is_power_cancellative(csemi) 
            inter["is_irrq"] = true
            println("yes")
        else 
            inter["is_irrq"] = false
            println("no")
        end
    else 
        inter["is_irrq"] = true
        println("yes")
    end
end

output_data = JSON.json(inter_list)
open("output/output_size_5.json","w") do f    
    println(f,output_data)
end
