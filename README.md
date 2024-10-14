# Is your interaction irreducibly quantified?

# Introduction
The hydrodynamic limit is a mathematical method that derives macroscopic deterministic partial differential equations as limits from microscopic large scale interacting systems. 
Varadahn's decomposition theorem plays an important role to prove the hydlodynamic limit for non-gradient model. 
In the studies Bannai-Kametani-Sasada [^BKS] and Bannai-Sasada [^BS], they prove Varadahn's decomposition theorem for a general class of large scale interacting system. 
In their setting, microscopic large scale interacting systems is constructed by interactions. 
For the definitions, please see thier papers. 
In their studies, they consider the condition of interactions, which is called *irreducibly quntified*, as the suitable assumption for the hydrodynamic limit.

If you have seen the definition of irreducibly quntifiedness, you might think that confirming this condition requires an infinite number of steps at first glance.
However,　I prove that this can be determined in a finite number of steps in my paper [^W24].

This program is check wheather your interaction is irreducibly quantified by using my algorithm.
To understand detail of the algorithm, please also see two papers[^NO] [^BL].

# How to use

If you want to check whether your interaction is irreducibly quantified, you need to write down your interaction in the following forms.
```
# size of the state space
n::Int64 = 5

# You group together the vertices that exist within the same connected component and describe them in a single vector.
# This example shows that vertices (0,0), (1,2) and (3,4) are in the same connected components.
edges::Vector{Vector{Vector{Int64}}} = [[[0,0],[1,2],[3,4]],[[0,1],[2,3]],[[0,2],[1,4]],[[0,3],[1,1]],[[0,4],[2,2]]]
```

In this program, we always assume that the interaction is exchangeable. 
Therefore, you don't need to add vertices that are symmetric to the others. 
In our example, that means you don't need to add the vertex [2,1] in the list [[0,0],[1,2],[3,4]]. 
It will be automatically added.

> [!CAUTION]
> You need to set the edges, but they must not be empty. If they are empty, it will cause an error in the next step.
> We note that if the edges are empty, one can prove that the interaction is irreducibly quantified.

After that, 
```
csemi = ComSemi.new(n,edges)

# If this interaction is irreducibly quantified, it will return true.
ComSemi.is_irreducibly_quantified(csemi) 
```

> [!WARNING]
> Since this computation takes a lot of time, please be careful when using this program.

One can find the list of exhcangeable separable interactions with a state space size of 4 or 5 in /data_sets.
Moreover, you can find the results of computations in /output.

# Reference 
[^BKS]: [Bannai, Kenichi, Kametani, Yukio and Sasada, Makiko. Topological Structures of Large Scale Interacting Systems via Uniform Functions and Forms. 2024.](https://arxiv.org/abs/2009.04699)
[^BS]: [Bannai, Kenichi, Sasada, Makiko. Varadhan's Decomposition of Shift-Invariant Closed $L^2$-forms for Large Scale Interacting Systems on the Euclidean Lattice. 2024](https://arxiv.org/abs/2111.08934)
[^W24]: [Wachi, Hidetada. Decision problem on interactions. to be apeared soon]
[^NO]: [Narendran, Paliath and Ó'Dúnlaing, Colm. Cancellativity in finitely presented semigroups. 1987.](https://www.sciencedirect.com/science/article/pii/S0747717189800288)
[^BL]: [Ballantyne, A. M. and Lankford, D. S. New decision algorithm for finitely presented commutative semigroups. 1980](https://core.ac.uk/download/pdf/82308735.pdf)