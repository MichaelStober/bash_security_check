#########################################################################
#Author: Michael Stober, Luka Henig					#
#Date: 12.04.21								#
#Version: 3.3								#
#									#
#Info:									#
#Please use fullscreen to see the right comment position		# 
#F_USER_LIST == Filterd USER LIST					#
#S_USER_LIST == Saves all users with sudo rights			#
#ILS_USER_LIST == Saves all users with an interactive login shell	#
#IDS_USER_LIST == Saves all users with an id smaller than  1000		#
#IDB_USER_LIST == Saves all users with an id bigger equal than 1000	#
#E_USER_LIST == Saves all users except the given one 			#
#########################################################################

#!/bin/bash

helpPage(){
echo "Usage: security_check.sh -h -s -l -i -I -u [username]


Filters a list of users based on security-relevant criteria

This application takes a list of usernames from stdin and filters this

list based on the criteria below. The list can be seperated by spaces

or newlines.

    -h:     Show this help and quit
   
    -s:     Keep users who have sudo rights
   
    -l:     Keep users with an interactive login shell
   
    -i:     Keep users with a user ID < 1000
   
    -I:     Keep users with a user ID >= 1000
   
    -u [username]:  ignore username (username is always removed/filtered)


Usernames that are not present in the system are filtered

(not contained in the result)



Use case examples:

        1) Filtering a manually created list for users with sudo rights:

	echo 'tobias heinz diter www root' | ./security_check.sh -s

        2) Filtering the entries of /etc/passwd: for user IDs >= 1000:

        $ cat /etc/passwd | cut -d : -f 1 | ./security_check.sh -I"                                                                  
exit
}


#Take filtered list and pick out all users with sudo rights
keepUserSudo(){
	for i in $F_USER_LIST; do						
		S_USER_LIST+=`cat /etc/group |  grep 'sudo' | cut -d: -f4 | tr , "\n" | grep "$i"`				#List Users in  sudo group and compare with filtered list
		S_USER_LIST+=" "												#blank to seperate the users
	done
	F_USER_LIST=$S_USER_LIST												#Update filtered list
}


#Take filtered list and pick out all users with Interactiv-Login-Shell
keepUserILShell(){
	for i in $F_USER_LIST; do							
		ILS_USER_LIST+=`cat /etc/passwd | grep -v /usr/sbin/nologin | grep -v /bin/false | cut -d: -f1 | grep "$i"`	#List Users with Interactiv Login Shell and compare with filtered list
		ILS_USER_LIST+=" "	
	done
	F_USER_LIST=$ILS_USER_LIST
}


#Take filtered list and pick out all users with UID smaler than 1000
keepUserID_S1000(){
	for i in $F_USER_LIST; do
		TempS=`id -u $i`												#TempS(smaler) saves UID
		if ( [ $TempS -lt  1000 ] ) then 										#check if UID less than 1000
			IDS_USER_LIST+="$i"											#Add user to filtered list
			IDS_USER_LIST+=" "
		fi									
	done
	F_USER_LIST=$IDS_USER_LIST
}


#Take filtered list and pick out all users with UID greater or equal 100
keepUserID_B1000(){
	for i in $F_USER_LIST; do
		TempB=`id -u $i`												#TempB(Bigger) hold UID	
		if ( [ $TempB -ge  1000 ] ) then										#check if UID greater equal 1000
			IDB_USER_LIST+="$i"											#Add user to filtered list
			IDB_USER_LIST+=" "											
		fi
	done
	F_USER_LIST=$IDB_USER_LIST
}


#cuts given user out of filtered list
exceptUser(){
	for i in $F_USER_LIST; do
		E_USER_LIST+=`echo $i | grep -v "$p_exUser"`									#give all users out of filtered list except OPTARG(given user)
		E_USER_LIST+=" "
	done
	F_USER_LIST=$E_USER_LIST
}


Error(){
	echo "Fail try security_check.sh -h"
	exit 
}

#Print out all users of filtered list in seperate lines
output(){
	for i in $F_USER_LIST; do
		echo $i										
	done
}


#read stdin and check if given users are pressent in the system
read_Stdin(){
	while read -t 0.1 Input; do												#while loop for multiple line input  
		for i in $Input;do
			F_USER_LIST+=`cat /etc/passwd | cut -d: -f1 | grep -w "$i"`						#List all users in system and filter given users
			F_USER_LIST+=" "
		done
	done
}

check_given_parameters(){

        if  ( [ $p_helpPage -eq 1 ] ) then
                helpPage
        fi

        if ( [ $p_exceptUser -eq 1 ] ) then
               exceptUser
        fi
        if ( [ $p_keepUserILShell -eq 1 ] ) then
                keepUserILShell
        fi
        if ( [ $p_keepUserID_S1000 -eq 1 ] ) then
                keepUserID_S1000
        fi
        if ( [ $p_keepUserID_B1000 -eq 1 ] ) then
                keepUserID_B1000
        fi
        if ( [ $p_keepUserSudo -eq 1 ] ) then
                keepUserSudo
        fi

}

init(){
p_helpPage=0
p_keepUserILShell=0
p_exceptUser=0
p_keepUserID_S1000=0
p_keepUserID_B1000=0
p_keepUserSudo=0
}



init
read_Stdin
while getopts "hsliIu:" opt;
do
        case ${opt} in
                h )     p_helpPage=1
                        ;;
                u )     p_exceptUser=1
                        p_exUser=$OPTARG
                        ;;
                l )     p_keepUserILShell=1;;
                i )     p_keepUserID_S1000=1;;
                I )     p_keepUserID_B1000=1;;
                s )     p_keepUserSudo=1;;
                \?)     Error
        esac
done
check_given_parameters
output  							#print finished filtered list
