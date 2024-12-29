#/bin/bash

if [ -n "$dbname" ]; then
  dbname=$1
  shift
else
  dbname=tpcc
fi
sql_vec=(
"select a.* from (select w_id, w_ytd from bmsql_warehouse) a left join (select d_w_id, sum(d_ytd) as d_ytd_sum from bmsql_district group by d_w_id) b on a.w_id = b.d_w_id and a.w_ytd = b.d_ytd_sum where b.d_w_id is null"

"select a.* from (select d_w_id, d_id, D_NEXT_O_ID - 1 as d_n_o_id from bmsql_district) a left join (select o_w_id, o_d_id, max(o_id) as o_id_max from bmsql_oorder group by  o_w_id, o_d_id) b on a.d_w_id = b.o_w_id and a.d_id = b.o_d_id and a.d_n_o_id = b.o_id_max where b.o_w_id is null"

"select a.* from (select d_w_id, d_id, D_NEXT_O_ID - 1 as d_n_o_id from bmsql_district) a left join (select no_w_id, no_d_id, max(no_o_id) as no_id_max from bmsql_new_order group by no_w_id, no_d_id) b on a.d_w_id = b.no_w_id and a.d_id = b.no_d_id and a.d_n_o_id = b.no_id_max where b.no_id_max is null"

"select * from (select (count(no_o_id)-(max(no_o_id)-min(no_o_id)+1)) as diff from bmsql_new_order group by no_w_id, no_d_id) a where diff != 0"

"select a.* from (select o_w_id, o_d_id, sum(o_ol_cnt) as o_ol_cnt_cnt from bmsql_oorder  group by o_w_id, o_d_id) a left join (select ol_w_id, ol_d_id, count(ol_o_id) as ol_o_id_cnt from bmsql_order_line group by ol_w_id, ol_d_id) b on a.o_w_id = b.ol_w_id and a.o_d_id = b.ol_d_id and a.o_ol_cnt_cnt = b.ol_o_id_cnt where b.ol_w_id is null"

# result of this sql is not empty, this is from aliyun doc, should be wrong
#"select a.* from (select d_w_id, sum(d_ytd) as d_ytd_sum from bmsql_district group by d_w_id) a left join (select w_id, w_ytd from bmsql_warehouse) b on a.d_w_id = b.w_id and a.d_ytd_sum = b.w_ytd where b.w_id is null"
)
for sql in "${sql_vec[@]}"; do
  mysql -uroot -t ${dbname} -e "${sql}"
done
