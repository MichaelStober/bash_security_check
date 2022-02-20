# bash_security_check
Hi this is my first bash script to practise bash programming.
This script filters a given username/username list, transfered through stdin, according to given criteria to find out the access rights of the user. 


Here are some examples for usage:
### 1. filters user which are not present
  $echo "mail root doesNotExist" | .security_check.sh 
#### output:
  mail
  root
 
### 2. user from /etc/passwd with id>1000 without "userName"
  cat /etc/passwd | cut -d : -f 1 | ./security_check.sh -I-u "userName"
#### output:
  nobody
### 3. User id <1000 and active login shell
  $echo "mail root 'userName'" | ./security_check.sh -l -i
#### output:
  root
 
