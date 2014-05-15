#!/usr/bin/env python

"""
    Script per calcolare specifici giorni del mese, ad esempio: tutti  i
    venerdi'  del  mese,  il  primo  sabato  del  mese  oppure  l'ultima
    domenica. Restituisce il giorno come numero intero.

    esempio:

    $ python daysofmonth.py -y 2013 -m 4 -d friday
    5, 12, 19, 26

    $ daysofmonth.py -y 2013 -m 4 -d friday -p last
    26

    esempio di utilizzo con cron:

    02 00 * * * root [ $(date +\%d) -eq $(daysofmonth.py -d friday -p last) ] \
            && esegui_qualcosa

    Autore: Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>
"""

import optparse
import datetime
import calendar
import sys


def main():
    desc = 'Print specific days of month'
    parsearg = optparse.OptionParser(description=desc)

    parsearg.add_option('-y', '--year', action='store', dest='year',
                        default=datetime.datetime.now().year,
                        type=int, help='Year, ex.: 2013, default ' +
                        'current year')

    parsearg.add_option('-m', '--month', action='store', dest='month',
                        default=datetime.datetime.now().month,
                        type=int, help='Month, ex.: 4 for April, default ' +
                        'current month')

    parsearg.add_option('-d', '--dayname', action='store',
                        dest='dayname', help='day name, ex.: friday, ' +
                        'sunday, etc...',
                        type=str)

    parsearg.add_option('-p', '--period', action='store',
                        dest='period', help='first, second, third, ' +
                        'fourth, fifth and last day of month, where day ' +
                        'is dayname',
                        type=str)

    (options, args) = parsearg.parse_args()

    if not options.dayname:
        parsearg.error('--dayname: required')

    (year,
     month,
     day_name,
     period) = (options.year,
                options.month,
                options.dayname,
                options.period)

    day_name = day_name.lower()

    try:
        cal_of_month = calendar.monthcalendar(year, month)
    except ValueError, err:
        sys.exit(err)

    dow = {'monday': 0,  'tuesday': 1, 'wednesday': 2, 'thursday': 3,
           'friday': 4, 'saturday': 5, 'sunday': 6}

    dom = {'first': 0, 'second': 1, 'third': 2, 'fourth': 3, 'fifth': 4,
           'last': -1}

    if day_name not in dow:
        sys.exit('invalid day name: %s' % day_name)

    if period and period not in dom:
        sys.exit('invalid period name: %s' % period)

    days = []

    for n, week in enumerate(cal_of_month):
        week = cal_of_month[n]
        days.extend([day for day in week
                     if day != 0 and week.index(day) == dow[day_name]])

    if period:
        try:
            return [days[dom[period]]]
        except IndexError:
            return []
    else:
        return days

if __name__ == '__main__':
    result = main()
    print(', '.join(map(str, result)))
