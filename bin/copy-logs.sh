#!/bin/bash

## copy-logs.sh
##   Script to copy log files off a Acquia ACSF environment
##
## Prerequisites:
##   * You must have a valid ssh key registered in cloud.acquia.com with
##     access rights to the environment you are downloading from.
##   * A valid config file located at ~/.cgdpconfig.yml
##
## Parameters
##   --site-group - the application name AKA $AH_SITE_GROUP value
##   --env - the environment to copy AKA $AH_SITE_ENVIRONMENT



## Function to parse YAML file
## Borrowed Code from https://medium.com/@mike.reider/handle-bash-config-file-variables-like-a-pro-957dc9a838ed
## and referenced https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

## Exit with error
function die {
  printf '%s\n' "$1" >&2
  show_help
  exit 1
}

## Print Usage Information
function show_help {
  cat << EOF
  Usage:
    copy-logs.sh [-options] --site-group <site-group> --env <environment> <target_dir>
  where options include:
    --config          The config file location. DEFAULT: ~/.cgdpconfig.yml
    -h -? --help      print this help message
EOF
}

function copy_files {
  local server=$1
  local site_group=$2
  local env=$3

  echo "Copying files for $server $site_group $env"

  ## Get the host by splitting off the first item before the .
  host=`echo $server | cut -d. -f1`
  ssh_host="${site_group}.${env}@${server}"
  remote_path="/var/log/sites/${site_group}.${env}/logs/${host}"

  echo "${ssh_host}:${remote_path}"
  # rsync -avzhe ssh --exclude '*.pos' user@remote:/remote/folder /local/folder
  # rsync --delete --exclude '*.pos'
}



## Initialize options
site_group=
environment=
config=~/.cgdpconfig.yml

## Iterate over options
while :; do
  case $1 in
    -h|-\?|--help)
      show_help
      exit
      ;;
    --site-group)
      if [ "$2" ]; then
        site_group=$2
        shift
      else
        die 'ERROR: "--site-group" requires a non-empty option argument.'
      fi
      ;;
    --site-group=?*)
      site_group=${1#*=} # Delete everything up to and "=" and assign remainder.
      ;;
    --site-group=)
      die 'ERROR: "--site-group" requires a non-empty option argument.'
      ;;
    --env)
      if [ "$2" ]; then
        environment=$2
        shift
      else
        die 'ERROR: "--env" requires a non-empty option argument.'
      fi
      ;;
    --env=?*)
      environment=${1#*=} # Delete everything up to and "=" and assign remainder.
      ;;
    --env=)
      die 'ERROR: "--env" requires a non-empty option argument.'
      ;;
    --config)
      if [ "$2" ]; then
        config=$2
        shift
      else
        die 'ERROR: "--config" requires a non-empty option argument.'
      fi
      ;;
    --config=?*)
      config=${1#*=} # Delete everything up to and "=" and assign remainder.
      ;;
    --config=)
      die 'ERROR: "--config" requires a non-empty option argument.'
      ;;
    -?*)
      printf "copy-logs.sh: illegal option -- %s\n" "$1" >&2
      show_help
      exit 2;
      ;;
    *)
      break
  esac

  shift
done

## Check required params
if [ -z "$site_group" ]; then
  die 'ERROR: "--site-group" is required.'
fi

if [ -z "$environment" ]; then
  die 'ERROR: "--env" is required.'
fi

## Check config file
if [ ! -f "$config" ]; then
  die "Config file $config is missing"
fi

## Read the config
## TODO: TEST FOR ERROR
eval $(parse_yaml $config)

## Set servers to the config setting for this app/env
## TODO: So we should go against the Acquia Cloud API in the future to get the
## list of servers for the environment. For now we expect them in the config.
server_conf="config_applications_${site_group}_environments_${environment}_servers"
servers=${!server_conf}

## Exit if bad keys
if [ -z "$servers" ]; then
  printf 'Servers for %s not found\n' "${site_group} ${environments}" >&2
  exit 10
fi

echo "$site_group $environment"
echo "$servers"

## Iterate over servers and fetch files
for server in ${servers}
do
  copy_files $server $site_group $environment
done
