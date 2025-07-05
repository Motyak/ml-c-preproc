
# synopsis
./mlcpp.sh -o output_file input_file args...

# example
./mlcpp.sh -o myprog.ml myprog.mlp -I .

# omitting the -o option will create an associated %.ml file
# ,.. so this has the same effect as previous command
./mlcpp.sh myprog.mlp -I .

# you can also output in the stdout
./mlcpp.sh -o - myprog.mlp -I .
