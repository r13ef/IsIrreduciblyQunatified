
using JSON

function tikz_picture(n::Int64, num::Int64, edges::Vector{Vector{Vector{Int64}}}, consv::Vector{Vector{Int64}})
    maximal_size = n - 1
    scale = 0.3
    get_cordinate(x, y) = (-x + y, x + y + maximal_size)
    tikz_cordinate(x,y) = ((-x + y) * scale, (x + y + maximal_size) * scale)
    tikz_code = "\\hspace*{-1cm}\\begin{minipage}[b]{0.3\\linewidth}\n\\begin{tikzpicture}\n"
    pairs = Set([i,j] for i = 0:3 for j = i+1:4)

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
            c = vec[i]
            if c != 0 
                if c < 0 && length(consv_tex) > 0 
                    consv_tex = consv_tex[1:end-1]
                end
                if c != 1 && c != -1
                    consv_tex *= "$c\\xi_$(i-1)+"
                elseif c == -1
                    consv_tex *= "-\\xi_$(i-1)+"
                else
                    consv_tex *= "\\xi_$(i-1)+"
                end
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
        else
            delete!(pairs,origin)
        end

        for target in edge[2:end]
            if target[1] == target[2] 
                flag = true
            else
                delete!(pairs,target)
            end

            (ox,oy) = get_cordinate(origin[1], origin[2])
            (tx, ty) = get_cordinate(target[1], target[2])
            dx = tx - ox
            dy = ty - oy
            bend = gcd(dx, dy) == 1 ? 0 : 12
            (origin_x, origin_y) = tikz_cordinate(origin[1], origin[2])
            (target_x, target_y) = tikz_cordinate(target[1], target[2])
            tikz_code *= "\\draw[arrows = {Stealth[length=1.5mm] - Stealth[length=1.5mm]}] ($origin_x, $origin_y) to [bend right = $bend] ($target_x, $target_y);\n"
            tikz_code *= "\\draw[arrows = {Stealth[length=1.5mm] - Stealth[length=1.5mm]}] ($(-origin_x), $origin_y) to [bend left = $bend] ($(-target_x), $target_y);\n"
            origin = target
        end

        if !flag
            (origin_x, origin_y) = tikz_cordinate(minimal_vertex[1], minimal_vertex[2])
            tikz_code *= "\\draw[arrows = {Stealth[length=1.5mm] - Stealth[length=1.5mm]}] ($origin_x, $origin_y) to [bend right = 12] ($(-origin_x), $origin_y);\n"
        end

    end

    for edge in pairs 
        (origin_x, origin_y) = tikz_cordinate(edge[1], edge[2])
        tikz_code *= "\\draw[arrows = {Stealth[length=1.5mm] - Stealth[length=1.5mm]}] ($origin_x, $origin_y) to [bend right = 12] ($(-origin_x), $origin_y);\n"
    end
    tikz_code *= "\\end{tikzpicture}\n\\end{minipage}"
    return tikz_code;
end



inter_list = JSON.parsefile("output/output_size5.json")
my_tikz_code_true = ""
my_tikz_code_false = ""
count_true = 1
count_false = 1

for (i,inter) in enumerate(inter_list)
    my_edges::Vector{Vector{Vector{Int64}}} = inter["edges"]
    my_consv::Vector{Vector{Int64}} = inter["consv"]
    if inter["is_irrq"] 
        global my_tikz_code_true *= tikz_picture(inter["n"],i,my_edges,my_consv)
        if count_true % 4 == 0 
            global my_tikz_code_true *= "\\\\"
        else
            global my_tikz_code_true *= "&"
        end
        global count_true += 1;
    else
        global my_tikz_code_false *= tikz_picture(inter["n"],i,my_edges,my_consv)
        if count_false % 3 == 0 
            global my_tikz_code_false *= "\\\\"
        else
            global my_tikz_code_false *= "&"
        end
        global count_false += 1; 
    end
end



tex_code = """
\\documentclass{article}
\\usepackage{tikz}
\\usepackage{amsmath}
\\usetikzlibrary{arrows.meta}
\\usetikzlibrary{arrows}
\\usetikzlibrary {bending}
\\begin{document}
\\begin{figure}
\\hspace{-1.5cm} 
\\begin{tabular}{cccc}
$my_tikz_code_true
\\end{tabular}
\\caption{Irreducibly quantified interactions with \$|S|=5\$.}
\\end{figure}
\\begin{figure}
\\hspace{0cm} 
\\begin{tabular}{ccc}
$my_tikz_code_false
\\end{tabular}
\\caption{Exchangeable, separable, but not irreducibly quantified interactions with \$|S|=5\$.}
\\end{figure}
\\end{document}
"""

write("./tikz/tikz_pictures.tex", tex_code)