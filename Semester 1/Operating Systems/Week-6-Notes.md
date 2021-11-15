# Week 6 Notes

> single greater than overwrites the file content with the current command output
>> double GT appends to the file content the output of the current command

Move cursor to the: 
`w` By word
`e` end of word
`x` deletes from current cursor position


$ uname -r

Sample outputs:

4.15.0-39-generic
So my Linux kernel version is 4.15.0-39, where:

4 : Kernel version
15 : Major revision
0 : Minor revision
39 : Patch level or number
generic : Linux distro/kernel specific additional info

-a, OR --all	print all information
-s, OR --kernel-name	print the kernel name
-n, OR --nodename	print the network node hostname
-r, OR --kernel-release	print the Linux kernel release
-v, OR --kernel-version	print the kernel version
-m, OR --machine	print the machine hardware name
-p, OR --processor	print the processor type or “unknown”
-i, OR --hardware-platform	print the hardware platform or “unknown”
-o, OR --operating-system	print the operating system
