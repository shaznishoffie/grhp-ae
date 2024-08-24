#/bin/zsh

# create a directory for virtual environment on local if doesn't exist
mkdir $HOME/venv/

# create a virtual environment for the project
python3 -m venv $HOME/venv/grhp-ae

# switch to virtual environment
source $HOME/venv/grhp-ae/bin/activate

# upgrade pip if not upgraded
python3 -m pip install --upgrade pip

# install packages
python3 -m pip install dbt-core dbt-bigquery
pip install $(cat requirements.txt)
