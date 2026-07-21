using DelimitedFiles

function blankify()
  for i in collect(walkdir(pwd()))
    if i[1] != pwd()
      writedlm(string(i[1], "/blank"), "")
    end
  end
end
