local proplist = {}

for line in io.lines(files['ObjectList'])
do
	table.insert(proplist, line)
end

return proplist
