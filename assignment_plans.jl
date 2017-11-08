#!/usr/bin/env julia
# __precompile__()

module Assignments

import Base: start, next, done, eltype, length, size
import Base: iteratorsize, SizeUnknown, IsInfinite, HasLength
import Combinatorics: factorial, combinations

# Copied from Combinatorics
# Only one small change in the `nextpermutation` method

export permutation
export assignmentplans

immutable Permutations{T}
    a::T
    t::Int
end

eltype{T}(::Type{Permutations{T}}) = Vector{eltype(T)}

length(p::Permutations) = (0 <= p.t <= length(p.a))?factorial(length(p.a), length(p.a)-p.t):0

"""
Generate all permutation of an indexable object. Because the number of permutation can be very large, this function returns an iterator object. Use `collec
t(permutation(array))` to get an array of all permutation.
"""
permutation(a) = Permutations(a, length(a))

"""
Generate all size t permutation of an indexable object.
"""
function permutation(a, t::Integer)
    if t < 0
        t = length(a) + 1
    end
    Permutations(a, t)
end

start(p::Permutations) = [1:length(p.a);]
next(p::Permutations, s) = nextpermutation(p.a, p.t ,s)

function nextpermutation(m, t, state)
    s = copy(state)                     # was s = copy(s) a few lines down
    perm = [m[s[i]] for i in 1:t]
    n = length(s)
    if t <= 0
        return(perm, [n+1])
    end
    if t < n
        j = t + 1
        while j <= n &&  s[t] >= s[j]; j+=1; end
    end
    if t < n && j <= n
        s[t], s[j] = s[j], s[t]
    else
        if t < n
            reverse!(s, t+1)
        end
        i = t - 1
        while i>=1 && s[i] >= s[i+1]; i -= 1; end
        if i > 0
            j = n
            while j>i && s[i] >= s[j]; j -= 1; end
            s[i], s[j] = s[j], s[i]
            reverse!(s, i+1)
        else
            s[1] = n+1
        end
    end
    return(perm, s)
end

done(p::Permutations, s) = !isempty(s) && max(s[1], p.t) > length(p.a) ||  (isempty(s) && p.t > 0)

# Copied from Iterators
# Returns an `Array` of `Array`s instead of `Tuple`s now

immutable Partition{I}
    xs::I
    step::Int
    n::Int
end

iteratorsize{T<:Partition}(::Type{T}) = SizeUnknown()

eltype{I}(::Type{Partition{I}}) = Vector{eltype(I)}

function partition{I}(xs::I, n::Int, step::Int = n)
    Partition(xs, step, n)
end

function start{I}(it::Partition{I})
    N = it.n
    p = Vector{eltype(I)}(N)
    s = start(it.xs)
    for i in 1:(N - 1)
        if done(it.xs, s)
            break
        end
        (p[i], s) = next(it.xs, s)
    end
    (s, p)
end

function next{I}(it::Partition{I}, state)
    N = it.n
    (s, p0) = state
    (x, s) = next(it.xs, s)
    ans = p0; ans[end] = x

    p = similar(p0)
    overlap = max(0, N - it.step)
    for i in 1:overlap
        p[i] = ans[it.step + i]
    end

    # when step > n, skip over some elements
    for i in 1:max(0, it.step - N)
        if done(it.xs, s)
            break
        end
        (x, s) = next(it.xs, s)
    end

    for i in (overlap + 1):(N - 1)
        if done(it.xs, s)
            break
        end

        (x, s) = next(it.xs, s)
        p[i] = x
    end

    (ans, (s, p))
end

done(it::Partition, state) = done(it.xs, state[1])

# Copied from the answer of Dan Getz
# Added types to comprehensions and used Vector{Int} instead of Int in vcat

typealias PlanGrid Matrix{SubArray{Int,1,Array{Int,1},Tuple{UnitRange{Int}},true}}



histograms(n,m) = [diff(vcat([0],x,[n+m])).-1 for x in combinations([1:n+m-1;],m-1)]

good_histograms(n,m,minval,maxval) =
  Vector{Int}[h for h in histograms(n,m) if all(maxval.>=h.>=minval)]


function assignmentplans(balls,boxes,minballs,maxballs)
  nballs, nboxes = length(balls),length(boxes)
  nperms = factorial(nballs)

  partslist = good_histograms(nballs,nboxes,minballs,maxballs)
  plans = PlanGrid(nboxes,nperms*length(partslist))

  permutationvector = vec([balls[p[i]] for i=1:nballs,p in permutation(balls)])

  i1 = 1

  for parts in partslist
    i2 = 0
    breaks = UnitRange{Int64}[(x[1]+1:x[2]) for x in partition(cumsum(vcat([0],parts)),2,1)]
    for i=1:nperms
      for j=1:nboxes
        plans[j,i1] = view(permutationvector,breaks[j]+i2)
      end
      i1 += 1
      i2 += nballs
    end
  end
  return plans
end

end


# using Assignments
#
# @time plans = assignmentplans(1:8, 1:5, 0, 4)
# print(size(plans))
