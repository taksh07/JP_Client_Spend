client_id=$1
customer_id=$2
dbp=$3


  server_name="dbp-mc-reports.prod.marinsw.net"

query="

select 
$client_id client_id
, cd.client_name
, cd.currency
, te.the_month
, te.the_year
, CASE
        WHEN cf.publisher_id = 4 THEN 'Google'
        WHEN cf.publisher_id = 9 THEN 'Yahoo Japan'
        WHEN cf.publisher_id = 6 THEN 'Bing'
        ELSE 'other'
    END AS Publisher
, sum(cf.publisher_cost) local_cost
, if (cd.currency='USD' ,  sum(cf.publisher_cost) , sum(cf.publisher_cost/x.rate) ) as  cost_in_USD

from 
marin_common.client_fact cf
join marin_common.client_dim cd on cf.client_id=cd.client_id
join marin_common.time_by_day_epoch te on te.time_id=cf.time_id

left join (
select target_currency,  date(date) the_date, avg(rate) rate
from marin_common.usd_currency_rates
where date between date($start_date) and date($end_date)

group by 1,2
) x on x.target_currency=cd.currency and x.the_date=te.the_date

  
where 
te.the_date between date($start_date) and date($end_date)
and cf.client_id=$client_id
and conversion_type_id=1

group by 1,2,4,5,6

"

  mysql -h $server_name -u $user -p$pass -e "$query" -N
