# fmu-builder

This branch contains a modified version of compile-fmu and cmakelists compared to the master branch.
The difference is: 
the master branch includes all .c files within the sources folder of an FMU, this branch includes only the ones listing within the `<SourceFiles>` tag of the ModelDescription.xml file - which is the correct behaviour according to the standard.

CMAKE cleanup and build: `rm CMakeCache.txt ; rm -rf CMakeFiles ; rm Makefile ; rm cmake_install.cmake ; cmake CMakeLists.txt ; make`

## Setup

Make sure python 3 is installed
```bash
git clone git@github.com:into-cps/fmu-builder.git fmu-builder
// make virtual python 3 env
mkvirtualenv --python=/usr/bin/python3 -a fmu-builder fmubuilder
// install dependencies
pip install -r requirements.txt 
```
## Start service as a user
change to the user running the service e.g. `sudo su - fmubuilder`

```bash
workon fmubuilder
./start_uwsgi.sh 
//or to stop the service
./stop_uwsgi.sh
```

where `.bash_profile` contains this: 
```bash
export OSXCROSS_ROOT=/var/lib/osxcross/target
export PATH=$OSXCROSS_ROOT/bin:$PATH
export MACOSX_DEPLOYMENT_TARGET=10.7
```

## Start the service from crontab 

```bash

#!/bin/bash

source /home/fmubuilder/.virtualenvs/fmubuilder/bin/activate

export OSXCROSS_ROOT=/var/lib/osxcross/target
export PATH=$OSXCROSS_ROOT/bin:$PATH
export MACOSX_DEPLOYMENT_TARGET=10.7

cd /home/fmubuilder/fmu-builder
git pull
./start_uwsgi.sh
```
```bash
crontab -l

@reboot sleep 60 && /home/fmubuilder/start_fmu_builder.sh```
```
