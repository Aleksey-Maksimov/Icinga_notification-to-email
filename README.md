## About

**notification-to-email** - Script for email notifications (Host and Service) in HTML format for Icinga.  

Tested on **Debian GNU/Linux 8.7 (Jessie)** with **Icinga r2.6.2-1**

Put here /etc/icinga2/scripts/notification-to-email.sh 
 
## Usage

Options:

```
$./notification-to-email.sh [OPTIONS]

Option  GNU long option         Meaning
------  ---------------	        -------
-M      --plugin-mode           Plugin mode. Static value. 
                                Possible values: host-mode|service-mode
-a      --notification-type     Icinga Notification type 
                                (for example, from a variable \$notification.type\$)
-b      --notification-autor    Icinga Notification autor 
                                (for example, from a variable \$notification.author\$)
-c      --notification-comment  Icinga Notification comment 
                                (for example, from a variable \$notification.comment\$)
-d      --long-datetime         Icinga Notification date and time 
                                (for example, from a variable \$icinga.long_date_time\$)
-e      --host-displayname      Icinga Host name 
                                (for example, from a variable \$host.display_name\$)
-f      --host-alias            Icinga Host alias (for example, from a variable \$host.name\$)
-g      --host-address          Icinga Host address (for example, from a variable \$address\$)
-h      --host-state            Icinga Host last state (for example, from a variable \$host.state\$)
-i      --host-output           Icinga Host monitoring plugin output 
                                (for example, from a variable \$host.output\$)
-j      --service-displayname   Icinga Service display name 
                                (for example, from a variable \$service.display_name\$)
-k      --service-desc          Icinga Service alias (for example, from a variable \$service.name\$)
-l      --service-state         Icinga Service last state 
                                (for example, from a variable \$service.state\$ )
-m      --service-output        Icinga Service monitoring plugin output 
                                (for example, from a variable \$service.output\$)
-n      --mail-to               Email address for "To:" header 
                                (for example, from a variable \$user.email\$)
-o      --mail-from             Email address for "From:" header. 
                                Static value (for example, Icinga@mycorp.com)
-p      --icingaweb-url         Icinga Web URL for link to Host or Service. Static value 
                                (for example, http://icinga.mycorp.com/icingaweb2/monitoring)
-q      --help                  Show this message
-v      --version               Print version information and exit


```

Icinga Director integration manual (in Russian):

[Развёртывание и настройка Icinga 2 на Debian 8.6. Часть 9. Настройка e-mail оповещений в Icinga Director 1.3](https://blog.it-kb.ru/2017/03/02/deploy-and-configure-icinga-2-on-debian-8-part-9-icinga-director-1-3-and-email-notification-with-plugin-command-and-custom-shell-script-with-additional-arguments/)
