#!/usr/bin/env Rscript
f <- file("stdin")
data <- read.csv(f)
#message(data)

message("Multiple debug messages")
message("Multiple debug messages")

# Place processing here. Pass data to the function.
result = 35

# single output to STDOUT
# You only output the result to STDOUT
print(result)

