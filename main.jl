using JSON

include("./src/ComSemi.jl")
n::Int64 = 5
edges::Vector{Vector{Vector{Int64}}} = [[[0, 0], [1, 2], [3, 4]], [[0, 1], [2, 3]], [[0, 2], [1, 4]], [[0, 3], [1, 1]], [[0, 4], [2, 2]]]
csemi = ComSemi.new(n, edges)
ComSemi.is_irreducibly_quantified(csemi)

# inter_list = JSON.parsefile("data_sets/size_5.json")

# for inter in inter_list
# n::Int64 = inter["n"]
# edges::Vector{Vector{Vector{Int64}}} = inter["edges"]
# 
# if length(edges) > 0 
# csemi = ComSemi.new(n,edges)
# if ComSemi.is_cancellative(csemi) && ComSemi.is_power_cancellative(csemi) 
# inter["is_irrq"] = true
# else 
# inter["is_irrq"] = false
# end
# else 
# inter["is_irrq"] = true
# end
# end

# output_data = JSON.json(inter_list)
# open("output/output_size5.json","w") do f    
# println(f,output_data)
# end
