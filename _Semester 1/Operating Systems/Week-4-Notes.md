# User & File Permissions

---

-   UGO = user, group, others
-   max value = 7, min value 0.
    -   eg: 777 = UGO -> read, write, execute

`umask` gets the current umask value

### Base permission defaults

1. Files: 666 = UGO -> Read, Write
2. Directory: 777 = UGO -> Read, Write, Execute

## Examples

| Base Permission | Base Permission | Effective Permission | Resulting Permission | UGO                                               |
| --------------- | --------------- | -------------------- | -------------------- | ------------------------------------------------- |
| 666             | 002             | `666-002=664`        | `-rw-rw-r--`         | U=6/RW or 4+2, G=6/RW or 4+2, O=4/R or 4          |
| 777             | 002             | `777-002=775`        | `drwxrwxr-x`         | U=7/RWX or 4+2+1, G=7/RWX or 4+2+1, O=5/RX or 4+1 |

---

## Modifying Default Permissions

1. The user (owner) can read and write
2. The group (group) can only read and write
3. Anyone else (other) can not do anything

Symbolic notation for these file permissions:
`-rw-rw----`

Octal notation for the file permissions: `660`

umask = (BASE PERMISSION − EFFECTIVE PERMISSION)

To set umask for user(owner) only read and write access: default file umask is 666, user read and write is 600 `umask: 666-600=066`

```bash
student@server:~$ mkdir newdir_tmp
student@server:~$ ls -ld newdir_tmp/
drwxrwxr-x 2 student student 4096 Mar 18 21:52 newdir_tmp/
student@server:~$ sudo chmod o-r newdir_tmp/
[sudo] password for student:
student@server:~$ ls -ld newdir_tmp/
drwxrwx--x 2 student student 4096 Mar 18 21:52 newdir_tmp/
```

## User Permissions

### Types



## UMask

## Sticky Bits

The sticky bit has no direct effect on files, but, when used on a directory, all the files in said directory will be modifiable only by their owners. 

```bash
$ ls -ld /tmp
drwxrwxrwt. 14 root root 300 Nov  1 16:48 /tmp
```

 In this case the owner, the group, and all other users, have full permissions on the directory (read, write and execute). The sticky bit is identifiable by a `t` which is reported where normally the executable `x` bit is shown, in the "other" section. Again, a lowercase `t` implies that the executable bit is also present, otherwise you would see a capital `T`.

### Setting Sticky Bits

Sticky bits can be set using the `chmod` command using either the numeric or UGO format. 

For effective security, Linux divides authorization into 2 levels.

1. Ownership
2. Permission

```
student@server:~$ touch test100                                                 
student@server:~$ ls -l test100                                                 
-rw-rw-r-- 1 student student 0 Mar  9 17:00 test100                             
student@server:~$ chmod u+x test100                                             
student@server:~$ ls -l test100                                                 
-rwxrw-r-- 1 student student 0 Mar  9 17:00 test100                             
student@server:~$ chmod u=r,g=x,o+w test100                                     
student@server:~$ ls -l test100                                                 
-r----xrw- 1 student student 0 Mar  9 17:00 test100 
```

```
student@server:~$ chmod 764 test100                                             
student@server:~$ ls -l test100                                                 
-rwxrw-r-- 1 student student 0 Mar  9 17:00 test100                             
student@server:~$ chmod 564 test100                                             
student@server:~$ ls -l test100                                                 
-r-xrw-r-- 1 student student 0 Mar  9 17:00 test100  
student@server:~$ "ownership"                                                   
/dev/mem: Permission denied                                                                                                         
student@server:~$ ls -l test100                                                 
-r-xrw-r-- 1 student student 0 Mar  9 17:00 test100                             
student@server:~$ sudo chown manager test100                                    
[sudo] password for student:                                                    
student@server:~$ ls -l test100                                                 
-r-xrw-r-- 1 manager student 0 Mar  9 17:00 test100 

student@server:~$ sudo chown manager test100                                    
[sudo] password for student:                                                    
student@server:~$ ls -l test100                                                 
-r-xrw-r-- 1 manager student 0 Mar  9 17:00 test100                             
student@server:~$ sudo chown manager:manager test100                            
student@server:~$ ls -l test100                                                 
-r-xrw-r-- 1 manager manager 0 Mar  9 17:00 test100     

student@server:~$ umask                                                         
0002                                                                            
student@server:~$ touch newfile100                                              
student@server:~$ ls -l newfile100                                              
-rw-rw-r-- 1 student student 0 Mar  9 17:04 newfile100  

student@server:~$ mkdir newdir100                                               
student@server:~$ ls -l 
drwxrwxr-x 2 student student  4096 Mar  9 17:05 newdir100  
```

