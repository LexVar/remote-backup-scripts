#!/bin/bash

# duplicity --no-encryption /home/avalente/Documents/KeePass rclone://remote:KeePass >> /var/log/duplicity/keepass.log

# Check for the number of arguments
if [ $# != 3 ]; then
	echo "Usage: remote-backup <backup-code> <source> <target>"
	exit 1
fi

MAILTO="avalente@protonmail.com"
CODE=$1
SOURCE=$2
TARGET=$3

export DISPLAY=:0

export MAIL_PASSPHRASE=`kwallet-query kdewallet -f Passwords -r mail-password`
export MAIL_SENDER=`kwallet-query kdewallet -f Passwords -r mail-sender`

# Backup directory
rclone sync -L --exclude '*.' $SOURCE $TARGET #>> /var/log/duplicity/$CODE.log 2>&1
if [ $? != 0 ]; then
	MESSAGE="Error code: $?. $(date +'%d %b %Y %H:%M')-- Error performing the remote $SOURCE backup."

	# Send mail to $MAILTO
	printf "Subject: Error performing the $CODE backup.\n\n" > /tmp/mail.dup
	echo $MESSAGE >> /tmp/mail.dup
	printf "\n\n------------------------------\n\n" >> /tmp/mail.dup
	tail -n 100 /var/log/duplicity/$CODE.log >> /tmp/mail.dup

	ssmtp -au $MAIL_SENDER -ap $MAIL_PASSPHRASE $MAILTO < /tmp/mail.dup

else
	MESSAGE="$(date +'%d %b %Y %H:%M')-- Finished execution of remote $SOURCE backup."
fi

#kdeconnect-cli -n HONOR --send-sms "$MESSAGE" --destination $PHONE_NUMBER
echo $MESSAGE >> /var/log/duplicity/$CODE.log 2>&1
# notify-send -u normal "Remote $CODE Backup" $MESSAGE -t 15000

# Unsetting the confidential variables so they are gone for sure.
unset PASSPHRASE
unset MAIL_PASSPHRASE
unset MAIL_SENDER

exit 0
