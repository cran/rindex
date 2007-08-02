#!/bin/sh

# This script performs the main build steps necessary to build
# the ref package. This script mainly completes one task:
# 1. Produce the Rd-files for the documentation from the R source files
# 
# Prerequisites:
# 	- Perl
#   - R_HOME must be set to the directory where R is installed

echo "#### starting build.sh"

# Produce Rd-files using the perl script "make_rd.pl"
mkdir -p exec
if [ -f ../common/make_rd.pl ]; then cp ../common/make_rd.pl exec; fi
mkdir -p man
cd man
find ../R -name '*.[rR]' -exec cat \{\} \; | perl ../exec/make_rd.pl 
cd ..

# Generate INDEX file
$R_HOME/bin/rcmd RdIndex . || echo "rcmd Rdindex failed!"

echo "#### build.sh completed!"