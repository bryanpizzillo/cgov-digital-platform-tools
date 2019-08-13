#!/bin/bash

## Function to parse YAML file
## Borrowed Code from https://medium.com/@mike.reider/handle-bash-config-file-variables-like-a-pro-957dc9a838ed
## and referenced https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
  local prefix=$2
  local s=’[[:space:]]*’ w=’[a-zA-Z0–9_]*’ fs=$(echo @|tr @ ‘\034’)
  sed -ne “s|^\($s\)\($w\)$s:$s\”\(.*\)\”$s\$|\1$fs\2$fs\3|p” \
  -e “s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p” $1 |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=””; for (i=0; i<indent; i++) {vn=(vn)(vname[i])(“_”)}
      printf(“%s%s%s=\”%s\”\n”, “‘$prefix’”,vn, $2, $3);
    }
   }'
}

die() {
  printf '%s\n' "$1" >&2
  show_help
  exit 1
}

## Print Usage Information
function show_help {
  cat << EOF
  Usage: copy-logs.sh [-options] --site-group site-group --env env

  where options include:
    --config\tThe config file location. DEFAULT: ~/.cgdpconfig.yml
    -h -? --help\tprint this help message
EOF
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


echo "$site_group $environment"
# rsync -avzhe ssh --exclude '*.pos' user@remote:/remote/folder /local/folder
