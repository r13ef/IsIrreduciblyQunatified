module ComSemi

using JuMP
using HiGHS
using Nemo
using DataStructures
using Combinatorics
using ProgressMeter

struct CSemi
    # size of generator of this commutative semigroup (c.s.)
    n::Int64
    # the complete semi-thue system of this c.s.
    thue::Vector{Matrix{Int64}}
    # For the definition of AG, please see [5].
    ag::Matrix{Int64}
end

# Construct new interaction from the data of edges
function new(n::Int64, edges::Vector{Vector{Vector{Int64}}})::CSemi

    len = length(edges)
    # We first construct the semi Thue system associated to our interaction.
    # We rewrite the i-th vector of origin to the i-th vector of target.

    pre_origin::Vector{Vector{Int64}} = []
    pre_target::Vector{Vector{Int64}} = []

    for i in 1:len
        a::Vector{Int64} = zeros(n)
        for j in edges[i][1]
            a[j+1] += 1
        end

        conn_comp_size = length(edges[i])
        for k in 2:conn_comp_size
            b::Vector{Int64} = zeros(n)
            for j in edges[i][k]
                b[j+1] += 1
            end
            push!(pre_origin, vcat(a))
            push!(pre_target, vcat(b))
            a = b
        end

    end

    # If edges are empty, then it return trivial commutative semigroup.
    if isempty(pre_origin)
        return CSemi(n, [], Array{Int}(undef, 0, 0))
    end

    # Transpose matrices
    origin::Matrix{Int64} = reduce(hcat, pre_origin)
    target::Matrix{Int64} = reduce(hcat, pre_target)


    # In fact, this is a semi-Thue system (not a Thue system).
    thue = [origin, target]
    thue = completion(thue)

    # Construct ag.
    ag = construct_ag(thue)

    csemi = CSemi(n, thue, ag)
    csemi

end

# Reduction a word by our (semi) Thue system. 
function reduce_word(word::Vector{Int64}, thue::Vector{Matrix{Int64}})::Vector{Int64}
    origin = thue[1]
    target = thue[2]

    (a, b) = size(origin)

    # We will continue rewriting until no further rewrites can be made.
    # This is the flag to confirm that the word was rewritten in the previous step.
    flag = true

    while flag
        flag = false
        for i in 1:b
            for j in 1:a
                # Can we rewrite the word by this rewriting rule?
                if word[j] < origin[j, i]
                    # If no, we use the next rewriting rule.
                    @goto NextColum
                end
            end
            word += target[:, i] - origin[:, i]
            # Yes, we rewrite our word!!
            flag = true
            break
            @label NextColum
        end
    end

    word

end

# Reduction our (semi) Thue system.
# To prove that this algorithm halt, please see [6].
function reduce_system(thue::Vector{Matrix{Int64}})::Vector{Matrix{Int64}}

    origin = thue[1]
    target = thue[2]
    (a, b) = size(origin)

    hp = [[origin[:, i], target[:, i]] for i in 1:b]

    used::Set{Vector{Vector{Int64}}} = Set()

    # We will continue reducing until no further reduces can be made.
    # This is the flag to confirm that our Thue system is reduced in the previous step.
    flag = true

    while flag

        flag = false

        # Sort our Thue system. 
        sort!(hp, rev=true)

        while length(hp) > 1

            # (*) Get a rewriting rule.
            word = popfirst!(hp)
            word_from = word[1]
            word_to = word[2]

            len = length(hp)

            # This is the Thue system obtained 
            # by removing the rule we selected (*) from our Thue system. 
            temp_origin = reduce(hcat, [vcat(hp[i][1]) for i in 1:len])
            temp_target = reduce(hcat, [vcat(hp[i][2]) for i in 1:len])
            temp_thue = [temp_origin, temp_target]

            # Reduce the rewriting rule. 
            new_word_from = reduce_word(word_from, temp_thue)
            new_word_to = reduce_word(word_to, temp_thue)

            if word_from == new_word_from && word_to == new_word_to
                # If it was not reduced, we add the rule to the "reduced Thue system". 
                push!(used, word)
                continue
            elseif new_word_from != new_word_to
                # If it was reduced, we add the new reduced rule to our Thue system 
                # and go back to the starting point again!!
                new_replace = [new_word_from, new_word_to]
                sort!(new_replace, rev=true)
                push!(used, new_replace)
                append!(hp, collect(used))
                empty!(used)
                flag = true
                break
            end

        end

    end


    append!(hp, collect(used))
    sort!(hp, rev=true)
    len = length(hp)
    reduced_origin = reduce(hcat, [vcat(hp[i][1]) for i in 1:len])
    reduced_target = reduce(hcat, [vcat(hp[i][2]) for i in 1:len])
    [reduced_origin, reduced_target]

end

# Get the critical pair.
# One can find Definition of critical pairs in [6].
function critical_pair(a::Vector{Vector{Int64}}, b::Vector{Vector{Int64}})::Vector{Vector{Int64}}
    len = length(a[1])
    x = [min(a[1][i], b[1][i]) for i in 1:len]

    y = [a[2][i] + b[1][i] - x[i] for i in 1:len]
    z = [b[2][i] + a[1][i] - x[i] for i in 1:len]

    [y, z]
end

# Add a new rewriting to our Thue system.
function add_to_thue(first_word::Vector{Int64}, second_word::Vector{Int64}, thue::Vector{Matrix{Int64}})::Vector{Matrix{Int64}}
    first_word = reduce(vcat, first_word)
    second_word = reduce(vcat, second_word)

    origin = thue[1]
    target = thue[2]

    if first_word > second_word
        origin = hcat(origin, first_word)
        target = hcat(target, second_word)
    elseif second_word > first_word
        origin = hcat(origin, second_word)
        target = hcat(target, first_word)
    end


    (_, b) = size(origin)
    to_sort = [[origin[:, i], target[:, i]] for i in 1:b]
    sort!(to_sort, rev=true)
    len = length(to_sort)
    sorted_origin = reduce(hcat, [vcat(to_sort[i][1]) for i in 1:len])
    sorted_target = reduce(hcat, [vcat(to_sort[i][2]) for i in 1:len])

    [sorted_origin, sorted_target]

end

# Take Church-Rosser completion.
# For detail of the algorithm, please see [6].
function completion(thue::Vector{Matrix{Int64}})::Vector{Matrix{Int64}}
    flag = true
    while flag
        flag = false
        thue = reduce_system(thue)

        origin = thue[1]
        target = thue[2]
        (a, b) = size(origin)


        seed::Vector{Int64} = [i for i in 1:b]
        for index_list in combinations(seed, 2)
            first_replace_system = [origin[:, index_list[1]], target[:, index_list[1]]]
            second_replace_system = [origin[:, index_list[2]], target[:, index_list[2]]]
            cvector = critical_pair(first_replace_system, second_replace_system)
            first_cvector = reduce_word(cvector[1], thue)
            second_cvector = reduce_word(cvector[2], thue)

            if first_cvector == second_cvector
                continue
            else
                flag = true
                thue = add_to_thue(first_cvector, second_cvector, thue)
                break
            end
        end
    end

    thue
end

# Construct AG.
# For the definition of AG, please see [5].
function construct_ag(thue::Vector{Matrix{Int64}})::Matrix{Int64}
    origin = thue[1]
    target = thue[2]

    (a, b) = size(origin)
    Ag::Matrix{Int64} = reshape([], a, 0)

    for i in 1:b
        new_ag = vcat([origin[j, i] - target[j, i] for j in 1:a])
        (c, d) = size(Ag)
        if d > 0
            A = matrix(ZZ, Ag)
            B = matrix(ZZ, a, 1, new_ag)

            if can_solve(A, B, side=:right)
                continue
            end
        end
        Ag = hcat(Ag, new_ag)
    end

    Ag

end

# This is the main part of our program.
# For detail of the algorithm, please see [5].
function is_cancellative(self::CSemi)
    origin = self.thue[1]
    (_, length_of_thue::Int64) = size(origin)
    (_, length_of_ag::Int64) = size(self.ag)

    iteration_list::Vector{Vector{Int64}} = []
    for i in 1:length_of_thue
        index_list::Vector{Int64} = []
        for (j, x) in enumerate(origin[:, i])
            if x > 0
                push!(index_list, j)
            end
        end
        push!(iteration_list, index_list)
    end

    @showprogress for bits_plus in Iterators.product(iteration_list...)

        for bits_minus in Iterators.product(iteration_list...)
            for index_not_equal in (1, self.n)
                for flag in (true, false)
                    model = Model(HiGHS.Optimizer)
                    set_silent(model)
                    @variable(model, x[1:length_of_ag], Int)
                    @variable(model, y[1:self.n] >= 0, Int)
                    @variable(model, z[1:self.n] >= 0, Int)
                    @constraint(model, c1[j in 1:self.n], sum(self.ag[j, k] * x[k] for k in 1:length_of_ag) + y[j] - z[j] == 0)
                    @constraint(model, c2[j in 1:length_of_thue], y[bits_plus[j]] <= origin[bits_plus[j], j] - 1)
                    @constraint(model, c3[j in 1:length_of_thue], z[bits_minus[j]] <= origin[bits_minus[j], j] - 1)
                    if flag
                        @constraint(model, c4, y[index_not_equal] + 1 <= z[index_not_equal])
                    else
                        @constraint(model, c4, y[index_not_equal] >= z[index_not_equal] + 1)
                    end

                    optimize!(model)
                    if result_count(model) > 0
                        return false
                    end

                end
            end
        end
    end

    true

end

# Is our semigroup is power cancellative?
# We check it by using the theory of invariant factors.
# In particular, we compute the Smith normal form.
function is_power_cancellative(self::CSemi)::Bool
    kernel = self.thue[1] - self.thue[2]
    A = matrix(ZZ, kernel)
    B = snf(A)
    (a, b) = size(A)
    c = min(a, b)
    for i in 1:c
        if B[i, i] > 1
            return false
        end
    end
    true
end

function is_irreducibly_quantified(self::CSemi)::Bool
    if isempty(self.thue)
        true
    else
        is_power_cancellative(self) && is_cancellative(self)
    end
end

export CSemi, new, is_cancellative, is_power_cancellative

end # module ComSemi