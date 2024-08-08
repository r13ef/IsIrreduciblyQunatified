using JSON

include("./src/ComSemi.jl")
inter_list = JSON.parsefile("size_4.json")

for inter in inter_list
    n::Int64 = inter["n"]
    pre_thue::Vector{Vector{Vector{Int64}}} = inter["edges"]
    
    if length(pre_thue) > 0 
        csemi = ComSemi.new(n,pre_thue)
         if ComSemi.is_cancellative(csemi) && ComSemi.is_power_cancellative(csemi) 
            inter["is_irrq"] = true
         else 
            inter["is_irrq"] = false
         end
    else 
        inter["is_irrq"] = true
    end
    
end

# output_data = JSON.json(inter_list)
# open("output_size_4.json","w") do f  
    # println(f,output_data)
# end
