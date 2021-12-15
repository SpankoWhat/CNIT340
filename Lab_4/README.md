In this laboratory you will build backup and restore scripts that back up directories and manage the backup files. Backup files will be stored in a target filesystem that in production would be a remotely mounted. The backup script should handle the creation and rotation of backup files based on the content of a configuration file. The restore script will be considerably simpler, merely requiring the user to select a backup to restore and verify the operation before restoring the files.

Operation:
- The backup script will recursively backup a directory based on the content of a configuration file o The format for the configuration file is provided in the attached file (please save it as /etc/backup.conf).
- The backup script will be executed from the command line in the form: backup name o Where name corresponds to an entry in /etc/backup.conf
- The backup script can operate manually or automatically (by adding an entry in crontab) 
- The restore script will prompt the user for the filesystem to restore and a restore target o The user must verify directory/file overwrites
- To backup and restore privileged files the scripts must be able to run as root
