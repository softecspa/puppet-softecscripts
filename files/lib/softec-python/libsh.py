import errno
import os
import shlex
import signal
import subprocess
import types

__version__ = (0, 0, 1)
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'
__all__ = ['run']


class Alarm(Exception):
    pass


class TimeoutError(Exception):
    pass


class run(object):

    """With Alex Martelli's solution for process killing."""

    def __init__(self, command, **kwargs):
        """

        - command with pipe require shell=True
        - raise OSError when command not found or permission denied
        - raise TimeoutError when command exceeds timeout

        """

        if isinstance(command, (list, tuple, types.GeneratorType)):
            command = ' '.join(str(item) for item in command)

        if not isinstance(command, (str, unicode)):
            raise TypeError('command: expect str object or unicode object')

        bufsize = kwargs.get('bufsize', 0)
        close_fds = kwargs.get('close_fds', False)
        cwd = kwargs.get('cwd')
        env = dict(os.environ)
        kill_tree = kwargs.get('kill_tree', True)
        nowait = kwargs.get('nowait', False)
        shell = kwargs.get('shell', False)
        stderr = kwargs.get('stderr', subprocess.PIPE)
        stderr_to_stdout = kwargs.get('stderr_to_stdout', False)
        stdout = kwargs.get('stdout', subprocess.PIPE)
        sudo = kwargs.get('sudo', False)
        timeout = kwargs.get('timeout', -1)
        universal_newlines = kwargs.get('universal_newlines', False)
        env.update(kwargs.get('env', {}))

        def alarm_handler(signum, frame):
            raise Alarm

        def get_process_children(pid):
            command = shlex.split('ps --no-headers -o pid --ppid %d' % pid)
            p = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            stdout, stderr = p.communicate()
            return [int(p) for p in stdout.split()]

        if stderr_to_stdout is True:
            stdout = subprocess.PIPE
            stderr = subprocess.STDOUT

        if timeout != -1:
            signal.signal(signal.SIGALRM, alarm_handler)
            signal.alarm(timeout)

        if sudo is True:
            command = '%s %s' % ('sudo', command)

        cmd = shlex.split(command) if shell is False else command

        (self.stdout,
         self.stderr,
         self.returncode,
         self.pid) = (None for i in range(4))

        p = subprocess.Popen(
            args=cmd,
            bufsize=bufsize,
            close_fds=close_fds,
            cwd=cwd,
            env=env,
            shell=shell,
            stderr=stderr,
            stdout=stdout,
            universal_newlines=universal_newlines,
        )

        if cmd[-1] == '&' or nowait is True:
            if p.poll() is None:
                self.returncode = 0
            else:
                self.returncode = 1
            return

        try:
            self.stdout, self.stderr = p.communicate()
            if timeout != -1:
                signal.alarm(0)
        except Alarm:
            pids = [p.pid]
            if kill_tree:
                pids.extend(get_process_children(p.pid))
            for pid in pids:
                # process might have died before getting to this line
                # so wrap to avoid OSError: no such process
                try:
                    os.kill(pid, signal.SIGKILL)
                except OSError:
                    pass

            e_msg = 'command "%s" %s, pid(s) %s killed' % (
                command,
                os.strerror(errno.ETIME),
                ','.join(str(p) for p in pids)
            )
            raise TimeoutError(e_msg)
        else:
            self.returncode, self.pid = p.returncode, p.pid
            self.stdout = self.stdout.rstrip() if self.stdout else self.stdout
            self.stderr = self.stderr.rstrip() if self.stderr else self.stderr

        self._list = [self.stdout, self.stderr, self.returncode, self.pid]

    def __getitem__(self, index):
        return self._list[index]

    def __repr__(self):
        return '%s' % self._list


if __name__ == '__main__':
    if os.name == 'posix':
        cmd = 'ls -l'
        res = run(cmd)
        if res.returncode != 0:
            print('%s exit with code %d' % (cmd, res.returncode))
            print('%s' % res.stderr)
        else:
            # slicing
            print('%s' % res[0])
    elif os.name == 'nt':
        print(run('dir', shell=True).stdout)

    # Firefox
    # run('firefox about:blank', nowait=True)

    # Command Not Found or Permission Denied
    # cmd = 'foo'
    # try:
    #     run(cmd)
    # except OSError as e:
    #     raise SystemExit('%s: %s' % (cmd, e.strerror))

    # Timeout Error
    cmd = 'sleep 5'
    timeout = 1
    try:
        res = run(cmd, shell=False, timeout=timeout)
    except TimeoutError as e:
        raise SystemExit(e)
