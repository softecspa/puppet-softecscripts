# == Define: softecscripts::get
#
# Get a script from puppet master
#
# The script could be generic or specific by FQDN, DOMAIN,
# LSB Dist Codename or generic operating system, as facter
# reports them.
#
# === Parameters
#
#   [*isadmin*]
#     The script path is 'sbin' instead of 'bin', on the source
#     and the same on the target host. Permission of binary file
#     and config file (if present) are set accordingly.
#     The default is FALSE.
#
#   [*hasconfig*]
#     The script has a config script ${name}.conf, pushed with the same logic
#     of the source
#
#   [*confmode*]
#     Override mode for conf file. Default is 660 if $isadmin is set to true,
#     664 if $isadmin is set to false. With this parameter you can specify your
#     customized mode.
#
#   [*incron*]
#     Set this parameter to true if you want that script is executed by cron
#
#   [*cron_frequency*]
#     Frequency of cron execution (frequently, hourly, daily, weekly, monthly)
#
#   [*cron_special*]
#     This parameter is used to set cron execution using special word (ex. boot)
#
#   [*cron_*]
#     Each of other cron_* parameter are documented under cron::entry and
#     cron::customentry defines
#
# === Examples
# To push a common script named 'myutil' put it on the Puppet Master
# in the module directory:
#
#   modules/softecscripts/bin/myutil
#
# and add
#
#   softecscripts::get { 'myutil': }
#
# on the desidered node. The paths where the script is searched are:
#
#   modules/softecscripts/files/$HOSTNAME/bin/
#   modules/softecscripts/files/$DOMAIN/bin/
#   modules/softecscripts/files/$OPERATINGSYSTEM/bin/
#   modules/softecscripts/files/$LSBDISTCODENAME/bin/
#   modules/softecscripts/files/bin/
#
#
# If you need to push a script to be run only from root and with a config file:
#
#   softecscripts::get { 'myutil':
#     isadmin => true,
#     hasconfig => true,
#   }
#
# Put the same script in cron with daily execution
#
#   softecscripts::get { 'myutil':
#     isadmin         => true,
#     hasconfig       => true,
#     incron          => true,
#     cron_frequency  => 'daily'
#   }
#
# Put the same script in cron with customized execution
#
#   softecscripts::get { 'myutil':
#     isadmin     => true,
#     hasconfig   => true,
#     incron      => true,
#     cron_hour   => '23',
#     cron_minute => '50',
#   }
#
define softecscripts::get(
  $ensure           = present,
  $isadmin          = false,
  $hasconfig        = false,
  $confmode         = '',
  $incron           = false,
  $cron_frequency   = '',
  $cron_user        = 'root',
  $cron_hour        = "*",
  $cron_minute      = "*",
  $cron_month       = "*",
  $cron_monthday    = "*",
  $cron_weekday     = "*",
  $cron_special     = false,
  $cron_path        = false,
  $cron_workdir     = '/',
  $cron_nice        = "19",
  $cron_ionice_cls  = "2",
  $cron_ionice_prio = "7",
)
{
  $bin = $isadmin ? {
    true    => 'sbin',
    default => 'bin',
  }

  $binmode = $isadmin ? {
    true    => '770',
    default => '775',
  }

  $conf_mode = $confmode ? {
    ''  => $isadmin ? {
      true    => '660',
      default => '664',
    },
    default => $confmode
  }

  file { "/usr/local/$bin/${name}":
    ensure  => $ensure,
    source  => [
      "puppet:///modules/softecscripts/${::fqdn}/${bin}/${name}",
      "puppet:///modules/softecscripts/${::domain}/${bin}/${name}",
      "puppet:///modules/softecscripts/${::lsbdistcodename}/${bin}/${name}",
      "puppet:///modules/softecscripts/${::operatingsystem}/${bin}/${name}",
      "puppet:///modules/softecscripts/${bin}/${name}"
    ],
    mode    => $binmode,
    owner   => 'root',
    group   => 'admin',
  }

  if $hasconfig {
    file { "/usr/local/etc/${name}.conf":
      ensure  => $ensure,
      source  => [
        "puppet:///modules/softecscripts/${::fqdn}/etc/${name}.conf",
        "puppet:///modules/softecscripts/${::domain}/etc/${name}.conf",
        "puppet:///modules/softecscripts/${::lsbdistcodename}/etc/${name}.conf",
        "puppet:///modules/softecscripts/${::operatingsystem}/etc/${name}.conf",
        "puppet:///modules/softecscripts/etc/${name}.conf"
      ],
      mode    => $conf_mode,
      owner   => 'root',
      group   => 'admin',
    }
  }

  if $incron {
    if ($cron_frequency != '') {
      cron::entry { $name:
        frequency   => $cron_frequency,
        user        => $cron_user,
        command     => "if [ -x /usr/local/${bin}/${name} ]; then /usr/local/${bin}/${name}; fi",
        workdir     => $cron_workdir,
        nice        => $cron_nice,
        ionice_cls  => $cron_ionice_cls,
        ionice_prio => $cron_ionice_prio,
        ensure      => $ensure,
        path        => $cron_path,
      }
    }
    else {
      if ( $cron_hour == '*' and $cron_minute == '*' and $cron_month == '*' and $cron_monthday == '*' and $cron_weekday == '*' and $cron_special == false) {
        fail ('Please specify when cron must be executed (cron_special or cron_hour, cron_minute etc.)')
      }
      else
      {
        cron::customentry { $name:
          command     => "if [ -x /usr/local/${bin}/${name} ]; then /usr/local/${bin}/${name}; fi",
          user        => $cron_user,
          workdir     => $cron_workdir,
          nice        => $cron_nice,
          ionice_cls  => $cron_ionice_cls,
          ionice_prio => $cron_ionice_prio,
          ensure      => $ensure,
          path        => $cron_path,
          hour        => $cron_hour,
          minute      => $cron_minute,
          month       => $cron_month,
          monthday    => $cron_monthday,
          weekday     => $cron_weekday,
          special     => $cron_special,
        }
      }
    }
  }

}
