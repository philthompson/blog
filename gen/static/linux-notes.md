
[//]: # (gen-title: Linux Notes - philthompson.me)

[//]: # (gen-keywords: linux, command, line, tips, terminal)

[//]: # (gen-description: A collection of bash and other snippets")

[//]: # (gen-meta-end)

This is a "cheat sheet" style collection of bash and other snippets, mainly for myself to refer to.

## General / Local System Administration

#### find common/different lines in two files

	# show only lines in file2 that are not in file1
	$ comm -1 -3 <(sort -u file1.txt) <(sort -u file2.txt)

	# show only lines in file1 that are not in file2
	$ comm -2 -3 <(sort -u file1.txt) <(sort -u file2.txt)

	# show only lines in both
	$ comm -1 -2 <(sort -u file1.txt) <(sort -u file2.txt)

#### pipe to/from clipboard

	# MacOS
	$ somecmd | pbcopy
	$ pbcopy < somefile

	$ pbpaste | somecmd
	$ pbpaste > somefile

	# Ubuntu
	$ sudo apt-get install xclip
	$ somecmd | xclip -selection clipboard

#### see lifetime data written to SSD

	# MacOS
	$ brew install smartmontools && sudo smartctl —all /dev/disk0

#### see disk capacity usage

	# MacOS
	$ diskutil info `diskutil list | grep "<VolumeName>" | tr ' ' '\n' | grep "^disk"` | grep "Space\|Identifier\|Mount"

#### restart ubuntu menu to get clock to appear
	
	$ sudo killall unity-panel-service

#### Generate N random characters:

	# restrict chars to listed ranges
	$ LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32 ; echo

#### Find large files:

	$ find / -xdev -type f -size +100M

#### rsync with SSH key (passphrase-protected key won't work):

	$ rsync -vPz -e 'ssh -i /full/path/to/key' /local/file user@host:/remote/location/

#### quick ps listing for java:

	$ ps ax | grep '[j]ava' | cut -c -100


#### find command in history

	# use Ctrl+R then start typing any portion of the command

#### hash a password

	$ mkpasswd -m SHA-256 [-S testsalt] [testpassw0rd]

#### remove old kernels from boot partition on ubuntu 14.04

	# reboot (if you have may downloaded a newer kernal since rebooting)
	$ uname -r (do not remove this one...)
	$ sudo dpkg --list 'linux-image*' | awk '{ if ($1=="ii") print $2}' | grep -v `uname -r`
	$ sudo apt-get purge <linux-image-...-from-above> (repeat for each to remove)
	$ sudo update-grub2 
	# reboot (optional)

#### remove old kernels from boot partition on ubuntu 16.04 or later

	$ sudo apt-get autoremove

#### In-line g-un-zipping of file content

	# linux
	$ zcat <file> | ...

	# MacOS (thanks to https://serverfault.com/a/704521/152493)
	$ gunzip -c <file> | ...


## Network

#### Run webserver from a directory

	# python 2.7, serve on port 8080
	$ python -m SimpleHTTPServer 8080

#### Port forward remote port 443 to local port 1443 through SSH:

	$ ssh -L 1443:<host1>:443 username@<host2>

#### SSH ignoring server-set inactivity timeouts (breaks some apps if used with port forwarding)

	$ ssh -o "ServerAliveInterval 60" -o "ServerAliveCountMax 1" username@host

#### Watch for packets:

	$ sudo tcpdump -nni eth0 port 8443
	$ sudo tcpdump -vvnni ens3 port 8140

#### list listening ports

	$ sudo netstat -atunp
	$ sudo ss -ltnp # listening tcp sockets ; use -lunp to list listening udp sockets

#### set up tunnels to remote IPMI hostA web (80) and remote console

	$ for SOMEPORT in 123 456 789; do sudo ssh -q -fN -L $SOMEPORT:<hostA>:$SOMEPORT you@<hostB-that-can-access-hostA>; done


## Git

#### branches

	# what does --track do?
	$ git checkout --track origin/development
	$ git checkout development

#### new branch

	$ git checkout -b new_branch [from-branch]

#### push new branch to origin

	# i always use -u here... any reason to not use -u?
	$ git push -u origin new_branch

#### two steps to merge a "development" branch into "master"

	$ git checkout master
	$ git merge --no-ff development

#### Wipe local changes to sync with remote:

	$ cd ~/some/repo
	$ git fetch --all
	$ git reset --hard origin/development

#### Create local mirror of repo

	$ git checkout master # checkout master branch in source repo
	$ cd /path/to/mirror
	$ git clone --mirror /path/to/source-proj

#### Update mirror repo

	$ cd /path/to/source-proj
	$ git push --mirror /path/to/mirror/source-proj.git

#### create tag for current commit

	$ git tag -m "message for the tag" "tag-name"
	$ git push origin --tags

#### brief list of changes

	$ git show --name-status [<commit>]

#### "squash" last 3 commits

	$ git rebase -i HEAD~3


## Maven

#### Run package without tests:

	$ mvn clean package -Dmaven.test.skip=true

#### find where a dependency is coming from

	$ mvn dependency:tree -Dincludes=groupid:artifactid
