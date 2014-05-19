class softecscripts::logrotate {

  logrotate::file { 'softecscripts':
    log          => '/var/local/log/*.log',
    interval     => 'weekly',
    rotation     => '12',
    options      => [ 'missingok', 'compress', 'notifempty' ],
    archive      => true,
    olddir       => '/var/local/log/archives/softecscripts',
    olddir_owner => $softecscripts::logrotate_olddir_owner,
    olddir_group => $softecscripts::logrotate_olddir_group,
    olddir_mode  => $softecscripts::logrotate_olddir_mode,
    create       => "${softecscripts::logrotate_olddir_mode} ${softecscripts::logrotate_olddir_owner} ${softecscripts::logrotate_olddir_group}",
  }
}
