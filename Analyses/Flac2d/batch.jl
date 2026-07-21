using DelimitedFiles
#pgs = [10, 20, 31, 35, 44, 49, 62, 76, 99, 106]
pgs = [7, 8, 12, 13, 17, 19, 20, 24, 27, 34, 35, 39, 44, 54, 57, 76, 87, 99, 109, 131]
all_pgs = [6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 27, 31, 33, 34, 35, 36, 39, 42, 43, 44, 48, 49, 54, 55, 56, 57, 62, 63, 64, 65, 76, 85, 86, 87, 99, 106, 109, 131]
tp = "_PGV"
#inp = "KP2650/"
#inp = "Test/"
thf = "Vel_C/"

n = 3 # Number of batch-n.dat files

function batch_creation(PGs::Vector{Int64}, tp::String, th_fold::String, inp::String, n::Int64)
  
  #folders = string.(PGs, tp)
  template = collect(eachline(string(inp, tp[2:end], "_Template.txt")))
  batch::Vector{String} = []
  
#  for i in folders
  for i in PGs
    folder = string(inp, i, tp)
    if isdir(folder)
      println("Folder ", folder, " already exists")
    else
      mkdir(folder)	
    end
    file = string(i, tp, ".dat")

    
    if isfile(file)
      println("File ", file, " already exists")
    else
      datfile = copy(template)
      hs = string(i, tp)
      his = string(hs, ".his")
      hisf = collect(eachline(string("Time-Histories/", th_fold, his)))
      time = round(parse(Float64, match(r"\d+", hisf[2]).match) * parse(Float64, match(r" \d.\d+", hisf[2]).match), digits=1)
      #time = parse(Float64, match(r"\d+", hisf[2]).match) * parse(Float64, match(r" \d.\d+", hisf[2]).match)
      #println("")
      #println(time)
      #println("")
      #println("For Time History ", string(i, tp), " Time is: ", time)
      
      if time > 36
        println("Warning: time is ", time," for ", folder,". ", "\n", "Consider using other time history")
      end
      
      for i in 1:length(datfile)
        datfile[i] = replace(datfile[i], "{FILE}" => hs)
        datfile[i] = replace(datfile[i], "{TIME}" => time)
      end

      writedlm(string(inp, file), datfile)
    end
    
    push!(batch, string("call ", file))
    push!(batch, string("save ", file))
    push!(batch, "restore excavation.sav")
    
  end
  
  L = length(batch)/3
  j = Int64(round(L/n, RoundUp))
  for i=1:n
#  print(batch)
    if i == n
      writedlm(string(inp, "batch", i, ".dat"), batch[1+(n-1)*j*3:end])
    else
      writedlm(string(inp, "batch", i, ".dat"), batch[1+(i-1)*j*3:3*j*i])	
    end
  end
end


inps = ["KP2650/", "KP6250/", "KP8550/"]
batch_creation.(Ref(pgs), tp, thf, inps, n)
