# Setting up a local environment

## Prerequisite
The below are the prerequisites that needs to be done before proceeding with the setup steps.
1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install-sdk) and authenticate
2. Access to Google Cloud Platform's BigQuery
3. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Setup
1. Create local environment and install required packages
```shell
# Run this in the setup dir
./setup.sh
```

2. If the virtual environment is not active, run the below command
```shell
source $HOME/venv/grhp-ae/bin/activate
```

3. Set dbt profiles variable
```shell
# Run this in grhp dir
export DBT_PROFILES_DIR=$PWD
```

4. Test connection
```shell
dbt debug
```
