puppet-softecscripts
====================

Common utilities used in the whole infrastructure as scripting facilities.

The module si also used as a scripts repository for many utilities, specific to some host. Not a good way to managed this, we'll must provide a better way in future.

Managed resources
-----------------

* `/var/local/log`: directory where scripts should preferably logs_mode; the module manage logrotate for this path too.
* `sample-bash-script`: template for newly created scripts
* `softec-common.sh`: shared bash library
* `softec-python`: shared python library
* `nway`: run a process multiple times concurrently to take advantage of multiple cores, significantly reducing processing time; see also [official website](http://timkay.com/nway/).
* `solo`: lock system, to be sure a scripts get launched in one instance at a time
* `smartfind`: find in PHP, used on storage appliances with loadaverage too high :) Utility used for backups on USB disks
* `smartdu`: the same of smartfind, but specific to substitute `du` command.
* `remote-updater`: utility to download a remote file from a specified url; can retry if file is not availabled and execute and action if remote file changes
* `file-age`: return the number of seconds since the last change on specified file; it simplifies Puppet recipes where used as a guard in an `Exec` resource.
* `slack`: utility to send messages to [Slack](http://slack.com) channels. It's a simple example usage of the function slack in the bash libray. The configuration file for slack is taken from [softec private](https://git.sftc.it/ops/puppet-softec_private) puppet module.
