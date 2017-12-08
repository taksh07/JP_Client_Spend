client_id=$1
customer_id=$2
dbp=$3

server_name="${dbp}.prod.marinsw.net"
kif="marin_olap_staging.keyword_instance_fact_${customer_id}_${client_id}"	
kid="marin_olap_staging.keyword_instance_dim_${customer_id}_${client_id}"

query="

SELECT
$client_id client_id
, cl.client_name
, $customer_id customer_id
, te.the_year
, te.the_month
, sum(kif.publisher_cost) Local_Cost
, SUM(CASE
       WHEN f.bid_system = 'Traffic' THEN kif.publisher_cost
   END) AS Traffic_Cost
, SUM(CASE
        WHEN kid.publisher_id = 4 THEN kif.publisher_cost ELSE 0 end) as Google_Cost
, SUM(CASE
	WHEN kid.publisher_id = 9 THEN kif.publisher_cost ELSE 0 end) as YJP_Cost
, SUM(CASE
        WHEN kid.publisher_id = 13 THEN kif.publisher_cost ELSE 0 end) as YDN_Cost
, COUNT(distinct (case when f.bid_system = 'Traffic' then f.folder_id end)) as Traffic_Folder
, (SELECT 
            COUNT(DISTINCT pc.publisher_campaign_id)
        FROM
            ${kid} kid
                JOIN
            marin.publisher_campaigns pc ON pc.publisher_campaign_id = kid.publisher_campaign_id
                JOIN
            marin.folders f ON kid.folder_id = f.folder_id
        WHERE
            pc.publisher_campaign_status = 'active'
                AND f.folder_name <> 'Unassigned') AS Active_Campaigns_Traffic
, (SELECT 
            COUNT(DISTINCT pc.publisher_campaign_id)
        FROM
            ${kid} kid
                JOIN
            marin.publisher_campaigns pc ON pc.publisher_campaign_id = kid.publisher_campaign_id
        WHERE
            pc.publisher_campaign_status = 'active') as All_Campaigns

FROM 
 ${kif} kif                                                                       
JOIN ${kid} kid on kid.keyword_instance_dim_id = kif.keyword_instance_dim_id		
JOIN marin.time_by_day_epoch te on kif.time_id=te.time_id
JOIN marin.folders f on kid.folder_id=f.folder_id
JOIN marin.clients cl on f.client_id=cl.client_id

WHERE
cl.client_id=$client_id
and kif.time_id BETWEEN DATEDIFF($start_date,'2004-12-31') AND DATEDIFF($end_date,'2004-12-31')

group by 1,4,5

"

mysql -h $server_name  -u $user -p$pass -e "$query" -N



