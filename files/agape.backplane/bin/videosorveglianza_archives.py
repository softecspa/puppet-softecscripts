#!/usr/bin/env python

"""TODO."""

import argparse
import os
import sys
import time
import shutil

libpath = '/usr/local/lib/softec-python'
try:
        sys.path.insert(0, os.path.realpath(os.environ['MYLIBDIR']))
except KeyError:
        sys.path.insert(0, libpath)

try:
    import liblogging
    import libfileosstat
    from libfileosstat import tstamp_to_localtime
except ImportError as e:
    raise SystemExit('Import Error: %s' % e)

__version__ = '0.1 alpha'
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'


def parse_argv():
    parsearg = argparse.ArgumentParser()

    parsearg.add_argument('-P', '--path', action='append', dest='path',
                          help='PATH, this option can be specified multiple '
                          'times', required=True)

    parsearg.add_argument('-d', '--days', action='store', dest='days',
                          help='archives files with `mtime` older than N '
                          'day(s), default 1', type=int, default=1)

    parsearg.add_argument('-p', '--pattern', action='store', dest='pattern',
                          help='file pattern (optional and support Unix '
                          'shell-style wildcards)', type=str)

    parsearg.add_argument('-L', '--log-level', dest='log_level',
                          choices=('DEBUG', 'INFO', 'WARNING', 'ERROR',
                                   'CRITICAL'),
                          help='Log Level (default: INFO)',
                          default='INFO')

    parsearg.add_argument('-V', '--version', action='version',
                          version='%(prog)s ' + __version__)

    return parsearg.parse_args()


def main():
    args = parse_argv()

    (path,
     days,
     pattern,
     log_level) = (args.path,
                   args.days,
                   args.pattern,
                   args.log_level)

    scriptname = os.path.basename(__file__)
    stat = libfileosstat.OsStat()
    log_fmt = '%(asctime)s [%(levelname)s] %(name)s: %(message)s'

    log = liblogging.setup_logging(name=scriptname,
                                   log_level=log_level,
                                   fmt=log_fmt)

    now = time.time()
    old_than = now - (days * 86400)

    def get_items(path, instance, pattern=None):
        if not pattern:
            return instance.walk(path)

        return instance.fnmatch_walk(path, pattern)

    log.info('Starting')

    for p in path:
        for item in get_items(p, stat, pattern):
            if item.mtime < old_than:
                item_date = tstamp_to_localtime(item.mtime, '%F')
                log.debug('Processing %s' % item.name)
                dst = os.path.join(('%s-archives' % p), item_date)

                try:
                    if not os.path.isdir(dst):
                        log.debug('Mkdir %s' % dst)
                        os.makedirs(dst)
                except EnvironmentError:
                    log.exception('Mkdir %s' % dst)
                    sys.exit(1)

                try:
                    log.debug('Move %s To %s/' % (item.name, dst))
                    shutil.move(item.name, dst)
                    time.sleep(0.001)
                except EnvironmentError:
                    log.exception('Move %s' % dst)
                    sys.exit(1)

    log.info('Finished')

if __name__ == '__main__':
    main()
