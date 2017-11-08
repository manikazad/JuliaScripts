function stirling(n::Int, k::Int)
    if n == k || k == 1
        return 1
    else
        if  n<k
            return 0
        else
            return k*stirling(n-1,k) + stirling(n-1,k-1)
        end
    end
end

function B(n::Int)
    sum = 0
    for i in [1:n;]
        sum += stirling(n,i)
    end
    return sum
end

function D(n,r,d)
    if n == r && 1 <= d <= n-1
        return d+1
    elseif r == n+1 && 1 <= d <= n
        return 1
    elseif 3 <= r <= n && 1 <= d <= r-1
        return d * D(n, r+1, d) + D(n, r+1, d+1)
    end
end


function unranksub(t,n)
    a = zeros(n)
    b = zeros(n)

    for i in [1:n;]
        b[i] = 0
    end

    r = 0
    k = 1

    while true
        if t <= 2^n - 1
            b[k] = 1
            r = r+1
            a[r] = k
            t = t- (1 - b[k]) * 2 ^ (n-k) - b[k]
            k = k + 1
            if k > n || t == 0
                break
            end
        end
    end
    return a,b,r
end

function ranka(a,n,r)
    rank = r
    a[0] = 0
    for i in [0:r;]
        for j in [a[i]+1:a[i+1];]
            rank = rank + 2 ^ (n-j)
        end
    end
    return rank
end

function rankb(b,n)
    k = n
    while b[k] == 0
        k = k-1
        rank = 0
        for i in [1:k;]
            rank = rank + (1-b[i])* 2^(n-i) + b[i]
        end
    end
    return rank
end

function subsetpar(n,k)
    for i in [1:k;]
        g = (2^n - 1) / k
        t = (i-1)*g + 1
        a, b, r = unranksub(t, n)
        l = 0
        while true
            println(a)
            l = l+1
            if a[r] < n
                a[r+1] = a[r] + 1
                r = r + 1
            else
                r = r - 1
                a[r] = a[r] + 1
            end
            if l == g || a[1] == n
                break
            end
        end
    end
end

function Cn_m(n,m)
    return factorial(n) / (factorial(m) * factorial(n-m))
end

function Ln_m(n,m)
    L = 0
    for i in [1:m;]
        L += Cn_m(n,i)
    end
    return L
end

function unranklim(t,n,m)
    r = 0
    i = 1
    a = zeros(n)

    while true
        s = t-1 - Ln_m(n,m)
        if s > 0
            t = s
        else
            r = r+1
            a[r] = i
            t = t - 1
        end
        i = i + 1
        if t == 0 || i == n+1
            break
        end
    end
    return a,r
end

function subsetlim(m,n,k)
    for i in [1:k;]
        g = ceil( Ln_m(n,m) / k )
        t = (i-1)*g + 1
        a,r = unranklim(t,n,m)
        l = 0
        while true
            l = l+1
            println(a[1:r])
            if a[r] < n
                if r < m
                    a[r+1] = a[r] + 1
                    r = r+1
                else
                    r = r-1
                    a[r] = a[r] + 1
                end
            else
                a[r] = a[r] + 1
            end
            if l == g || a[1] == n
                break
            end
        end
    end
end

function unrankpart(t,n)
    c = zeros(n)

    if  !(0 < t < B(n))
        r = 0
        sys.exit()
    end

    c[1] = 1
    d = 1
    for r in [2:n;]
        m = 0
        while true
            m = m+1
            f = m * D(n, r+1, d)
            if t <= f
                break
            end
        end
        if m > d + 1
            m = d + 1
        end
        c[r] = m
        t = t-(m-1)*D(n, r+1, d)
        if m>d
            d = m
        end
    end
    return c,r
end

function rankp(n,c)
    t = 1
    d = 1
    for r in [2:n;]
        t = t + (c[r] - 1)*D_n(r+1, d)
        if c[r] > d
            d = c[r]
        end
    end
    return t
end

function setpartpar(n::Int,k::Int)
    b = zeros(n)
    for i in [1:k;]
        g = ceil(B(n)/k)
        t = (i-1)*g + 1
        c,r = unrankpart(t,n)
        l = 0
        r = n
        j = 0
        _max = 1

        for s in [2:n-1;]
            if c[s] > _max
                _max = c[s]
            else
                j = j + 1
                b[j] = s
            end
        end
        while true
            while r < n-1
                r = r+1
                c[r] = 1
                j = j+1
                b[j] = r
            end
            while true
                l = l+1
                println(c)
                c[n] = c[n] + 1
                if c[n] > n-j || l == g
                    break
                end
            end
            if j < 1
                break
            end
            r = Int(b[j])
            c[r] = c[r] + 1
            c[n] = 1
            if c[r] > r-j
                j = j-1
            end
            if l == g || r == 1
                break
            end
        end
        println("\n")
    end
end
