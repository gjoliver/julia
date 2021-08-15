using Distributed

params = (exename=`/home/julia/julia-1.6.2/bin/julia`,
          dir="/home/julia/projects/test")

# :auto for num of cpus.
addprocs([("julia@192.168.4.49", :auto)]; params...)

@everywhere println(gethostname())

rmprocs(workers())
