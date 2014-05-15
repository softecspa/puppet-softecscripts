#!/usr/bin/env python

import hashlib as _hashlib

__version__ = '0.1 alpha'
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'


def md5sum(filepath, buffersize=8192):
    """Make MD5 hexdigest.

    Keywords arguments:

    filepath -- path to the target file
    buffersize (optional) -- size in byes for read file descriptor

    Returns: tuple (hexdiges, filepath)

    """
    try:
        with open(filepath, 'rb') as fh:
            m = _hashlib.md5()
            while True:
                data = fh.read(buffersize)
                if not data:
                    break
                m.update(data)

        return (m.hexdigest(), filepath)
    except IOError:
        raise
