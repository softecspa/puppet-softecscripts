# == Define: softecscripts::root
#
# Put softec utility scripts in /root/scripts and
# ensure it's updated on each puppet run
#
# === Examples
#
# softecscripts::root { 'root scripts': }
#
define softecscripts::root
{

  if ($::svn_user == '') or ($::svn_password == '') or ($::svn_host == '') {
    fail ('you need to define $svn_user $svn_password and $svn_host global variables!')
  }

  $method = $::svn_method ?{
    ''      => 'http',
    default => $::svn_method
  }

  file { '/root/scripts':
    ensure  => directory,
  }

  subversion::checkout { 'root-scripts-co':
    method              => $method,
    host                => $::svn_host,
    repopath            => '/sistemi/trunk/scripts',
    workingdir          => '/root/scripts',
    svnuser             => $::svn_user,
    password            => $::svn_password,
    require             => File['/root/scripts'],
    trustcert           => true,
  }
}
