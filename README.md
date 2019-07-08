# cgov-digital-platform-tools
Support tools for the CGov Digital Platform

## Background
Acquia only covers backing up servers for the purposes of data center disaster recovery, not botched deployments or accidental deletions of content. As such we need to ensure that we are taking nightly backups, as well as being able to support on-demand backups prior to deployments. Additionally, we will need other tooling such as log file fetching, and in the future, log file processing. This project is to collect all these tools so that we may run them on our operations servers.

## General Guidance
Almost all tools should be containerized. This allows us to:
* more easily upgrade those packagages required by our tools without littering the servers with multiple versions of outdated packages
* test scripts locally in different OSes than those that run on the operations servers

We should be able to easily do a `docker run -it . > output.log` in a folder to run the program and output to a log file. More so, each "tool" that is created should have a shell script to wrap that command. (Sometimes you will need to pass additional docker parameters, such as volumes, into the command line and that can get messy.)

All "tools" running in the container should be configured to output to standout, as is normal container practice. This allows for us to redirect the output on the host.

Finally the wrapper script for the tool should handle error cases from the tool, and send email if it failed. Additionally, it should send emails if it succeded so that we know that the program ran. (Unless we find a better way to determine that it ran)

If a tool is only using simple commands installed on the OS, then it does not need to be containerized. (e.g. scp some log files from a server.)

## Tools

### Insert tools here.