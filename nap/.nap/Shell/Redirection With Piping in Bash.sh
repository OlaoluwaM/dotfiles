#!/usr/bin/env bash

# input redirection must come first, and output redirection must be the last thing 
tr a A <prologue | sort | cat >newprologue
