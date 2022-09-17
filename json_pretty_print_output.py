import json

# Clean data
with open("json_output.txt","r") as f:
    contents = f.readlines()
f = open("temp.txt", "w")
for i in range(len(contents)):
    contents[i] = contents[i].replace("\\","")
    contents[i] = contents[i].replace("\"[","[")
    contents[i] = contents[i].replace("]\"","]")
    f.write(contents[i])
    if i!=len(contents)-1:
        f.write(",")
f.close()

# Pretty print
with open("temp.txt","r") as json_output:
    json_data = json.load(json_output)
f = open("final_output.txt", "w")
json_pretty_print = json.dumps(json_data, indent=2)
f.write(json_pretty_print)
f.close()