#!/bin/bash
# Credits: http://stackoverflow.com/a/26082445/756986
set -e

export PING_SLEEP=60s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
   echo "############# Dependency build log(tail -1000) start #############"
   tail -1000 $BUILD_OUTPUT
   echo "############# Dependency build log end #############"
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  exit 1
}
# If an error occurs\  run our error handler to output a tail of the build
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.

bash -c "while true; do echo \ $(date) - building ...; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

changed_files=("shogun.rb")
options=("--with-brewed-matplotlib","--with-brewed-numpy","--with-csharp-modular","--with-java-modular","--with-lua-modular","--with-lua-static","--with-matlab-static","--with-octave-modular","--with-octave-static","--with-python-modular","--with-python-static","--with-r-modular","--with-r-static","--with-tests")

# Check individual files ending in ".rb"
file="shogun.rb"
brew install $(brew deps $file) >> $BUILD_OUTPUT 2>&1

for option in "${options[@]}"
do
    echo "Building with option: $option "
    # Dump output of building dependencies to log file
    # Explicitly print the verbose output of test-bot
    brew install $file $option -v >> $BUILD_OUTPUT 2>&1
    brew uninstall $file
done


# The build was successful dump the output
dump_output

# nicely terminate the ping output loop
kill $PING_LOOP_PID
