#script will check for >1gb size hdfs logs ,confirm final state and delete it if job was successsful.
#It will also maintain the list of deleted applicationID along with application name and size in spark_deletedlogs.txt file.
 
#!/bin/bash
 
#variable declarion section
counter=1
scounter=1
#section end
 
echo "<---------Script execution date and time : " $(date)"------->" >>/home/hadoop/awsinfra/spark_deletedlogs.txt
 
#greping in logs greater than 1 gb
hdfs dfs -du -h /var/log/spark/apps/ | grep G | sort -h | awk '{print $3}' > spark_dl.txt
 
#checking each logs one by one and performing deletion operation after verify job status.
for i in `cat spark_dl.txt`
do
#appid=$(echo $i | cut -d'/' -f8-)
appid=$(echo $i |cut -d '/' -f6-|sed 's/..$//')
#echo $appid
echo "log no : "$counter
echo "ApplicationId :" $appid
hdfs dfs -du -s -h $i
echo "checking final status...."
yarn application -status $appid | grep 'Final-State : SUCCEEDED'
succeed=$?
if [ $succeed -eq 0 ];
then
    echo "safe to delete"
                "Sr no : "$scounter
                yarn application -status $appid | grep 'Application-Name' >> /home/hadoop/awsinfra/spark_deletedlogs.txt
        hdfs dfs -du -s -h $i >> /home/hadoop/awsinfra/spark_deletedlogs.txt
 
                hdfs dfs -rm -R  $i
                echo "Successfully deleted log"
        scounter=$((scounter + 1))
else
    echo "Job failed/still running skiping deletion"
fi
counter=$((counter + 1))
echo "-----------------------------------------------------"
done
echo "Successfully deleted " $((scounter-1)) "logs size greater than 1GB (cat /home/hadoop/awsinfra/spark_deletedlogs.txt for details)"
rm -rf spark_dl.txt
has context menu
