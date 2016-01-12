# == Define: softecscripts::root
#
# Put softec utility scripts in /root/scripts and
# ensure it's updated on each puppet run
#
# === Examples
#
# include softecscripts::root
#
class softecscripts::root(
  $svn_host = 'svn.softecspa.it',
  $svn_user = '',
  $svn_password = '',
  $svn_method   = 'http',
)
{
  include subversion

  if ($svn_user == '') or ($svn_password == '') or ($svn_host == '') {
    fail('Missing parameters $svn_user $svn_password or $svn_host')
  }

  vcsrepo { '/root/scripts':
    ensure              => latest,
    provider            => 'svn',
    source              => "${svn_method}://${svn_host}/sistemi/trunk/scripts",
    basic_auth_username => $svn_user,
    basic_auth_password => $svn_password,
    require             => Package['subversion'],
  }

}
