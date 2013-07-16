#!/usr/bin/bash
# script to get the details of the tables created in hive.

#get the list of tables created in default database and other databases created in hive. select req.fields and send the results to a file
hadoop fs -ls /user/hive/warehouse/ | awk '{print $3, $4, $6, $7, $8}' > $1 

#loop to read each line of file to find databases
while read p
do 

#get the db path
file=$(awk '{ if ($NF ~ /.db/) print $5 }')

#get the list of tables in the db. select fields and concat to the file
hadoop fs -ls $file | awk '{print $3, $4, $6, $7, $8}' >> $1 
done < $1


sed -e 's/\/.*\///' $1 > $2 #replace the absolute path with table name
sed '/.db/d' $2 > $1 #remove the databases
sed '/items/d' $1 > $2 #remove unnessesary rows

#get the list of tables and their sizes
hadoop fs -du /user/hive/warehouse > $1

while read p
do
db=$(awk '{ if ($NF ~ /.db/) print $2}')

hadoop fs -du $db >> $1
done < $1

sed -e 's/\/.*\///' $1 > $3
sed '/.db/d' $3 > $1
sed -e 's/ .* / /g' $1 > $3
