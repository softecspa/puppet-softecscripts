import calendar
import datetime
import os
import shutil
import sys
import time

__version__ = (0, 1, 1, 'alpha')
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'


def to_stdout(msg):
    return sys.stdout.write('%s\n' % msg)


def to_stderr(msg):
    return sys.stderr.write('%s\n' % msg)


def human_time(seconds):
    """Seconds to human time."""
    return datetime.timedelta(seconds=float(seconds))


def str_join(*args):
    """iterble to string."""
    return ' '.join(str(i) for i in args)


def timestamp_to_localtime(seconds, time_format=None):
    """Timestamp to localtime."""
    if not time_format:
        return time.ctime(seconds)
    else:
        return time.strftime(time_format, time.localtime(seconds))


def utc_date_to_timestamp(date_string, time_format=None):
    """UTC date to timestamp."""
    if not time_format:
        time_format = '%Y-%m-%d %H:%M'

    time_tuple = time.strptime(date_string, time_format)
    return calendar.timegm(time_tuple)


def date_now(time_format=None):
    if time_format is not None:
        return datetime.datetime.now().strftime(time_format)

    return ('%s' % datetime.datetime.now())


def file_copy(sources, dst, suffix=None, overwrite=False):
    """Copy data and all stat info ("cp -p src dst").

    iterable:sources    --  sources
    str:dst             --  dest directory
    str:suffix          --  suffix, ex.: .orig
    bool:overwrite      --  True or False

    raise: IOError()
    """

    if isinstance(sources, str):
        sources = [sources]

    for src in sources:
        dstfile = os.path.join(dst, os.path.split(src)[-1])

        if suffix:
            dstfile += suffix

        if not os.path.exists(dstfile) or overwrite:
            try:
                shutil.copy2(src, dstfile)
            except shutil.Error, err:
                raise IOError(err)


def human_size(size_in_bytes):
    """
    Keywords arguments:
        size_in_bytes -- file size in bytes

    Returns: string
    """
    if size_in_bytes == 1:
        # return "1 byte"
        return '%s %s' % (float(1), 'B')

    suffixes_table = [
        ('B', 0), ('kiB', 0), ('MiB', 1), ('GiB', 2), ('TiB', 2),
        ('PiB', 2),
    ]

    num = float(size_in_bytes)
    for suffix, precision in suffixes_table:
        if num < 1024.0:
            break
        num /= 1024.0

    if precision == 0:
        formatted_size = '%d' % num
    else:
        formatted_size = str(round(num, ndigits=precision))

    return float(formatted_size), suffix
