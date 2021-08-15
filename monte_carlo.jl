using Distributed

params = (exename=`/home/julia/julia-1.6.2/bin/julia`,
          dir="/home/julia/projects/test")

N_WORKERS = 4

# :auto for num of cpus.
addprocs([("julia@192.168.4.49", N_WORKERS)]; params...)

@everywhere using Distributions

# Single threaded.

@everywhere function compute_pi(N::Int64)
  xs = rand(Uniform(-1, 1), N)
  ys = rand(Uniform(-1, 1), N)
  inside = 0
  for i in 1:N
    x = xs[i]
    y = ys[i]
    if x * x + y * y <= 1.0
      inside += 1
    end
  end
  return inside
end

N = 100000000
@time inside = compute_pi(N)
println("pi is: ", inside * 4.0 / N)

# Parallelized.

function compute_pi_parallel(N::Int64, nworkers::Int)
  ids = workers()
  futures = Array{Any}(undef, nworkers)
  for i in 1:nworkers
    futures[i] = @spawnat ids[i] compute_pi(convert(Int64, N / nworkers))
  end
  inside = 0
  for i in 1:nworkers
    inside += fetch(futures[i])
  end
  return inside
end

@time inside = compute_pi_parallel(N, N_WORKERS)
println("by parallel estimation, pi is: ", inside * 4.0 / N)

# distributed keyword

@time inside = @distributed (+) for i in 1:N_WORKERS
  compute_pi(convert(Int, N / N_WORKERS))
end
println("by distributed, pi is: ", inside * 4.0 / N)

rmprocs(workers())
