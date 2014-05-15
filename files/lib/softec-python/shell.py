#!/usr/bin/env python

"""AUTHOR:Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>."""

import collections
import os
import shlex
import subprocess


class run(object):
    def __new__(cls, command, **kwargs):
        cwd = kwargs.get('cwd')
        env = dict(os.environ)
        env.update(kwargs.get('env', {}))
        shell = kwargs.get('shell', False)
        nowait = kwargs.get('nowait', False)

        if not shell:
            command = shlex.split(command)

        p = subprocess.Popen(
            command,
            universal_newlines=True,
            shell=shell,
            cwd=cwd,
            env=env,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
            bufsize=0,
        )

        stdout, stderr, returncode, pid = (None, None, None, None)
        result = collections.namedtuple(
            'Result', 'stdout, stderr, returncode, pid')

        if command[-1] == '&' or nowait:
            if p.poll() is None:
                returncode = 0
            else:
                returncode = 1
            return result(stdout, stderr, returncode, pid)

        (stdout, stderr) = p.communicate()
        (returncode, pid) = (p.returncode, p.pid)

        stdout = stdout.rstrip() if stdout else stdout
        stderr = stderr.rstrip() if stderr else stderr

        return result(stdout, stderr, returncode, pid)


if __name__ == "__main__":
    import sys
    import shell as sh

    if os.name == 'posix':
        out, err, code, pid = sh.run('ping -c 1 127.0.0.1')
        format = 'stdout=%s\nstderr=%s\ncode=%d\npid=%d\n'
        print(format % (out, err, code, pid))

        print(sh.run('ls NOT_exists').stderr)

        out, err = sh.run('ls | wc -l', shell=True)[:2]
        if err:
            sys.exit(err)
        else:
            print('%s' % out)

        #ecode = sh.run('firefox about:blank', nowait=True)[2]
        #if ecode == 0:
        #    print('firefox executed successfully, exit-code %d' % (ecode))
        #else:
        #    print('firefox failed, exit-code %d' % (ecode))
    elif os.name == 'nt':
        print(sh.run('dir', shell=True).stdout)
