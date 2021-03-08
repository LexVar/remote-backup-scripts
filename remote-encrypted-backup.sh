#!/bin/bash
#
# This script was created to make Duplicity backups.
# Full backups are done once every 3 months.
# Then incremental backups are made on the other days.

# Check for the number of arguments
if [ $# != 4 ]; then
	echo "Usage: remote-backup <backup-code> <source> <target> <backup-frequency>"
	exit 1
fi

CODE=$1
SOURCE=$2
TARGET=$3
FREQUENCY=$4

# Flags to exclude some dotfiles
if [ $CODE == "dotfiles" ]; then
	FLAGS=" --exclude **/home/avalente/.cache/** \
		--exclude **/home/avalente/.gem/** \
		--exclude **/home/avalente/.local/share/lutris/** \
		--exclude **/home/avalente/.local/lib/** \
		--exclude **/home/avalente/.wine/** \
		--exclude **/home/avalente/.local/share/libvirt/** \
		--exclude **/home/avalente/.local/share/baloo/** \
		--exclude **/home/avalente/.local/share/Steam/** \
		--exclude **/home/avalente/.local/share/vocal/** \
		--exclude **/home/avalente/.vagrant.d/** \
		--include **/home/avalente/.** \
		--exclude **\*"
elif [ $CODE == "documents" ]; then
	FLAGS=" --exclude **/home/avalente/Documents/LEI** \
		--exclude **/home/avalente/Documents/SSE-Drones**"

else
	unset FLAGS
fi

# Variable to define the xorg session
export DISPLAY=:0

# Setting the passphrase to encrypt the backup files.
# Get the passphrase from kwallet.
export PASSPHRASE=`kwallet-query kdewallet -f Passwords -r $CODE`

# E-mail
export MAILTO="avalente@protonmail.com"
export MAIL_PASSPHRASE=`kwallet-query kdewallet -f Passwords -r mail-password`
export MAIL_SENDER=`kwallet-query kdewallet -f Passwords -r mail-sender`

# Backup files
# duplicity --dry-run --verbosity 8 --allow-source-mismatch --full-if-older-than $FREQUENCY $FLAGS $SOURCE $TARGET
# duplicity full $FLAGS $SOURCE $TARGET
duplicity --full-if-older-than $FREQUENCY $FLAGS $SOURCE $TARGET >> /var/log/duplicity/$CODE.log 2>&1

if [ $? != 0 ]; then
	MESSAGE="Error code: $?. $(date +'%d %b %Y %H:%M')-- Error performing the $CODE backup."

	printf "Subject: Error performing the $CODE backup.\n\n" > /tmp/mail.dup
	echo $MESSAGE >> /tmp/mail.dup
	printf "\n\n------------------------------\n\n" >> /tmp/mail.dup
	tail -n 100 /var/log/duplicity/$CODE.log >> /tmp/mail.dup

	ssmtp -au $MAIL_SENDER -ap $MAIL_PASSPHRASE $MAILTO < /tmp/mail.dup
else
	MESSAGE="$(date +'%d %b %Y %H:%M')-- Finished execution of remote $CODE backup."
fi

echo $MESSAGE >> /var/log/duplicity/$CODE.log 2>&1

notify-send -u normal "Remote $CODE Backup" $MESSAGE -t 15000

# Deleting old backups - 6 months
duplicity remove-older-than 3M \
	--force \
	$TARGET >> /var/log/duplicity/$CODE.log 2>&1

# Unsetting the confidential variables so they are gone for sure.
unset PASSPHRASE
unset MAIL_PASSPHRASE
unset MAIL_SENDER

exit 0
