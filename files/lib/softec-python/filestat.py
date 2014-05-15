#!/usr/bin/env python

import fnmatch
import os
import re
import sys
import time


def tstamp_to_localtime(seconds, time_format=None):
    if not time_format:
        return time.ctime(seconds)
    else:
        return time.strftime(time_format, time.localtime(seconds))


class OsStat(object):
    def _path_exists(self, path):
        if os.path.exists(path):
            return os.stat(path)
        else:
            return (None for i in range(10))

    def _stat(self, path):
        (self.mode,
         self.ino,
         self.dev,
         self.nlink,
         self.uid,
         self.gid,
         self.size,
         self.atime,
         self.mtime,
         self.ctime) = self._path_exists(path)

    def walk(self, path):
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                self.name = os.path.join(dirpath, filename)
                self._stat(self.name)
                yield self

    def fnmatch_walk(self, path, pattern=None):
        pattern = pattern if pattern else '*'

        for dirpath, dirnames, filenames in os.walk(path):
            for filename in fnmatch.filter(filenames, pattern):
                self.name = os.path.join(dirpath, filename)
                self._stat(self.name)
                yield self

    def re_walk(self, path, pattern=None):
        if not pattern is None:
            pattern = re.compile(pattern)
        else:
            pattern = re.compile('.*')

        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                self.name = os.path.join(dirpath, filename)
                if pattern.search(self.name):
                    self._stat(self.name)
                    yield self

    def __repr__(self):
        return '%r' % self.name

    def __str__(self):
        return '%s' % self.name


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: %s PATH [pattern]' % sys.argv[0])
        sys.exit(1)

    path = sys.argv[1]

    try:
        pattern = sys.argv[2]
    except IndexError:
        pattern = None

    stat = OsStat()

    for file_ in stat.fnmatch_walk(path, pattern):
        print(file_)
