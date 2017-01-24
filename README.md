# fmu-builder

## Setup

Make sure python 3 is installed
```bash
git clone git@github.com:into-cps/fmu-builder.git fmu-builder
// make virtual python 3 env
mkvirtualenv --python=/usr/bin/python3 -a fmu-builder fmubuilder
// install dependencies
pip install -r requirements.txt 
```



## Start service
change to the user running the service e.g. `sudo su - fmubuilder`

```bash
workon fmubuilder
./start_uwsgi.sh 
//or to stop the service
./stop_uwsgi.sh
```
