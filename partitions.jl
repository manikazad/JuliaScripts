module Partitions

export get_partitions
export bell_number
export stirling
export get_all_partitions


function stirling(n::Int, k::Int)
    if (n == k || k == 1)
        return 1
    else
        if (n < k)
            return 0
        else
            return k * stirling(n - 1, k) + stirling(n - 1, k - 1)
        end
    end
end

function bell_number(n::Int)
    sum = 0
    @inbounds for i in [1:n;]
        sum += stirling(n,i)
    end
    return sum
end

function increment1(s::Array{Int,1}, count::Array{Int,1}, index::Int)
    count[s[index]] -= 1
    s[index] += 1
    count[s[index]] += 1
end

function set_value1(s::Array{Int,1}, count::Array{Int,1}, index::Int)
    count[s[index]] -= 1
    s[index] = 1
    count[s[index]] += 1
end

function next_partition(s::Array{Int,1}, m::Array{Int,1}, count_set::Array{Int,1}, n::Int, max_part_size::Int)

    while true
        i = 1
        increment1(s, count_set, i)
        while i < n && s[i] > m[i] + 1
            set_value1(s, count_set, i)
            i += 1
            increment1(s, count_set, i)
        end

        if i == n
            return false
        end

        max = s[i]
        @inbounds for j in [i-1:-1:1]
            m[j] = max
        end

        if length(filter(x -> x > max_part_size, count_set)::Array{Int,1})::Int == 0
            break
        end
    end

    return true
end

function get_partitions(orders::Array{Int,1}, max_part_size::Int)
    set_n = length(orders)

    sets = Array{Int,1}(repeat([1], inner=set_n))
    max_set = Array{Int,1}(repeat([1], inner=set_n))
    count_set = Array{Int,1}(repeat([0], inner=set_n+2))

    count_set[1] = set_n

    if length(filter(x -> x > max_part_size, count_set)) == 0
        produce([orders])
    end
    while (next_partition(sets, max_set, count_set, set_n, max_part_size))
        produce(map_orders_partitions(orders, sets, set_n))
    end
end

function map_orders_partitions(orders::Array{Int,1}, parts::Array{Int,1}, len)
    nparts = maximum(parts)
    partition = Array{Int,1}[Int[] for i in zip(1:nparts)]
    @inbounds for i in 1:len
        push!(partition[parts[i]], orders[i])
    end
    return partition
end

function counpart(set_n, max_n)
    orders = [1:set_n;]
    j = 0
    @inbounds for part::Array{Array{Int,1},1} in Task(() -> get_partitions(orders, max_n))
        j+= 1
    end
    println(j)
end

function get_all_partitions(orders::Array{Int,1}, max_part_size::Int)
  all_partitions = Array{Array{Array{Int, 1}, 1},1}()
  for part in Task(()->get_partitions(orders, max_part_size))
    push!(all_partitions, part)
  end
  return all_partitions
end

end
