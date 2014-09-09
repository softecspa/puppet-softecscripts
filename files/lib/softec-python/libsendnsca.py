#!/usr/bin/env python

import os

try:
    from libsh import run
except ImportError as e:
    raise SystemExit('Import Error: %s' % e)

__version__ = (0, 0, 1)
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'


class SendNsca(object):

    def __init__(self, nsca_host, nsca_cmd='send_nsca', nsca_port=5667,
                 nsca_conf=None):

        self.nsca_cmd = nsca_cmd
        self.nsca_host = nsca_host
        self.nsca_port = nsca_port
        self.nsca_conf = nsca_conf

        self._is_executable(self.nsca_cmd)
        self._nsca_cmd = ('%s -p %s -H %s' % (self.nsca_cmd,
                                              self.nsca_port,
                                              self.nsca_host))
        if self.nsca_conf:
            self._nsca_cmd = ('%s -c %s' % (self._nsca_cmd,
                                            self.nsca_conf))

    def _is_executable(self, file_):
        for path in os.environ.get('PATH', '').split(':'):
            file_path = os.path.join(path, file_)
            if os.path.isfile(file_path) and os.access(file_path, os.X_OK):
                return True

        raise OSError('%s: No such file or Not executable' % (self.nsca_cmd))

    def _send_result(self, host, code, output, svc=None):
        if not svc:
            res = ('%s\t%s\t%s' % (host, code, output))
        else:
            res = ('%s\t%s\t%s\t%s' % (host, svc, code, output))

        cmd = ('echo "%s" | %s' % (res, self._nsca_cmd))
        return run(cmd, shell=True)

    def service_result(self, host, svc, code, output):
        return self._send_result(host, code, output, svc)

    def host_result(self, host, code, output):
        return self._send_result(host, code, output)
