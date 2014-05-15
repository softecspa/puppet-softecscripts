#!/usr/bin/env python

try:
    import argparse
    import MySQLdb
    import MySQLdb.cursors
except ImportError as err:
    raise SystemExit('Import error: {0}'.format(err))

import re

__version__ = '0.1 alpha'
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'


def parse_argv():
    parser = argparse.ArgumentParser()

    parser.add_argument('-c', '--default-file', dest='mycnf',
                        action='store', default='/etc/mysql/debian.cnf',
                        help='MySQL configuration file to read, default '
                        '/etc/mysql/debian.cnf')

    parser.add_argument('-d', '--db-name', dest='db_name',
                        action='store',
                        help='Select database by name (regexp)')

    parser.add_argument('--innodb', action='store_true',
                        dest='innodb',
                        help='add InnoDB engine, default work only to MyISAM')

    parser.add_argument('-l', '--local', action='store_true',
                        dest='local', help='if OPTIMIZE no write '
                        'statements to the binary log, default False')

    parser.add_argument('-o', '--optimize', dest='optimize',
                        action='store_true', help='OPTIMIZE fragmented '
                        'tables, default print only MyISAM fragmented'
                        'tables')

    parser.add_argument('-t', '--connect-timeout', dest='timeout',
                        action='store', type=int, default=1,
                        help='Abort if connect to MySQL is not completed '
                        'within given number of seconds, default 1.0')

    parser.add_argument('-i', '--ignore-db', action='append',
                        dest='ignore_db', help='ignore database by '
                        'name (regexp), default skip `mysql`, '
                        '`information_schema` and `lost+found` '
                        'this option can be specified multiple times')

    parser.add_argument('-V', '--version', action='version',
                        version='%(prog)s ' + __version__)

    return parser.parse_args()


def human_size(size_in_bytes):
        """
        Keywords arguments:
            size_in_bytes -- size in bytes

        Returns: tuple (size, suffix)
        """
        if size_in_bytes == 1:
            return '{0} {1}'.format(float(1), 'B')

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
            formatted_size = '{0:.1f}'.format(num)
        else:
            formatted_size = str(round(num, ndigits=precision))

        return float(formatted_size), suffix


def main():
    args = parse_argv()

    (mycnf,
     timeout,
     optimize,
     local,
     innodb) = (args.mycnf,
                args.timeout,
                args.optimize,
                args.local,
                args.innodb)

    try:
        with open(mycnf, 'r'):
            pass
    except IOError as e:
        raise SystemExit('{0}: {1}'.format(e.filename, e.strerror))

    db_pattern = None
    db = args.db_name if args.db_name else None
    ignore_db = args.ignore_db if args.ignore_db else []

    # ignore databases
    skip_db = ['mysql', 'information_schema', 'lost\+found']
    skip_db.extend(ignore_db)

    if db:
        try:
            db_pattern = re.compile(db)
        except Exception as err:
            raise SystemExit('re.compile({0})'.format(err))

    try:
        skip_db_pattern = re.compile('^({0})$'.format('|'.join(skip_db)))
    except Exception as err:
        raise SystemExit('re.compile({0})'.format(err))

    # storage engines
    if not innodb:
        storage_engines = ['MyISAM']
    else:
        storage_engines = ['MyISAM', 'InnoDB']

    try:
        con = MySQLdb.connect(read_default_file=mycnf,
                              connect_timeout=timeout)
    except MySQLdb.MySQLError as e:
        raise SystemExit('MySQLdb [{0}]: {1}'.format(e.args[0], e.args[1]))
    except TypeError as e:
        raise SystemExit('Unexpected error: {0}'.format(e))

    # MySQLdb cursor objcet
    cur = con.cursor(MySQLdb.cursors.DictCursor)

    def query(cursor, query):
        cursor.execute(query)
        return cursor.fetchall()

    # format
    fmt = 'Table: {0:>40} Engine: {1} Size: {2:>6} {3:>3} Frag: {4:>3}%'
    # format for OPTIMIZE TABLE
    opt_fmt = 'OPTIMIZE: {0:>37} {1} ({2} {3})'

    try:
        for database in query(cur, 'SHOW DATABASES'):
            db_name = database['Database']

            if skip_db_pattern.match(db_name):
                continue

            if db:
                if not db_pattern.match(db_name):
                    continue

            print('\n= database {0} ='.format(db_name))
            con.select_db(db_name)
            tables_status = query(cur, 'SHOW TABLE STATUS')

            for table in tables_status:
                table_engine = table['Engine']
                if table_engine in storage_engines:
                    table_name = table['Name']
                    data_free = table['Data_free']
                    data_length = table['Data_length']
                    size, suffix = human_size(data_length)
                    fragmentation = 0

                    if data_free != 'NULL':
                        if data_free > 0:
                            fragmentation = (data_free * 100 / data_length)

                    if not optimize and fragmentation > 0:
                        print(fmt.format(table_name, table_engine, size,
                                         suffix, fragmentation))

                    if optimize and fragmentation > 0:
                        if not local:
                            q = 'OPTIMIZE TABLE {0}'.format(table_name)
                        else:
                            q = 'OPTIMIZE LOCAL TABLE {0}'.format(table_name)

                        res = query(cur, q)[0]

                        print(opt_fmt.format(res['Table'].split('.')[1],
                                             res['Msg_text'],
                                             res['Msg_type'],
                                             res['Op']))
    except MySQLdb.MySQLError as e:
        raise SystemExit('MySQLdb [{0}]: {1}'.format(e.args[0], e.args[1]))
    finally:
        if cur:
            cur.close()
        if con:
            con.close()

if __name__ == '__main__':
    main()
