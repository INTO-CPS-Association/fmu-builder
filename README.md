# fmu-builder

This branch contains a modified version of compile-fmu and cmakelists compared to the master branch.
The difference is: 
the master branch includes all .c files within the sources folder of an FMU, this branch includes only the ones listing within the `<SourceFiles>` tag of the ModelDescription.xml file - which is the correct behaviour according to the standard.

## Setup

Make sure python 3 is installed with venv support
```bash
git clone git@github.com:into-cps/fmu-builder.git fmu-builder
// make virtual python 3 env
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt 
```

Versions used at the time of development is:
```
uWSGI-2.0.19.1
Django-3.2.7
```
## Start service as a user
change to the user running the service e.g. `sudo su - fmubuilder`

```bash
# if not already activated
source venv/bin/activate

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

source /home/fmubuilder/fmubuilder/venv/bin/activate

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

# Guide for creating the django structure

```
django-admin startproject fmubuildersite
python manage.py startapp builderapp
python manage.py runserver
python manage.py migrate
python manage.py makemigrations builderapp
python manage.py sqlmigrate builderapp 0001
python manage.py migrate
python manage.py runserver
```