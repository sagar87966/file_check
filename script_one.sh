#!/bin/bash
#title           :script_one.sh
#description     :check for files and do operation according to that
#author          :sagar_deotale
#version         :1.0
#====================================================================================================================================

file_path="/app/access.log"
date=`date +%Y-%m-%d`
date_time=`date +%Y-%m-%d-%H:%M`
recepient_email="$2" 


msg() {
    local message="$1"
    echo "$date_time - INFO - $message"
}

:
error_exist() {
    local message="$1"
    echo "$date_time - INFO - $message"
    exit 55
}


file_check(){
    msg "+++++++++++++++++++++++++++++++++++++++++++++++++++Script Started++++++++++++++++++++++++++++++++++++++++++"
    if [ ! -e "$file_path" ]
    then
   	error_exist "File ${file_path} not found."
    else
   	msg  "file found"
   	stat --printf="%s"  "$file_path"
   	size_check
    fi
    msg "+++++++++++++++++++++++++++++++++++++++++++++++++++Script End++++++++++++++++++++++++++++++++++++++++++++"
}

size_check(){
   file_size=`du -k "$file_path" | cut -f1`
   echo $file_size
   if [ "$file_size" -ge 1024 ]
   then
        msg "File size is greater than or equal to 1mb"
        `mv $file_path  /app/access-$date.log`
	local changed_file="app/access-${date}.log"
        local retrive_name=$(echo "$changed_file" | cut -c 5-53)
        read -p "Enter recepient email address if more than ',' seperated : " sender_email 	
        sendemail "access.log renamed" "As the file size was equal to or more than 1MB file was renamed to ${retrive_name}"
   elif [ "$file_size" -ge 5000 ]
   then
        `rm -rf $file_path`
	msg "File size is equal to or more than 5mb"
        msg "File deleted successfully!!!!!!!!"
	read -p "Enter recepient email address if more than ',' seperated : " sender_email
        sendemail "access.log deleted" "As the file size was equal to or more than 5 MB access.log file was deleted"
   else
        msg "File is less than 1mb"	   
   fi
   create_empty_file "mail" "mail"
}

sendemail(){
   local subj="$1"
   local cont="$2"
   echo "$cont" | mail -s "$subj" $sender_email  
}

create_empty_file(){	
   local user_to_check="$1"
   local group_to_check="$2"
   local user=$(whoami)   
   if [[ "$user_to_check" -eq "$user" && $(getent group $group_to_check) ]];
   then
      msg "User and Group exist."
      touch "/app/access.log"
      chown mail:mail "/app/access.log"
   else
      msg "User and Group not exist"   
   fi    
}

main(){
   file_check
}

main
