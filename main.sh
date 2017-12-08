
user=tshinagawa
pass=2mecno7v2k
export user pass

#JP_Spend
#start_date="'2017-10-01'"
#end_date="'2017-10-31'"
#export start_date  end_date

echo Enter start date
read start_date
export start_date

echo Enter end date
read end_date
export end_date

#Customer Names
#echo -e 'client_id\tcustomer_name' > customer_names.csv
#shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./customer_names.sh >> customer_names.csv

#sort customer_names.csv -o customer_names.csv

#Cost Report
echo -e 'client_id\tclient_name\tcustomer_id\tyear\tmonth\tlocal_cost\ttraffic_cost\tGoogle_cost\tYJP_cost\tYDN_cost\ttraffic_folder\tactive_campaigns_traffic\tall_campaigns' > 1_jp_spend_report.csv
shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./jp_spend.sh >> 1_jp_spend_report.csv

sort 1_jp_spend_report.csv -o 1_jp_spend_report.csv 

#User login details
echo -e 'client_id\tuser_login' > 2_marin_login_count.csv
shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./marin_login.sh >> 2_marin_login_count.csv 

sort 2_marin_login_count.csv -o 2_marin_login_count.csv 

#Daily Reports
echo -e 'client_id\tdaily_report' > 3_reports.csv
shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./reports.sh >> 3_reports.csv

sort 3_reports.csv -o 3_reports.csv

#PCA Linked
echo -e 'client_id\tGoogle_PCA\tYJP_PCA\tYDN_PCA' > 4_Linked_PCAs.csv
shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./PCA_link_count.sh >> 4_Linked_PCAs.csv

sort 4_Linked_PCAs.csv -o 4_Linked_PCAs.csv

#Custom Tracking Check
echo -e 'client_id\tcustom_tracking' > 5_custom_tracking.csv
shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./custom_tracking_check.sh >> 5_custom_tracking.csv

sort 5_custom_tracking.csv -o 5_custom_tracking.csv


#Last Pub Cost Date
echo -e 'client_id\tGoogle_Last_Date\tYJP_Last_Date\tYDN_Last_Date' > 6_last_cost_date.csv
shuf JP_Client_Spend_List.txt | xargs -P 20  -L 1 ./last_cost_date.sh >> 6_last_cost_date.csv

#Join the Tables
join -t $'\t' 1_jp_spend_report.csv 2_marin_login_count.csv -a1 > joined_1_2.csv
join -t $'\t' joined_1_2.csv 3_reports.csv -a1 > joined_1_2_3.csv
join -t $'\t' joined_1_2_3.csv 4_Linked_PCAs.csv -a1 > joined_1_2_3_4.csv
join -t $'\t' joined_1_2_3_4.csv 5_custom_tracking.csv -a1 | tac > all_done.csv

#echo "JP_Spend_is_Ready" | mail -s "JP_Spend_Ready" -a /home/tshinagawa/JP_Client_Spend/all_done.csv tshinagawa@marinsoftware.com, jkao@marinsoftware.com 

mytime=`date +%Y-%m-%d:%H:%M:%S`
echo " JP-Spend-The query has finsihed at $mytime" | mail -s "JPspend finished at $mytime" tshinagawa@marinsoftware.com 
