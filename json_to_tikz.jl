
function tikz_picture(n::Int64, edges::Vector{Vector{Vector{Int64}}}, consv::Vector{Vector{Int64}})

    maximal_size = n - 1
    scale = 0.5
    get_coordinate(x, y) = (-x + y, x + y + maximal_size)
    (base_x, base_y) = () 

    tikz_code = "\\begin{tikzpicture}\n"
    
    for x in 0:maximal_size
        (tikz_x, tikz_y) = get_coordinate(x,0)
        tikz_code *= "\\coordinate (x$x) at ($(tikz_x * scale), $(tikz_y * scale)) node at (x$x) [below left] {\$$x\$};\n"
    end
    for y in 0:maximal_size
        (tikz_x, tikz_y) = get_coordinate(0,y)
        tikz_code *= "\\coordinate (y$y) at ($(tikz_x * scale), $(tikz_y * scale)) node at (y$y) [below right] {\$$y\$};\n"
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
    tikz_code *= "\\coordinate (c) at (0,1) node at (c) {\$$consv_tex\$};\n"

    for x in 0:maximal_size
        for y in 0:maximal_size
            (tikz_x, tikz_y) = get_coordinate(x,y)
            tikz_code *= "\\fill[gray] ($(tikz_x * scale), $(tikz_y * scale)) circle (2pt);\n"
        end
    end

    flag = false
    for edge in edges
        origin = edge[1]
        minimal_vertex = edge[1]

        for target in edge
            if origin[1] == origin[2] 
                flag = true
            end
            (origin_x, origin_y) = get_coordinate(origin[1], origin[2])
            (target_x, target_y) = get_coordinate(target[1], target[2])
            dx = target_x - origin_x
            dy = target_y - origin_y
            bend = gcd(dx, dy) == 1 ? 0 : 12
            tikz_code *= "\\draw[<->][line width=1][{Latex[width = 2mm]}-{Latex[width = 2mm]}] ($(origin_x * scale),$(origin_y * scale)) to [bend right = $bend] ($(target_x * scale),$(target_y * scale));\n"
            tikz_code *= "\\draw[<->][line width=1][{Latex[width = 2mm]}-{Latex[width = 2mm]}] ($(-origin_x * scale),$(origin_y * scale)) to [bend left = $bend] ($(-target_x * scale),$(target_y * scale));\n"
            origin = target
        end

        if !flag
            (origin_x, origin_y) = get_coordinate(minimal_vertex[1], minimal_vertex[2])
            tikz_code *= "\\draw[<->][line width=1][{Latex[width = 2mm]}-{Latex[width = 2mm]}] ($(origin_x * scale),$(origin_y * scale)) to [bend right = $bend] ($(-origin_x * scale),$(origin_y * scale));\n"
        end
    end  

    tikz_code *= "\\end{tikzpicture}\n"

    return tikz_code;
end



edges = [[[0,0],[1,2],[3,4]],[[0,1],[2,3]],[[0,2],[1,4]],[[0,3],[1,1]],[[0,4],[2,2]]]
consv = [[0,1,-1,0,0],[0,0,0,1,-1]]
tikz_code = tikz_picture(5,edges,consv)



tex_code = """
\\documentclass{article}
\\usepackage{tikz}
\\usepackage{amsmath}
\\usetikzlibrary{arrows.meta}
\\usetikzlibrary{arrows}
\\begin{document}
$tikz_code
\\end{document}
"""

write("./tikz/tikz_pictures.tex", tex_code)