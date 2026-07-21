using DelimitedFiles

# Convert **explicitlty** flac 8.0 results into workable csvs
function csv_export(fp) #fp is a full filepath
  
  lines = collect(eachline(fp))
  
  for i in 5:length(lines)
    
    lines[i] = replace(lines[i], "          "=>"")
    lines[i] = replace(lines[i], "   " => "  ")
    lines[i] = replace(lines[i], "  " => ",")
    
  end
  
  
  par = match(r"\s\w+ \w+", match(r"time(.)+", lines[3]).match).match[2:end]
  header = replace(string("t,", par), " " => "")
  file = vcat(header, lines[5:end])
  
  writedlm(string(fp[1:end-3], "csv"), file, quotes=false)

end

