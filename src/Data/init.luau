local nodes={}
for _,name in {"Chunk001","Chunk002","Chunk003","Chunk004","Chunk005","Chunk006","Chunk007","Chunk008","Chunk009","Chunk010","Chunk011","Chunk012","Chunk013","Chunk014","Chunk015","Chunk016","Chunk017","Chunk018","Chunk019","Chunk020","Chunk021","Chunk022","Chunk023","Chunk024","Chunk025","Chunk026","Chunk027","Chunk028","Chunk029","Chunk030","Chunk031","Chunk032","Chunk033","Chunk034","Chunk035","Chunk036","Chunk037","Chunk038","Chunk039","Chunk040","Chunk041","Chunk042","Chunk043","Chunk044","Chunk045","Chunk046","Chunk047","Chunk048","Chunk049","Chunk050","Chunk051","Chunk052","Chunk053"} do
 for _,node in require(script[name]) do table.insert(nodes,node) end
end
return nodes
