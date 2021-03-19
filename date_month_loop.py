#/usr/bin python
import datetime
from dateutil.relativedelta import relativedelta

start='2020-10-21'
end='2021-01-21'

datestart=datetime.datetime.strptime(start,'%Y-%m-%d')
dateend=datetime.datetime.strptime(end,'%Y-%m-%d')

#table_name="accounting_journal"
table_name=['sub_ledger_entry','general_ledger_entry','application_journal','adjust_sub_ledger_entry','adjust_ledger_entry','accounting_journal_register','accounting_journal_entry','accounting_journal','adjust_journal_entry']

for table in table_name:
    start='2019-09-01'
    end='2022-02-01'

    datestart=datetime.datetime.strptime(start,'%Y-%m-%d')
    dateend=datetime.datetime.strptime(end,'%Y-%m-%d')

    # cteate default partition
    #print("CREATE TABLE {0}_default_partition  PARTITION OF {0} DEFAULT;".format(table))

    # cteate min partition
    print("CREATE TABLE {0}_p201909_before  PARTITION OF {0} FOR VALUES FROM (MINVALUE) TO ('2019-09-01 00:00:00'::timestamp);;".format(table))

    # create dayliy partition
    while datestart<dateend:
        day01=datestart.strftime('%Y-%m-%d')
        day02=datestart.strftime('%Y%m')

        #datestart+=datetime.timedelta(days=1)
        datestart=(datestart + relativedelta(months=+1))
        day01_t=datestart.strftime('%Y-%m-%d')
        #print(day01, day02)

        print("CREATE TABLE {0}_p{3}  PARTITION OF {0} FOR VALUES FROM ('{1} 00:00:00'::timestamp) TO ('{2} 00:00:00'::timestamp);".format(table,day01,day01_t,day02))
