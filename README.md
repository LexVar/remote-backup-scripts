# Duplicity backup scripts

Two backup scripts to backup encrypted or plain directories to remote location.
Configuration files to backup directories using anacron called from a cron job are included.
Duplicity supports multiple remote location types, in this example rclone is used.

## Usage

Remote encrypted backups:
> remote-encrypt-backup \<backup-code\> \<source\> \<target\> \<backup-frequency\>

Remote plaintext backups:
> remote-plain-backup \<backup-code\> \<source\> \<target\>

- backup-code is the code of the directory to backup, only used for logging.
- source and target specify the source directory and remote target.
- For encrypted backups, the backup frequency of full backups can be specified. All other times, incremental backups are performed.

Passphrases for encrypted backups are fetched from kwallet manager which needs to be unlocked.

Both scripts log the result to their log files, and email through a configured ssmtp mailhub, to the user's email, when a backup finishes with errors.

## Configuration

The anacron directory `.anacron` can be moved to the user's home directory. The anacrontab file lists the backup jobs, how often they should be executed and at what times.

Anacron is run every hour to check if updates are up to date, and run them if not. This line can be added to the user's crontab, with `crontab -e`, assuming the anacron directory structure is the same as this repo.

> @hourly /usr/sbin/anacron -s -t $HOME/.anacron/etc/anacrontab -S $HOME/.anacron/spool

## Tools
- duplicity version 0.8.18
- rclone v1.53.3-DEV
- crontab, anacron version 1.5.5-4
- kwallet version 20.08.1-1
- ssmtp 2.64-25
