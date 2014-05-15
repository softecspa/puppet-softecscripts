# = Define: softecscripts::remote-updater
#
# This define create cronjobs to update a local file from an URL
#
# == Parameters:
#
# $remote_url::     The remote URL to download updated file
#
# $local_file::     The local file to be updated
#
# $action::         A command to be executed on each local file update
#                   In example a service reload.
#
# $mode:            The file permission to be applied to file
#
# $user::           The cron user
#
# $hour::
# $mimute::         The time of the scheduled cronjob
#
# == Actions:
#   The remote file is downloaded form the URL in a temp file, if
#   the downloaded file diffs from the current version of local one
#   the temp file is copied on the local one.
#
# == Requires:
#   - File["/usr/local/bin/remote-updater"]
#
# == Sample Usage:
#
#   softecscripts::remote-updater { "asp.vcl updater":
#       remote_url => "http://cluster.asp.softecspa.it/varnish_asp.vcl",
#       local_file => "/etc/varnish/articolo-test/vhosts.d/asp.vcl",
#       action  => "varnish-instance-reload articolo-test",
#   }
#
define softecscripts::remoteupdater (
  $remote_url,
  $local_file,
  $action = '',
  $mode   = '664',
  $user   = 'root',
  $hour   = '*',
  $minute = '*/5',
  $owner  = '',
  $group  = ''
)
{
  cron { "remote-updater for $local_file":
    command => "/usr/local/bin/remote-updater '$remote_url' '$local_file' '$action' $mode '$owner' '$group'",
    user    => $user,
    hour    => $hour,
    minute  => $minute,
    require => File['/usr/local/bin/remote-updater'],
  }
}
