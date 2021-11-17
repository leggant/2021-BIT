# Assignment: Scripting in PowerShell

This assignment is worth 15%, which includes performing the actual assignment including the planning tasks as part of the instructions!
**Deadline: Wednesday, 1 September 2021, 11:59pm**

## Summary

A business environment is emulated through the use of `FileModifier` and `FakeSMTP`. FileModifier creates, deletes and modifies files and folders on the local system; within its current directory. FakeSMTP provides a fake email server, which will handle the email notification sent each time there is new or deleted file (or directory??).

### Task

Create a backup mechanism using a script that uses Robocopy, which is monitored by a secondary PowerShell script. This monitor script sends an e-mail notification upon any addition or deletion of files (not for modified files). Change events and errors are also to be logged to the Windows event log.

## Data Flow

1. init.bat initialise project >> Opens `fakeSMTP`,  `robocopy`
2. FileModifier >> Writes to changes >> File System
3. File System >> reads >> Robocopy **Config/pwrshell**
4. Robocopy **Config** >> Creates Backup + Writes Log
5. Log >> Reads >> Powershell Script **Development**
6. Powershell Script **Development** >> Sends Email + Writes Log

## Pre-Flight Checks

1. To set up your environment, first ensure you have at least PowerShell 4.0 installed.
2. In order to run the FileModifier as well as FakeSmtp you will further require the Java Runtime Environment (`https://www.java.com/en/download/manual.jsp`) version 7 or higher.
3. double-click the ‘FileModifier.jar’ and ‘FakeSmtp-2.0.jar’ and they should launch.
4. right click on `init.bat` to initialise the project.

### File Structure

Set up the project file system structure, with ‘C:\IN609_OE1’ as the base directory
should be easily configurable in your code
FileModifier.jar
Copy the entire file structure, including all subdirectories and files of the source directory (`Files`) to a separate target directory (‘Files_Backup’),
Run persistently in a separate terminal window and recheck for file system changes (Robocopy can do this out of the box – check the help),
Write a continuous logfile that contains all detected file system changes, including full pathnames of affected files.
The logfile should be stored in the base folder (‘OSC-Assignment’) outside any of the ‘Files’ folders (‘Files’, ‘Files_Backup’).

### Directory Structure

```bash
OSC-Assignment
   |-- Assignment 1-Anthony Legg 03007276.docx
   |-- IN609_OE1
   |   |-- Files
   |   |   |-- FileModifier.jar
   |   |-- fakeSMTP-2.0.jar
   |   |-- init.bat
   |   |-- leggtc1_monitor.ps1
   |   |-- leggtc1_monitor.ps1
   |   |-- leggtc1_robocopy.ps1
   |-- INSTRUCTIONS.md
   |-- Outline of steps.md
   |-- images
   |   |-- assignment instructions.1.jpg
   |   |-- assignment instructions.2.jpg
   |   |-- assignment instructions.3.java check for updates.jpg
```

### Init.bat Script

### leggtc1_robocopy.ps1

identify file paths as variables and store those at a single location in your code,
so they can be easily changed (e.g. from C: to D:, change in pathnames, etc.).

### leggtc1_monitor.ps1

- use PowerShell to parse a logfile, format to console

backup mechanism based on Robocopy that is monitored by a PowerShell script.

1. send an e-mail notification upon any addition or deletion of files
2. (not for modified files)
3. Events or Errors are further written to the Windows event log.

Your PowerShell script will periodically query this logfile
and check for added or deleted files. per minute

If such changes have happened, it will send an e-mail containing an overview of those changes and write those to the Windows Event log.

Your work thus consists of multiple stages,
with the initial task of setting up the FileModifier and configure Robocopy.

- The FileModifier will work in whatever directory it is started from.
- separate the logfile from the actual file system,
- create a subfolder called ‘Files’
- save the FileModifier.jar in that 'Files/'.

The structure should thus appear as shown in Figure 4.

- IN609_OE1
- Files
- FileModifier.jar
- Generated Files from FileModifier.jar
- Start the FileModifier and run it in ‘Live Mode’ for a few minutes.
- it incrementally builds up a folder structure as well as files within the ‘Files’ subfolder.
- It randomly adds, deletes and modifies files within that folder structure.
- You can delete the generated files at any time and start over.

As mentioned above, Robocopy offers an abundance of different configuration options, which you can explore by typing ‘robocopy /?’ on the command line.

The formatting of the actual logfile is left to you, but knowing that you will need to parse it, you would want to minimize the output and remove any unnecessary information. A possible output format is in Figure 5.

- output time/date of run in human readable format
- file name
- file path
- status (new file, deleted file)
- current user

- debugging: Robocopy options to write the content it saves to the logfile to the screen.
- test configuration
- note down the complete command
  since it is necessary to replicate and test your system as part of your submission.
  Ideally you save it in a batch file, so you can easily launch your complete configuration whenever you need it.
  batch file required in final submission, name `init.bat`

- extract the relevant entries for new and deleted files
- send a notification e-mail
- post an event log entry in the Windows event log.

- This way one can follow up on events even if e-mails have been lost or deleted.
- The notification about specific added or deleted files should only occur once, not repeatedly.
- Log execution errors (e.g. sending of e-mail), your script should log an error in the event log.

Initially you would want to break the complex overall activity down into manageable work packages, which you can (to some extent) address in isolation.
What are those tasks? (Write them down, so you can use it as a guide to address the scripting tasks systematically and can revisit it later!)

As part of the core functionality, your script is supposed to run continuously without interruption! Bear that in mind when structuring your code and consider the use of functions and loops for this purpose.

Also test the setup for robustness:
What happens if several components of the system do not work (e.g. robocopy, e-mail, etc.)?

You may not be able solve all required tasks at the current stage, but you know enough to get address individual subtasks immediately.

## Parse Log File To Console

- [ ] Log Errors

## Deliverables

The deliverable (in addition to this worksheet) is one zip file with the name `IN609S220-studentCode` (where ‘studentCode’ is your OP student code). This file should at least include:

- Planning Steps as instructed in this document (Task 2)
- Setup Instructions (.txt, .pdf, or .doc/x)
- Batch file (.bat) or script that starts Robocopy with the correct configuration. Ensure that you DO NOT name the file ‘robocopy.bat’ or ‘robocopy.cmd’ – else your batch file will enter an infinite loop. Any other name should work fine.
- PowerShell script file(s) (.ps1)
- Screen shot of your execution

PowerShell: The central element of our work will be the configuration of the use of Microsoft PowerShell. In this assignment you will use it to integrate the functionalities provided by other tools which is a common task in system administration scripting. You will use PowerShell to parse a logfile generated by Robocopy in order to identify newly added or deleted files and send notification e-mails and log Windows events.
FakeSmtp: To avoid all the nuisance that comes with varying network environments (you may do part of the assignment at home or at Polytechnic), we use a tool that fakes a real smtp mail server and does not actually send e-mails to the target address, but instead allows you to inspect sent messages. In the context of software development, e.g. when implementing e-mail sending facilities, it is a good testing tool. Changing the mail server in a production environment should then only be a matter of adjusting the configuration. When you use it, ensure you run it on a drive it can write to, since it attempts to create the folder ‘received-mails’ where it stores mails for inspection. Once you see the user interface (as shown in Figure 1), you can start the actual server by clicking on ‘Start server’. At this stage it will be able to receive e-mails. Note that relies on Java to run. More information on that is provided in the Setup section below.

Figure 1: FakeSMTP Interface

To simulate a business environment in which users continuously create, modify and delete files you will use the tool FileModifier (see Figure 2). It offers a ‘Live Mode’, which will continuously perform random file operations (and which will be used to evaluate your work), and a ‘Debug mode’ in which you can perform specific tasks, such as performing single file modifications, creating or deleting single files.

Figure 2: FileModifier Interface

To set up your environment, first ensure you have at least PowerShell 4.0 installed. In order to run the FileModifier as well as FakeSmtp you will further require the Java Runtime Environ- ment (`https://www.java.com/en/download/manual.jsp`) version 7  or  higher  (but  you  would  want to use the latest version available if possible). It is already installed on OP student desktops, so you can just double-click the ‘FileModifier.jar’ and ‘FakeSmtp-2.0.jar’ and they should launch.

The provided FileModifier will produce a file system structure that is to be backed up using Robocopy, which produces a logfile. Your PowerShell script will periodically query this logfile and check for added or deleted files. If such changes have happened, it will send an e-mail containing an overview of those changes and write those to the Windows Event log. Your work thus consists of multiple stages, with the initial task of setting up the FileModifier and configure Robocopy. (Note that the configuration of Robocopy is part of your submission! More on that at the end of the document.)

Set up the project file system structure, with ‘C:\IN609_OE1’ as the base directory (but it should be easily configurable in your code). The FileModifier will work in whatever directory it is started from. To separate the logfile from the actual file system, create a subfolder called ‘Files’ and save the FileModifier in that folder. The structure should thus appear as shown in Figure 4.  It is good practice to identify file paths as variables and store those at a single location in your code, so they can be easily changed (e.g. from C: to D:, change in pathnames, etc.).

Start the FileModifier and run it in ‘Live Mode’ for a few minutes. You will see that it incrementally builds up a folder structure as well as files within the ‘Files’ subfolder. It randomly adds, deletes and modifies files within that folder structure. You can delete the generated files at any time and start over.

Document your code. You will need to do that as part of the assignment anyway, so it would be best to do it from the beginning in order to remember what the individual statements or sections do. Especially in more complex projects this is very important. Look at the Tutorials.

If you see errors, interpret them, don’t just give up because you are seeing ‘red’! Not all errors give you meaningful information, but they often contain a hint what code section caused the error. This is generally a good starting point for investigation. If you really get stuck, let me know and we try to solve the issue.

Generally, external resources, such as file system, e-mail, etc. can be error sources in them- selves. When dealing with file systems, insufficient permissions is a problem to think about, since the script may be executed with different permissions by different users. (In the first PowerShell lab we used the ‘-ErrorAction’ parameter to deal with those cases.)

## Testing

Test your results carefully. Your code is supposed to be generic and pretty much run on any Windows machine (with minor configuration adjustments, such as folder names). Think about possible side effects that could affect your setup, such as

- the deletion of the logfile during operation,
- the setup on different machines,
- failure of services, changing the location of the backup location in the script. (Changing the backup location should only require a single change in your PowerShell script!)

**Deadline
The submission is due   Wednesday, 1 September 2021, 11;59pm.**

## Submission Instructions

In addition to the tasks outlined above you will further complete a self-assessment on the marking sheet and indicate the tasks you completed (see column ‘Completed’) and may leave ‘Self-assessment Comments’ regarding your progress (e.g. if you did not complete a task or are unsure).

You will need to hand in this sheet in addition to your zip file. Please submit the zip file on the teams assignment tab before the deadline.
