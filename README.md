# cgov-digital-platform-tools
Support tools for the CGov Digital Platform

## Background
Acquia only covers backing up servers for the purposes of data center disaster recovery, not botched deployments or accidental deletions of content. As such we need to ensure that we are taking nightly backups, as well as being able to support on-demand backups prior to deployments. Additionally, we will need other tooling such as log file fetching, and in the future, log file processing. This project is to collect all these tools so that we may run them on our operations servers.

## Approach
We started by trying to containerize Drush commands, but found that you pretty much need a full Drupal install in order to simply run the acsf-tools package. The tools package is actually, just a series of curl commands or wrappers around other drush commands. We can easily make web requests in node, so it seemed easier to create node scripts that could be called from shell. (Via CommanderJS)

## Tools

### Insert tools here.
