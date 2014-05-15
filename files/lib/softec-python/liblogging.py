#!/usr/bin/env python

import logging
import sys

# http://docs.python.org/2/howto/logging.html
# parte del codice su gentile concessione di Andrea Cappelli

__version__ = (0, 0, 1)
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'


def setup_logging(name=None, filename=False, log_level='INFO', fmt=None,
                  datefmt=None):
    """

    Level       Numeric value
    CRITICAL    50
    ERROR       40
    WARNING     30
    INFO        20
    DEBUG       10
    NOTSET      0

    """
    log = logging.getLogger(name)

    if not fmt:
        fmt = '%(asctime)s [%(levelname)s] %(name)s.%(module)s: %(message)s'

    formatter = logging.Formatter(fmt, datefmt)

    if not filename:
        hdlr = logging.StreamHandler(sys.stdout)
    elif filename == '-':
        # log to sys.stderr
        hdlr = logging.StreamHandler()
    elif filename:
        hdlr = logging.FileHandler(filename)
    else:
        hdlr = logging.NullHandler()

    hdlr.setFormatter(formatter)
    log.addHandler(hdlr)
    log.setLevel(getattr(logging, log_level))

    return log


if __name__ == '__main__':
    log = setup_logging(name=__name__, log_level='DEBUG')
    for level in ('debug', 'info', 'warn', 'error', 'critical'):
        getattr(log, level)('foobar')
