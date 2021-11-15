# Operating Systems Paper
  
***

## Helper Commands

* man command
		
		man ls
		man rm
		man mkdir

* history command - hisplays all used in terminal in the current session

		history
		up-arrow
		down-arrow

* clear terminal
		
		clear

* paste into terminal

		control-shift-v
		shift-insert

---

## Linux Commands To Navigate File System

* Get the current directory, this will output: **/home/useraccountname**
		
		pwd

* Get the files and Directories within the current directory
		
		ls

		// get files and directories recursively from the current directory
		ls -R

		// to get information about file type, permissions, memory blocks, owner/creator, 
		// user group of owner, file size(bytes), created date/time, directory/file name
		la -al

		ls -a - show hidden files and directories
---
## Create and View Files - Cat Command
* create file
		
		cat > filename 
		(enter, type text content in the terminal, ctrl+d to return to command prompt)
* view file content
		
		cat filename
		(output the text content within the file)
* join file

		cat file1 file2 > newfile
		this will inject/combine the content of each text file into a new file
		cat newfile
		show the content of the new file
---

## Delete, remove, rename  files 
 		
* check current directory
		
		ls

* remove file

		rm FileName
* move file - requires superuser permissions

		mv filename newfilelocation
		sudo mv test.txt /home/student/exams/

* rename file

		mv filename newfilename
	
# Directories

* make directory

		mkdir filename

* make sub-directory

		mkdir /tmp/music
* create multiple directories - in current
		
		mkdir folder1 folder2 folder3
* delete directory - remove files/sub-directories first

		rmdir directoryname
* rename directory

		mv directoryname newdirectoryname

**Edit Table**
Linux Command List
Below is a Cheat Sheet of Linux commands list we have learned in this Linux commands tutorial

Command	Description
ls	Lists all files and directories in the present working directory
ls - R	Lists files in sub-directories as well
ls - a	Lists hidden files as well
ls - al	Lists files and directories with detailed information like permissions, size, owner, etc.
cat > filename	Creates a new file
cat filename	Displays the file content
cat file1 file2 > file3	Joins two files (file1, file2) and stores the output in a new file (file3)
mv  file "new file path"	Moves the files to the new location
mv filename new_file_name	Renames the file to a new filename
sudo	Allows regular users to run programs with the security privileges of the superuser or root
rm filename	Deletes a file
man	Gives help information on a command
history	Gives a list of all past basic Linux commands list typed in the current terminal session
clear	Clears the terminal
mkdir directoryname	Creates a new directory in the present working directory or a at the specified path
rmdir	Deletes a directory
mv	Renames a directory
pr -x	Divides the file into x columns
pr -h	Assigns a header to the file
pr -n	Denotes the file with Line Numbers
lp -nc
lpr c	Prints "c" copies of the File
lp -d lpr -P	Specifies name of the printer
apt-get	Command used to install and update packages
mail -s 'subject' -c 'cc-address' -b 'bcc-address' 'to-address'	Command to send email
mail -s "Subject" to-address < Filename	Command to send email with attachment

---

```
ls -a <path>
ls -al ~
ls -A ~
```

Show Exclusively Hidden Files using ls
```
ls -dl .[^.]* <path>
```
```
$ ls -dl .[^.]* ~

-rw-------   1 schkn schkn 43436 Oct 26 06:08 .bash_history
-rw-r--r--   1 schkn schkn   220 Apr  4  2018 .bash_logout
-rw-r--r--   1 schkn schkn  3771 Apr  4  2018 .bashrc
drwx------   2 schkn schkn  4096 Jan  5  2019 .cache
drwx------   5 schkn schkn  4096 Jan  5  2019 .config
```

```
$ dir -a <path>
$ dir -A <path>
```