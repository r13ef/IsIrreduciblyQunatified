
using JSON

function tikz_picture(n::Int64, num::Int64, edges::Vector{Vector{Vector{Int64}}}, consv::Vector{Vector{Int64}})
    maximal_size = n - 1
    scale = 0.5
    get_cordinate(x, y) = (-x + y, x + y + maximal_size)
    tikz_cordinate(x,y) = ((-x + y) * scale, (x + y + maximal_size) * scale)
    tikz_code = "\\begin{tikzpicture}\n"

    for x in 0:maximal_size
        (tikz_x, tikz_y) = tikz_cordinate(x,0)
        tikz_code *= "\\coordinate (x$num-$x) at ($tikz_x, $tikz_y) node at (x$num-$x) [below left] {\$$x\$};\n"
    end
    for y in 0:maximal_size
        (tikz_x, tikz_y) = tikz_cordinate(0,y)
        tikz_code *= "\\coordinate (y$num-$y) at ($tikz_x, $tikz_y) node at (y$num-$y) [below right] {\$$y\$};\n"
    end

    consv_tex = ""
    for vec in consv 
        for i in 1:n
            if vec[i] != 0 
                consv_tex *= "\\xi_$(i-1)+"
            end
        end
        consv_tex = "$(consv_tex[1:end-1]),"
    end
    tikz_code *= "\\coordinate (c$num) at (0,$(scale * 2)) node at (c$num) {\$$consv_tex\$};\n"

    for x in 0:maximal_size
        for y in 0:maximal_size
            (tikz_x, tikz_y) = tikz_cordinate(x,y)
            tikz_code *= "\\fill[gray] ($tikz_x, $tikz_y) circle (2pt);\n"
        end
    end

    for edge in edges
        origin = edge[1]
        minimal_vertex = edge[1]
        flag = false
        if origin[1] == origin[2] 
            flag = true
        end
        for target in edge[2:end]
            if target[1] == target[2] 
                flag = true
            end
            (ox,oy) = get_cordinate(origin[1], origin[2])
            (tx, ty) = get_cordinate(target[1], target[2])
            dx = tx - ox
            dy = ty - oy
            bend = gcd(dx, dy) == 1 ? 0 : 12
            (origin_x, origin_y) = tikz_cordinate(origin[1], origin[2])
            (target_x, target_y) = tikz_cordinate(target[1], target[2])
            tikz_code *= "\\draw[<->][line width=1][{Latex[width = 2mm]}-{Latex[width = 2mm]}] ($origin_x, $origin_y) to [bend right = $bend] ($target_x, $target_y);\n"
            tikz_code *= "\\draw[<->][line width=1][{Latex[width = 2mm]}-{Latex[width = 2mm]}] ($(-origin_x), $origin_y) to [bend left = $bend] ($(-target_x), $target_y);\n"
            origin = target
        end

        if !flag
            (origin_x, origin_y) = tikz_cordinate(minimal_vertex[1], minimal_vertex[2])
            tikz_code *= "\\draw[<->][line width=1][{Latex[width = 2mm]}-{Latex[width = 2mm]}] ($origin_x, $origin_y) to [bend right = 12] ($(-origin_x), $origin_y);\n"
        end
    end  
    println(num)
    println(length(tikz_code))

    tikz_code *= "\\end{tikzpicture}\n"
    return tikz_code;
end



inter_list = JSON.parsefile("output/output_size5.json")
my_tikz_code = ""

for (i,inter) in enumerate(inter_list)
    if inter["is_irrq"] 
        my_edges::Vector{Vector{Vector{Int64}}} = inter["edges"]
        my_consv::Vector{Vector{Int64}} = inter["consv"]
        global my_tikz_code *= tikz_picture(inter["n"],i,my_edges,my_consv)
    end
end


tex_code = """
\\documentclass{article}
\\usepackage{tikz}
\\usepackage{amsmath}
\\usetikzlibrary{arrows.meta}
\\usetikzlibrary{arrows}
\\begin{document}
$my_tikz_code
\\end{document}
"""

write("./tikz/tikz_pictures.tex", tex_code)