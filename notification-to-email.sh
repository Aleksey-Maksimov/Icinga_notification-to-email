#!/bin/sh
#
# Script for email notifications (HTML format) for Icinga 
# Tested on Debian GNU/Linux 8.7 (Jessie) with Icinga r2.6.2-1 
# Put here /etc/icinga2/scripts/notification-to-email.sh 
# Aleksey Maksimov <aleksey.maksimov@it-kb.ru>
#
PLUGIN_NAME="Plugin for email notifications (HTML format) for Icinga Director"
PLUGIN_VERSION="2017.09.27"
PRINTINFO=`printf "\n%s, version %s\n \n" "$PLUGIN_NAME" "$PLUGIN_VERSION"`
#
#
Usage() {
  echo "$PRINTINFO"
  echo "Usage: $0 [OPTIONS]

Option   GNU long option         Meaning
------   ---------------	 -------
 -M      --plugin-mode           Plugin mode. Static value. Possible values: host-mode|service-mode
 -a      --notification-type	 Icinga Notification type (for example, from a variable \$notification.type\$)
 -b      --notification-autor	 Icinga Notification autor (for example, from a variable \$notification.author\$)
 -c      --notification-comment  Icinga Notification comment (for example, from a variable \$notification.comment\$)
 -d      --long-datetime	 Icinga Notification date and time (for example, from a variable \$icinga.long_date_time\$)
 -e      --host-displayname	 Icinga Host name (for example, from a variable \$host.display_name\$)
 -f      --host-alias		 Icinga Host alias (for example, from a variable \$host.name\$)
 -g      --host-address		 Icinga Host address (for example, from a variable \$address\$)
 -h      --host-state		 Icinga Host last state (for example, from a variable \$host.state\$)
 -i      --host-output		 Icinga Host monitoring plugin output (for example, from a variable \$host.output\$)
 -j      --service-displayname   Icinga Service display name (for example, from a variable \$service.display_name\$)
 -k      --service-desc		 Icinga Service alias (for example, from a variable \$service.name\$)
 -l      --service-state	 Icinga Service last state (for example, from a variable \$service.state\$ )
 -m      --service-output	 Icinga Service monitoring plugin output (for example, from a variable \$service.output\$)
 -n      --mail-to		 Email address for "To:" header (for example, from a variable \$user.email\$)
 -o      --mail-from		 Email address for "From:" header. Static value (for example, Icinga@mycorp.com)
 -z      --item-comment		 Additional item comment with custom variable from Host or Service (for example, from a variable \$host.Notification_Comment\$)
 -p      --icingaweb-url	 Icinga Web URL for link to Host or Service. Static value (for example, http://icinga.mycorp.com/icingaweb2/monitoring)
 -q      --help                  Show this message
 -v      --version		 Print version information and exit

"
}
#
# Parse arguments
#
OPTS=`getopt -o M:a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:z:p:qv -l plugin-mode:,notification-type:,notification-autor:,notification-comment:,long-datetime:,host-displayname:,host-alias:,host-address:,host-state:,host-output:,service-displayname:,service-desc:,service-state:,service-output:,mail-to:,mail-from:,item-comment:,icingaweb-url:,help,version -- "$@"`
eval set -- "$OPTS"
while true; do
        case $1 in
                -M|--plugin-mode)
      			case "$2" in
                        "host-mode"|"service-mode") PLUGINMODE=$2 ; shift 2 ;;
                                                 *) printf "Unknown value for option %s. Use 'host-mode' or 'service-mode'\n" "$1" ; exit 1 ;;
			esac ;;
                -a|--notification-type)
                        NOTIFICATIONTYPE=$2 ; shift 2 ;;
                -b|--notification-autor)
                        NOTIFICATIONAUTHORNAME=$2 ; shift 2 ;;
                -c|--notification-comment)
                        NOTIFICATIONCOMMENT=$2 ; shift 2 ;;
                -d|--long-datetime)
                        LONGDATETIME=$2 ; shift 2 ;;
                -e|--host-displayname)
                        HOSTDISPLAYNAME=$2 ; shift 2 ;;
                -f|--host-alias)
                        HOSTALIAS=$2 ; shift 2 ;;
                -g|--host-address)
                        HOSTADDRESS=$2 ; shift 2 ;;
                -h|--host-state)
                        HOSTSTATE=$2 ; shift 2 ;;
                -i|--host-output)
                        HOSTOUTPUT=$2 ; shift 2 ;;
                -j|--service-displayname)
                        SERVICEDISPLAYNAME=$2 ; shift 2 ;;
                -k|--service-desc)
                        SERVICEDESC=$2 ; shift 2 ;;
                -l|--service-state)
                        SERVICESTATE=$2 ; shift 2 ;;
                -m|--service-output)
                        SERVICEOUTPUT=$2 ; shift 2 ;;
                -n|--mail-to)
                        MAILTO=$2 ; shift 2 ;;
                -o|--mail-from)
                        MAILFROM=$2 ; shift 2 ;;
                -z|--item-comment)
                        ITEMCOMMENT=$2 ; shift 2 ;;
                -p|--icingaweb-url)
                        ICINGAWEBURL=$2 ; shift 2 ;;
                -q|--help)
                        Usage ; exit 0 ;;
                -v|--version)
			echo "$PRINTINFO" ; exit 0 ;;
                --)
                        # no more arguments to parse
                        shift ; break ;;
                *)
                        printf "\nUnrecognized option %s\n\n" "$1" ; Usage ; exit 1 ;;
        esac 
done
#
#
TIMETOMAIL=`echo $(date -d "$LONGDATETIME" +"%d.%m.%Y %T %Z")`
SERVICETOMAIL=`echo $SERVICEDESC | sed 's/ /%20/g'`
#
#
ITEMCOMMENTTOMAIL=""
if [ -n "$ITEMCOMMENT" ]; then ITEMCOMMENTTOMAIL=`cat <<EOT
<p><table><tbody>
<tr>
  <td width="125">Item comment:</td><td>$ITEMCOMMENT</td>
</tr>
</tbody></table></p>
EOT
`
fi
#
#
COMMENTTOMAIL=""
if [ -n "$NOTIFICATIONAUTHORNAME" ]; then COMMENTTOMAIL=`cat <<EOT
<p><table><tbody>
<tr>
  <td width="125">Comment:</td><td>$NOTIFICATIONAUTHORNAME</td><td>$NOTIFICATIONCOMMENT</td>
</tr>
</tbody></table></p>
EOT
`
fi
#
#
if [ "$PLUGINMODE" = "host-mode" ]; then
	#
	MAILSUBJECT=`echo Icinga $NOTIFICATIONTYPE alert - $HOSTDISPLAYNAME is $HOSTSTATE`
	#
	BACKGROUND=#C9C9C9
	if [ "$HOSTSTATE" = "UP" ]; then
		BACKGROUND=#C7E1D6
	elif [ "$HOSTSTATE" = "DOWN" ]; then
	        BACKGROUND=#F7DFDF
	elif [ "$HOSTSTATE" = "UNREACHABLE" ]; then
	       BACKGROUND=`#CDD5E0`
	fi
	#
	#
template=`cat <<TEMPLATE
<html>
<head><style>
 BODY{font-family: Arial; font-size: 9pt;}
 TABLE{border: 1px solid #eeeeee; border-collapse: collapse;}
 TH{border: 1px solid #eeeeee; background: $BACKGROUND; padding: 10px; }
 TD{border: 1px solid #eeeeee; padding: 5px; }
</style></head>
<body>
<p><table><tbody>
<tr>
  <th colspan="2" align="center">Icinga $NOTIFICATIONTYPE Notification</th>
</tr>
<tr>
  <td width="125">Host:</td><td><strong>$HOSTDISPLAYNAME</strong></td>
</tr>
<tr>
  <td width="125">Description:</td><td><strong>$HOSTOUTPUT</strong></td>
</tr>
<tr>
  <td width="125">Host State:</td><td>$HOSTSTATE</td>
</tr>
<tr>
  <td width="125">FQDN:</td><td>$HOSTALIAS</td>
</tr>
<tr>
  <td width="125">Address:</td><td>$HOSTADDRESS</td>
</tr>
<tr>
  <td width="125">Raised Time:</td><td>$TIMETOMAIL</td>
</tr>
</tbody></table></p>
<br>$ITEMCOMMENTTOMAIL
<br>$COMMENTTOMAIL
<p><a href=$ICINGAWEBURL/host/show?host=$HOSTALIAS>Icinga Host view link</a></p>
</body>
</html>
TEMPLATE
`
	#
	#
elif [ "$PLUGINMODE" = "service-mode" ]; then
	#
	MAILSUBJECT=`echo Icinga $NOTIFICATIONTYPE alert - $HOSTDISPLAYNAME - $SERVICEDISPLAYNAME is $SERVICESTATE`
	#
	BACKGROUND=#C9C9C9
	if [ "$SERVICESTATE" = "OK" ]; then
        	BACKGROUND=#C7E1D6
	elif [ "$SERVICESTATE" = "WARNING" ]; then
        	BACKGROUND=#FEEAC7
	elif [ "$SERVICESTATE" = "CRITICAL" ]; then
        	BACKGROUND=#F7DFDF
	elif [ "$SERVICESTATE" = "UNKNOWN" ]; then
       		BACKGROUND=`#CDD5E0`
	fi
	#
	template=`cat <<TEMPLATE
<html>
<head><style>
 BODY{font-family: Arial; font-size: 9pt;}
 TABLE{border: 1px solid #eeeeee; border-collapse: collapse;}
 TH{border: 1px solid #eeeeee; background: $BACKGROUND; padding: 10px; }
 TD{border: 1px solid #eeeeee; padding: 5px; }
</style></head>
<body>
<p><table><tbody>
 <tr>
   <th colspan="2" align="center">Icinga $NOTIFICATIONTYPE Notification</th>
 </tr>
 <tr>
   <td width="125">Service:</td><td><strong>$SERVICEDESC</strong></td>
 </tr>
 <tr>
   <td width="125">Description:</td><td><strong>$SERVICEOUTPUT</strong></td>
 </tr>
 <tr>
   <td width="125">Service State:</td><td>$SERVICESTATE</td>
 </tr>
 <tr>
   <td width="125">Host:</td><td>$HOSTALIAS</td></tr>
 <tr>
   <td width="125">Address:</td><td>$HOSTADDRESS</td>
 </tr>
 <tr>
   <td width="125">Raised Time:</td><td>$TIMETOMAIL</td>
 </tr>
</tbody></table></p>
<br>$ITEMCOMMENTTOMAIL
<br>$COMMENTTOMAIL
<p><a href=$ICINGAWEBURL/service/show?host=$HOSTALIAS&amp;service=$SERVICETOMAIL>Icinga Service view link</a></p>
</body>
</html>
TEMPLATE
`
	#
	#
fi
#
# Send email
#
/usr/bin/printf "%b" "$template" | mail \
-a "From: $MAILFROM" \
-a 'Content-Type: text/html; charset="utf-8"' \
-s "$MAILSUBJECT" \
$MAILTO
#
#
#
#
# TO DO
#
# 1. Add charset fir headers From, To, Subject
# $VARB64 = ( echo -n $VAR | base64 )
# Subject =?utf-8?B?$VARB64?=
#
#
#
#
