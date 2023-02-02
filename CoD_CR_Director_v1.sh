#!/bin/bash
# $Header: CR_Director.sh
#######################################################################
# Copyright:       All Rights Reserved.
#                  This material is confidential and a trade secret.
#                  Permission to use this work for any purpose must be
#                  obtained in writing from: Mavenir Systems USA
# $Author: Security TEAM$, Sanjay Menon, William Ye
# $Revision: 0.0.3 $
# 07/01/2020: adding first set of script elements
# 07/06/2020: adding more script items
# 07/09/2020: finished all items
# 07/10/2020: added section for audit.rules and saving existing config files
# 07/13/2020: added restore and help feature
# 07/20/2020: added various missing items
# 07/21/2020: added 7:2:6, 7:2:9 in audit section, added 7:2:1
# 07/22/2020: modified 7:6:5, 7:2:14, 7:2:18
######################################################################
cwd=$(dirname "$(readlink -f "$0")")

restore()
{
  echo "---Restore from backup started"
  echo 
  # Restore config files
  [ -f /etc/ssh/sshd_config.sv ] && \mv -f /etc/ssh/sshd_config.sv /etc/ssh/sshd_config
  [ -f /etc/pam.d/password-auth-ac.sv ] && \mv -f /etc/pam.d/password-auth-ac.sv /etc/pam.d/password-auth-ac
  [ -f /etc/pam.d/system-auth-ac.sv ] && \mv -f /etc/pam.d/system-auth-ac.sv /etc/pam.d/system-auth-ac
  [ -f /etc/audit/rules.d/audit.rules.sv ] && \mv -f /etc/audit/rules.d/audit.rules.sv /etc/audit/rules.d/audit.rules
  [ -f /etc/sysctl.conf.sv ] && \mv -f /etc/sysctl.conf.sv /etc/sysctl.conf
  [ -f /etc/login.defs.sv ] && \mv -f /etc/login.defs.sv /etc/login.defs
  [ -f /etc/default/grub.sv ] && \mv -f /etc/default/grub.sv /etc/default/grub
  [ -f /boot/grub2/grub.cfg.sv ] && \mv -f /boot/grub2/grub.cfg.sv /boot/grub2/grub.cfg
  [ -f /etc/security/pwquality.conf.sv ] && \mv -f /etc/security/pwquality.conf.sv /etc/security/pwquality.conf
  [ -f /etc/fstab.sv ] && \mv -f /etc/fstab.sv /etc/fstab
  [ -f /etc/logrotate.d/syslog.sv ] && \mv -f /etc/logrotate.d/syslog.sv /etc/logrotate.d/syslog
  
  # Restore password related files
  [ -f /etc/passwd.sv ] && \mv -f /etc/passwd.sv /etc/passwd
  [ -f /etc/shadow.sv ] && \mv -f /etc/shadow.sv /etc/shadow
  [ -f /etc/group.sv ] && \mv -f /etc/group.sv /etc/group
  [ -f /etc/gshadow.sv ] && \mv -f /etc/gshadow.sv /etc/gshadow
  [ -f /etc/passwd-.sv ] && \mv -f /etc/passwd-.sv /etc/passwd-
  [ -f /etc/shadow-.sv ] && \mv -f /etc/shadow-.sv /etc/shadow-
  [ -f /etc/group-.sv ] && \mv -f /etc/group-.sv /etc/group-
  [ -f /etc/gshadow-.sv ] && \mv -f /etc/gshadow-.sv /etc/gshadow-
  
  # Restore cron related files
  [ -f /etc/cron.monthly.sv ] && \mv -f /etc/cron.monthly.sv /etc/cron.monthly
  [ -f /etc/cron.weekly.sv ] && \mv -f /etc/cron.weekly.sv /etc/cron.weekly
  [ -f /etc/crontab.sv ] && \mv -f /etc/crontab.sv /etc/crontab
  [ -f /var/log/cron.sv ] && \mv -f /var/log/cron.sv /var/log/cron

  [ -f /etc/cron.deny.sv ] && \mv -f /etc/cron.deny.sv /etc/cron.deny
  [ -f /etc/at.deny.sv ] && \mv -f /etc/at.deny.sv /etc/at.deny
  [ -f /etc/cron.allow.sv ] && \mv -f /etc/cron.allow.sv /etc/cron.allow
  [ -f /etc/at.allow.sv ] && \mv -f /etc/at.allow.sv /etc/at.allow
  [ -f /etc/anacrontab.sv ] && \mv -f /etc/anacrontab.sv /etc/anacrontab

  [ -f /etc/cron.d.sv ] && \mv -f /etc/cron.d.sv /etc/cron.d
  [ -f /etc/cron.daily.sv ] && \mv -f /etc//etc/cron.daily.sv /etc/cron.daily
  [ -f /etc/cron.hourly.sv ] && \mv -f /etc/cron.hourly.sv /etc/cron.hourly

  [ -f /etc/motd.sv ] && \mv -f /etc/motd.sv /etc/motd
  [ -f /etc/issue.sv ] && \mv -f /etc/issue.sv /etc/issue
  [ -f /etc/issue.net.sv ] && \mv -f /etc/issue.net.sv /etc/issue.net

  [ -f /etc/rsyslog.d/hpov.conf.sv ] && \cp /etc/rsyslog.d/hpov.conf.sv /etc/rsyslog.d/hpov.conf
  [ -f /etc/rsyslog.conf.sv ] && \cp /etc/rsyslog.conf.sv /etc/rsyslog.conf

  [ -f $cwd/crontab.sv ] && crontab -u root $cwd/crontab.sv

  # Remove grub2 password file if exists
  [ -f /boot/grub2/user.cfg ] && \rm -f /boot/grub2/user.cfg
  
  # Fallback to earlier audit rules
  chmod 640 /etc/audit/rules.d/audit.rules
  # The following might fail if "-e 2" is set in auditd.rules_vil, which prevents changes in memory unless after reboot 
  auditctl -R /etc/audit/rules.d/audit.rules
  
  grub2-mkconfig -o /boot/grub2/grub.cfg
  systemctl restart sshd
  sysctl -p
  sysctl -w net.ipv4.route.flush=1
  sysctl -w net.ipv6.route.flush=1
 
  echo 
  echo "---Restore from backup completed"
}

usage() 
{
  echo "usage: `basename $0`' 
                   --restore        : restores configuration files from backup
                   --help           : print usage info'"
}

################################################### MAIN ################################################

while [ "$1" != "" ]; do
    case $1 in
         --restore ) 
                echo "Starting Rollback ..."
                echo
                restore
                echo
                echo "Rollback completed"
                exit 0
                ;;
         --help )
                usage
                exit
                ;;
         * )    
                echo "Error: Invalid Option"
                usage
                exit 1
    esac
    shift
done


echo "--Script CR_Director.sh started"

echo
echo "---Saving exiting config files ..."
\cp -Rpf /etc/ssh/sshd_config /etc/ssh/sshd_config.sv
\cp -Rpf /etc/pam.d/password-auth-ac /etc/pam.d/password-auth-ac.sv
\cp -Rpf /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.sv
[ -f /etc/audit/rules.d/audit.rules ] && \cp -Rpf /etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules.sv
\cp -Rpf /etc/sysctl.conf /etc/sysctl.conf.sv
\cp -Rpf /etc/default/grub /etc/default/grub.sv
\cp -Rpf /boot/grub2/grub.cfg /boot/grub2/grub.cfg.sv
\cp -Rpf /etc/security/pwquality.conf /etc/security/pwquality.conf.sv
\cp -Rpf /etc/login.defs /etc/login.defs.sv
\cp -Rpf /etc/fstab /etc/fstab.sv
\cp -Rpf /etc/logrotate.d/syslog /etc/logrotate.d/syslog.sv

\cp -Rpf /etc/passwd /etc/passwd.sv
\cp -Rpf /etc/shadow /etc/shadow.sv
\cp -Rpf /etc/group /etc/group.sv
\cp -Rpf /etc/gshadow /etc/gshadow.sv
\cp -Rpf /etc/passwd- /etc/passwd-.sv
\cp -Rpf /etc/shadow- /etc/shadow-.sv
\cp -Rpf /etc/group- /etc/group-.sv
\cp -Rpf /etc/gshadow- /etc/gshadow-.sv

\cp -Rpf /etc/cron.monthly /etc/cron.monthly.sv
\cp -Rpf /etc/cron.weekly /etc/cron.weekly.sv
\cp -Rpf /etc/crontab /etc/crontab.sv
[ -f /var/log/cron ] && \cp -Rpf /var/log/cron /var/log/cron.sv

[ -f /etc/cron.deny ] && \cp /etc/cron.deny /etc/cron.deny.sv
[ -f /etc/at.deny ] && \cp /etc/at.deny /etc/at.deny.sv
[ -f /etc/cron.allow ] && \cp /etc/cron.allow /etc/cron.allow.sv
[ -f /etc/at.allow ] && \cp /etc/at.allow /etc/at.allow.sv
[ -f /etc/anacrontab ] && \cp /etc/anacrontab /etc/anacrontab.sv

\cp -Rpf /etc/cron.d /etc/cron.d.sv
\cp -Rpf /etc/cron.daily /etc/cron.daily.sv
\cp -Rpf /etc/cron.hourly /etc/cron.hourly.sv

[ -f /etc/motd ] && \cp /etc/motd /etc/motd.sv
[ -f /etc/issue ] && \cp /etc/issue /etc/issue.sv
[ -f /etc/issue.net ] && \cp /etc/issue.net /etc/issue.net.sv

[ -f /etc/rsyslog.d/hpov.conf ] && \cp /etc/rsyslog.d/hpov.conf /etc/rsyslog.d/hpov.conf.sv
[ -f /etc/rsyslog.conf ] && \cp /etc/rsyslog.conf /etc/rsyslog.conf.sv

crontab -l > $cwd/crontab.sv

echo "---End of saving existing config files ..." 
echo


# RHEL-7:1:10, CIS 5.1.6, cron.monthly configurations. Solution: from CIS and Platform_Security_Hardening.sh
echo "---Start RHEL-7:1:10. cron.monthly configurations ..."
[ -d /etc/cron.monthly ] && chown root:root /etc/cron.monthly
[ -d /etc/cron.monthly ] && chmod og-rwx /etc/cron.monthly
echo "---End of RHEL-7:1:10. cron.monthly configurations"

echo

# RHEL-7:1:11, CIS 5.1.5, cron.weekly configurations. Solution: from CIS and Platform_Security_Hardening.sh
echo "---Start RHEL-7:1:11. cron.weekly configurations ..."
[ -d /etc/cron.weekly ] && chown root:root /etc/cron.weekly
[ -d /etc/cron.weekly ] && chmod og-rwx /etc/cron.weekly
echo "---End of RHEL-7:1:11. cron.weekly configurations"

echo

# RHEL-7:1:12, CIS 5.1.2, crontab configurations. Solution: from CIS and Platform_Security_Hardening.sh
echo "---Start RHEL-7:1:12. crontab configurations ..."
[ -d /etc/crontab ] && chown root:root /etc/crontab
[ -d /etc/crontab ] && chmod og-rwx /etc/crontab
echo "---End of RHEL-7:1:12. crontab configurations"

echo

# RHEL-7:1:1, CIS 5.1.1, Enable Anacron Daemon. Solution: from CIS
echo "---Start RHEL-7:1:1. Enable Anacron Daemon ..."
yum install cronie-anacron -y
echo "---End of RHEL-7:1:1. Enable Anacron Daemon"

echo

# RHEL-7:1:2, CIS 5.1.1, Enable crond. Solution: from CIS
echo "---Start RHEL-7:1:2. Enable crond ..."
systemctl --now enable crond
systemctl enable crond 
chkconfig crond on
echo "---End of RHEL-7:1:2. Enable crond"

echo

# RHEL-7:1:4, CIS: N/A. Permission of /var/log/cron. Solution: from spreadsheet instruction. Changed 0770 to 0600
echo "---Start RHEL-7:1:4. Permission of /var/log/cron ..."
chmod 0600 /var/log/cron
chown root /var/log/cron
chgrp root /var/log/cron
echo "---End of RHEL-7:1:4. Permission of /var/log/cron ..."

echo

# RHEL-7:1:5, CIS 5.1.8/5.1.9. Restrict at/cron to Authorized Users. Solution: from spreadsheet instruction.
echo "---Start RHEL-7:1:5. Restrict at/cron to Authorized Users ..."
\rm -f /etc/cron.deny
\rm -f /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
echo "---End of RHEL-7:1:5. Restrict at/cron to Authorized Users"

echo

# RHEL-7:1:6, CIS N/A. Set User/Group Owner and Permission on /etc/anacrontab. Solution: from spreadsheet instruction.
echo "---Start RHEL-7:1:6. Set User/Group Owner and Permission on /etc/anacrontab ..."
chown root:root /etc/anacrontab
chmod og-rwx /etc/anacrontab
echo "---End of RHEL-7:1:6. Set User/Group Owner and Permission on /etc/anacrontab"

echo

# RHEL-7:5:20, sshd configurations. Solution: from CIS 3.0
echo "---Start RHEL-7:5:20. sshd config file configurations ..."
chown root:root /etc/ssh/sshd_config 
chmod og-rwx /etc/ssh/sshd_config
echo "---End of RHEL-7:5:20. sshd config file configurations"

echo

# RHEL-7:1:7, cron.d configurations. Solution: from CIS 3.0
echo "---Start RHEL-7:1:7. cron.d configurations ..."
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
echo "---End of RHEL-7:1:7. cron.d configurations"

echo

# RHEL-7:1:8, cron.daily configurations. Solution: from CIS 3.0
echo "---Start RHEL-7:1:8. cron.daily configurations ..."
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
echo "---End of RHEL-7:1:8. cron.daily configurations"

echo

# RHEL-7:1:9, cron.hourly configurations. Solution: from CIS 3.0
echo "---Start RHEL-7:1:9. cron.hourly configurations ..."
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
echo "---End of RHEL-7:1:9. cron.hourly configurations"

echo

# RHEL-7:2:1, CIS 4.2.1.6. Accept Remote rsyslog Messages Only on Designated Log Hosts. Solution: from CIS 3.0
# Here we assume Director is to be set up as a log host
echo "---Start RHEL-7:2:1. Accept Remote rsyslog Messages Only on Designated Log Hosts ..."
egrep -q "ModLoad.*imtcp" /etc/rsyslog.conf && sed -i "s/^#\$ModLoad.*imtcp/\$ModLoad imtcp/" /etc/rsyslog.conf || echo "\$ModLoad imtcp" >> /etc/rsyslog.conf
egrep -q "InputTCPServerRun.*514" /etc/rsyslog.conf && sed -i "s/^#\$InputTCPServerRun.*514/\$InputTCPServerRun 514/" /etc/rsyslog.conf || echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf
systemctl restart rsyslog
echo "---End of RHEL-7:2:1. Accept Remote rsyslog Messages Only on Designated Log Hosts"

echo

# RHEL-7:2:2, CIS 4.2.1.2. Activate the rsyslog Service. Solution: from Spreadsheet
echo "---Start RHEL-7:2:2. Activate the rsyslog Service ..."
systemctl disable syslog 
systemctl --now enable rsyslog
echo "---End of RHEL-7:2:2. Activate the rsyslog Service"

echo

# RHEL-7:2:14, CIS 4.2.4, Configure logrotate. Solution: from Spreadsheet
echo "---Start RHEL-7:2:14. Configure logrotate ..."
if ! grep -q '/var/log/messages' /etc/logrotate.d/syslog
then
  sed -i '1s/^/\/var\/log\/messages\n/' /etc/logrotate.d/syslog
fi

if ! grep -q '/var/log/secure' /etc/logrotate.d/syslog
then
  sed -i '1s/^/\/var\/log\/secure\n/' /etc/logrotate.d/syslog
fi

if ! grep -q '/var/log/maillog' /etc/logrotate.d/syslog
then
  sed -i '1s/^/\/var\/log\/maillog\n/' /etc/logrotate.d/syslog
fi

if ! grep -q '/var/log/spooler' /etc/logrotate.d/syslog
then
  sed -i '1s/^/\/var\/log\/spooler\n/' /etc/logrotate.d/syslog
fi

if ! grep -q '/var/log/boot.log' /etc/logrotate.d/syslog
then
  sed -i '1s/^/\/var\/log\/boot.log\n/' /etc/logrotate.d/syslog
fi

if ! grep -q '/var/log/cron' /etc/logrotate.d/syslog
then
  sed -i '1s/^/\/var\/log\/cron\n/' /etc/logrotate.d/syslog
fi
echo "---End of RHEL-7:2:14. Configure logrotate ..."

echo

# RHEL-7:2:18, CIS 4.1.1.3, Enable auditing for processes that start prior to auditd. Solution: from CIS
# add GRUB_CMDLINE_LINUX="audit=1" to /etc/default/grub
echo "---Start RHEL-7:2:18. Enable auditing for processes that start prior to auditd ..."
sed -i -e '/GRUB_CMDLINE_LINUX=/s/.$//' /etc/default/grub
sed -i -e '/GRUB_CMDLINE_LINUX=/s/$/ audit=1"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
echo "---End of RHEL-7:2:18. Enable auditing for processes that start prior to auditd"

echo

# RHEL-7:2:19, CIS N/A, Entry of .err /var/log/errlog contained in /etc/rsyslog.d/hpov.conf. Solution: from Spreadsheet
echo "---Start RHEL-7:2:19. Entry of .err /var/log/errlog contained in /etc/rsyslog.d/hpov.conf ..."
if [ -s /etc/rsyslog.d/hpov.conf ]
then
  if ! grep -q '/var/log/errlog' /etc/rsyslog.d/hpov.conf
  then
    sed -i '1s/^/*.err \/var\/log\/errlog\n/' /etc/rsyslog.d/hpov.conf
  fi
else
  echo "*.err /var/log/errlog" > /etc/rsyslog.d/hpov.conf
  chmod 644 /etc/rsyslog.d/hpov.conf
fi
echo "---End of RHEL-7:2:19. Entry of .err /var/log/errlog contained in /etc/rsyslog.d/hpov.conf"

echo

# Here we take care of all auditd related items
# RHEL-7:2:17, CIS 4.1.1.2, Enable auditd service. Solution: from VIL Report
echo "---Start RHEL-7:2:17. Enable auditd service ..."
systemctl enable auditd
service auditd restart
cp -f $cwd/audit.rules_vil /etc/audit/rules.d/audit.rules
# Load the new rules
auditctl -R /etc/audit/rules.d/audit.rules
echo "---End of RHEL-7:2:17. Enable auditd service"

echo

# The following are implemented in new audit.rules
# RHEL-7:2:10, CIS 4.1.15, Ensure sudolog is collected.
# RHEL-7:2:11, CIS 4.1.10, Collect bad access attempts.
# RHEL-7:2:20, CIS 4.1.6, Ensure events modifying MAC are collected.
# RHEL-7:2:23, CIS 4.1.17, Ensure audit config is immutable.
# RHEL-7:2:24, CIS 4.1.3, Collect events modifying date and time.
# RHEL-7:2:25, CIS 4.1.5, Collect events modifying network environment.
# RHEL-7:2:26, CIS 4.1.4, Collect events modifying user/group info.
# RHEL-7:2:3, CIS 4.1.14, Ensure sudoers collected.
# RHEL-7:2:4, CIS 4.1.9, Ensure permission modification events collected.
# RHEL-7:2:6, CIS 4.1.16, Collect Kernel Module Loading and Unloading.
# RHEL-7:2:5, CIS 4.1.13, Collect file deletion events.
# RHEL-7:2:7, CIS 4.1.7, Ensure login and logout is collected.
# RHEL-7:2:8, CIS 4.1.8, Ensure session info is collected.
# RHEL-7:2:9, CIS 4.1.12, Collect Successful File System Mounts

#RHEL-7:2:27, CIS 4.2.1.3. Rsyslog default file permissions. Solution: from spreadsheet and platform_security_hardening.
echo "---Start RHEL-7:2:27. Rsyslog default file permissions ..."
echo "$FileCreateMode 0640 " > /etc/rsyslog.conf
echo "---End of RHEL-7:2:27. Rsyslog default file permissions"

echo

#RHEL-7:3:11, CIS 3.3.2. Disable ICMP Redirect Acceptance. Solution: from spreadsheet and platform_security_hardening.
echo "---Start RHEL-7:3:11. Disable ICMP Redirect Acceptance ..."
grep -q net.ipv4.conf.all.accept_redirects /etc/sysctl.conf && sed -i "s/net.ipv4.conf.all.accept_redirects.*/net.ipv4.conf.all.accept_redirects = 0/" /etc/sysctl.conf || echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
grep -q net.ipv4.conf.default.accept_redirects /etc/sysctl.conf && sed -i "s/net.ipv4.conf.default.accept_redirects.*/net.ipv4.conf.default.accept_redirects = 0/" /etc/sysctl.conf || echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
echo "---End of RHEL-7:3:11. Disable ICMP Redirect Acceptance"

echo

#RHEL-7:3:12, CIS 3.2.1. Disable IP Forwarding. Solution: from spreadsheet (not in platform_security_hardening).
# Added setting for IPv6 per CIS
echo "---Start RHEL-7:3:12. Disable IP Forwarding ..."
grep -q net.ipv4.ip_forward /etc/sysctl.conf && sed -i "s/net.ipv4.ip_forward.*/net.ipv4.ip_forward = 0/" /etc/sysctl.conf || echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
grep -q net.ipv6.conf.all.forwarding /etc/sysctl.conf && sed -i "s/net.ipv6.conf.all.forwarding.*/net.ipv6.conf.all.forwarding = 0/" /etc/sysctl.conf || echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv6.conf.all.forwarding=0
echo "---End of RHEL-7:3:12. Disable IP Forwarding"

echo

#RHEL-7:3:13, CIS 3.3.2. Disable IPv6 Redirect Acceptance. Solution: from spreadsheet and platform_security_hardening.
# Here we also disable IPv4 Redirect Acceptance
echo "---Start RHEL-7:3:13. Disable IPv6 Redirect Acceptance ..."
grep -q net.ipv6.conf.all.accept_redirects /etc/sysctl.conf && sed -i "s/net.ipv6.conf.all.accept_redirects.*/net.ipv6.conf.all.accept_redirects = 0/" /etc/sysctl.conf || echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
grep -q net.ipv6.conf.default.accept_redirects /etc/sysctl.conf && sed -i "s/net.ipv6.conf.default.accept_redirects.*/net.ipv6.conf.default.accept_redirects = 0/" /etc/sysctl.conf || echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_redirects=0
echo "---End of RHEL-7:3:13. Disable IPv6 Redirect Acceptance"

echo

#RHEL-7:3:14, CIS 3.3.9. Disable IPv6 Router Advertisements. Solution: from spreadsheet and platform_security_hardening.
echo "---Start RHEL-7:3:14. Disable IPv6 Router Advertisements ..."
grep -q net.ipv6.conf.all.accept_ra /etc/sysctl.conf && sed -i "s/net.ipv6.conf.all.accept_ra.*/net.ipv6.conf.all.accept_ra = 0/" /etc/sysctl.conf || echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
grep -q net.ipv6.conf.default.accept_ra /etc/sysctl.conf && sed -i "s/net.ipv6.conf.default.accept_ra .*/net.ipv6.conf.default.accept_ra = 0/" /etc/sysctl.conf || echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
echo "---End of RHEL-7:3:14. Disable IPv6 Router Advertisements"

echo

#RHEL-7:3:16, CIS 3.2.2. Disable Packet redirect sending. Solution: from spreadsheet and platform_security_hardening.
echo "---Start RHEL-7:3:16. Disable Packet redirect sending ..."
grep -q net.ipv4.conf.all.send_redirects /etc/sysctl.conf && sed -i "s/net.ipv4.conf.all.send_redirects.*/net.ipv4.conf.all.send_redirects = 0/" /etc/sysctl.conf || echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
grep -q net.ipv4.conf.default.send_redirects /etc/sysctl.conf && sed -i "s/net.ipv4.conf.default.send_redirects.*/net.ipv4.conf.default.send_redirects = 0/" /etc/sysctl.conf || echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
echo "---End of RHEL-7:3:16. Disable Packet redirect sending"

echo

#RHEL-7:3:18, CIS 3.3.3. Disable Secure ICMP Redirect Acceptance. Solution: from spreadsheet and platform_security_hardening.
echo "---Start RHEL-7:3:18. Disable Secure ICMP Redirect Acceptance ..."
grep -q net.ipv4.conf.all.secure_redirects /etc/sysctl.conf && sed -i "s/net.ipv4.conf.all.secure_redirects.*/net.ipv4.conf.all.secure_redirects = 0/" /etc/sysctl.conf || echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
grep -q net.ipv4.conf.default.secure_redirects /etc/sysctl.conf && sed -i "s/net.ipv4.conf.default.secure_redirects.*/net.ipv4.conf.default.secure_redirects = 0/" /etc/sysctl.conf || echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
echo "---End of RHEL-7:3:18. Disable Secure ICMP Redirect Acceptance"

echo

#RHEL-7:3:20, CIS 1.6.4. Ensure Prelink is disabled. Solution: from spreadsheet and CIS.
echo "---Start RHEL-7:3:20. Ensure Prelink is disabled ..."
rpm -qa | grep -q prelink
if [ $? -eq 0 ];then
  prelink -ua
  yum remove prelink
  echo -e "package: prelink removed"
fi
echo "---End of RHEL-7:3:20. Ensure Prelink is disabled"

echo

#RHEL-7:3:22, CIS 3.3.4. Log Suspicious Packets. Solution: from spreadsheet and platform_security_hardening.
# Warning: this might generated too much log on some systems. By default we don't set this flag
echo "---Start RHEL-7:3:22. Log Suspicious Packets ..."
grep -q net.ipv4.conf.all.log_martians /etc/sysctl.conf && sed -i "s/net.ipv4.conf.all.log_martians.*/net.ipv4.conf.all.log_martians = 1/" /etc/sysctl.conf || echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
grep -q net.ipv4.conf.default.log_martians /etc/sysctl.conf && sed -i "s/net.ipv4.conf.default.log_martians.*/net.ipv4.conf.default.log_martians = 1/" /etc/sysctl.conf || echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
echo "---End of RHEL-7:3:22. Log Suspicious Packets"

echo

echo "---Start flushing IPv4 route settings ..."
sysctl -w net.ipv4.route.flush=1
echo "---End of flushing IPv4 route settings"

echo

echo "---Start flushing IPv6 route settings ..."
sysctl -w net.ipv6.route.flush=1
echo "---End of flushing IPv6 route settings"

echo

#RHEL-7:3:23, CIS N/A. STIG N/A. Remove NNTP authentication and identification. Solution: from spreadsheet.
# Don't think we have this packaged
# Don't think the command is correct
#chkconfig NNTP off
echo "---Start RHEL-7:3:23. Remove NNTP authentication and identification ..."
chkconfig nntpd off
echo "---End of RHEL-7:3:23. Remove NNTP authentication and identification"

echo

#RHEL-7:4:12, CIS 5.3.3. Password Hashing Algorithm to SHA-512. Solution: from platform_security_hardening script
# The verification command is wrong, should be:
# egrep '^password.*sufficient.*pam_unix.so' /etc/pam.d/system-auth /etc/pam.d/system-auth
echo "---Start RHEL-7:4:12. Password Hashing Algorithm to SHA-512 ..."
cp -f $cwd/default_password-auth-ac /etc/pam.d/password-auth-ac
cp -f $cwd/default_system-auth-ac /etc/pam.d/system-auth-ac
echo "---End of RHEL-7:4:12. Password Hashing Algorithm to SHA-512"

echo

#RHEL-7:4:13, CIS 6.1.8/CIS 6.1.9*. Verify permissions on /etc/group- /etc/gshadow-. Solution: from spreadsheet and CIS
# Use 600 for /etc/group- and 000 for /etc/gshadow-
echo "---Start RHEL-7:4:13. Verify permissions on /etc/group- /etc/gshadow- ..."
chown root:root /etc/group-
chmod 600 /etc/group-
chown root:root /etc/gshadow-
chmod 0000 /etc/gshadow-
echo "---End of RHEL-7:4:13. Verify permissions on /etc/group- /etc/gshadow-"

echo

#RHEL-7:4:16, CIS 6.1.6/CIS 6.1.7*. Verify Permissions on /etc/passwd- /etc/shadow-. Solution: from spreadsheet and CIS
# Use 600 for /etc/passwd- and 000 for /etc/shadow-
echo "---Start RHEL-7:4:16. Verify Permissions on /etc/passwd- /etc/shadow- ..."
chown root:root /etc/passwd-
chmod 600 /etc/passwd-
chown root:root /etc/shadow-
chmod 0000 /etc/shadow-
echo "---End of RHEL-7:4:16. Verify Permissions on /etc/passwd- /etc/shadow-"

echo

#RHEL-7:4:4, CIS 5.3.4*. Limit Password Reuse. Solution: from platform_security_hardening script and CIS
# This is already covered by the solution for RHEL-7:4:12
# defaults must be in current directory and have the correct "remember" value:12. CIS has the value:5

#RHEL-7:4:7, CIS 5.4.1.2. Password Change Minimum Number of Days. Solution: from platform_security_hardening script and CIS
echo "---Start RHEL-7:4:7. Password Change Minimum Number of Days ..."
sed -i -E "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/g" /etc/login.defs
for i in $(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1)
do
  chage --mindays 1 "$i"
done
echo "---End of RHEL-7:4:7. Password Change Minimum Number of Days"

echo

#RHEL-7:4:8, CIS 5.3.1. Password Creation Requirement. Solution: from platform_security_hardening script.
# Added minclass = 4
echo "---Start RHEL-7:4:8. Password Creation Requirement ..."
sed -i -E "s/^# minlen.*/minlen = 14/g" /etc/security/pwquality.conf
sed -i -E "s/^# minclass.*/minclass = 4/g" /etc/security/pwquality.conf
sed -i -E "s/^# dcredit.*/dcredit = -1/g" /etc/security/pwquality.conf
sed -i -E "s/^# ucredit.*/ucredit = -1/g" /etc/security/pwquality.conf
sed -i -E "s/^# ocredit.*/ocredit = -1/g" /etc/security/pwquality.conf
sed -i -E "s/^# lcredit.*/lcredit = -1/g" /etc/security/pwquality.conf
echo "---End of RHEL-7:4:8. Password Creation Requirement"

echo

#RHEL-7:4:9, CIS 5.4.1.1. Password Expiration Days. Solution: from platform_security_hardening script and CIS
echo "---Start RHEL-7:4:9. Password Expiration Days ..."
sed -i -E "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g" /etc/login.defs
for i in $(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1)
do
  chage --maxdays 90 "$i"
done
echo "---End of RHEL-7:4:9. Password Expiration Days"

echo

#RHEL-7:5:17, CIS N/A. Permissions on /var/log/messages /var/log/wtmp. Solution: from spreadsheet.
# We set 600 to /var/log/messages and 644 to /var/log/wtmp, which are more strict than 755
# Could not fallback
echo "---Start RHEL-7:5:17. Permissions on /var/log/messages /var/log/wtmp ..."
chmod 600 /var/log/messages
chmod 644 /var/log/wtmp
echo "---End of RHEL-7:5:17. Permissions on /var/log/messages /var/log/wtmp"

echo

#RHEL-7:5:19, CIS 1.5.2. Permissions on Bootloader Config File. Solution: from spreadsheet.
echo "---Start RHEL-7:5:19. Permissions on Bootloader Config File ..."
chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg
echo "---End of RHEL-7:5:19. Permissions on Bootloader Config File"

echo

#RHEL-7:5:4, CIS 4.2.1.3*. Verify Permission of Log file. Solution: from spreadsheet.
# Changed from Manual to script
# Could not fallback
echo "---Start RHEL-7:5:4. Verify Permission of Log file ..."
chown root:root `grep -E "^uucp|^local7|^emerg|^mail.|^auth|^cron.|^.*none|^kern" /etc/rsyslog.conf|awk '{print $2}' | sed -e 's/^-//'`
chmod 600 `grep -E "^uucp|^local7|^emerg|^mail.|^auth|^cron.|^.*none|^kern" /etc/rsyslog.conf|awk '{print $2}' | sed -e 's/^-//'`
custom_log=$(grep -E "^:msg" /etc/rsyslog.conf|awk '{print $4}' | sed -e 's/^-//')
if [ ! -z "$custom_log" ]
then
  chown root:root $custom_log
  chmod 600 $custom_log
fi
echo "---End of RHEL-7:5:4. Verify Permission of Log file"

echo

#RHEL-7:5:7, CIS N/A. Verify permission on /etc/sysctl.conf. Solution: from spreadsheet.
echo "---Start RHEL-7:5:7. Verify permission on /etc/sysctl.conf ..."
chmod 600 /etc/sysctl.conf
echo "---End of RHEL-7:5:7. Verify permission on /etc/sysctl.conf"

echo

#RHEL-7:6:22, CIS 1.1.17. Create Separate Partition for /home. Solution: from spreadsheet.
# If required, is a manual step. Category: N/A

#RHEL-7:6:23, CIS 1.1.10. Create Separate Partition for /var. Solution: from spreadsheet.
# If required, is a manual step. Category: N/A

#RHEL-7:6:24, CIS 1.1.2. Create Separate Partition for /tmp. Solution: from spreadsheet.
# If required, is a manual step. Category: N/A

#RHEL-7:6:25, CIS 1.1.15. Create Separate Partition for /var/log. Solution: from spreadsheet.
# If required, is a manual step. Category: N/A

#RHEL-7:6:26, CIS 1.1.16. Create Separate Partition for /var/log/audit. Solution: from spreadsheet.
# If required, is a manual step. Category: N/A

#RHEL-7:6:27, CIS N/A. Creation of User-ID for Security Team. Solution: from spreadsheet.
# changed username to security_team, space in username is a pain to manage
echo "---Start RHEL-7:6:27. Creation of User-ID for Security Team ..."
useradd security_team
if [ "$?" -eq 0 ]
then
  echo "Please set passwd for user security_team"
  passwd security_team
fi
echo "---End of RHEL-7:6:27. Creation of User-ID for Security Team"

echo

#RHEL-7:6:3, CIS 1.1.18. Add nodev option for /home. Solution: from spreadsheet instruction.
# Spreadsheet says compliant, but conflicting with RHEL-7:6:7, separate mount for /home is likely not there
echo "---Start RHEL-7:6:3. Add nodev option for /home ..."
mount | grep -q -E '\s/home\s'
if [ "$?" -eq 0 ]
then
  mount -o remount,nosuid,nodev /home
fi
echo "---End of RHEL-7:6:3. Add nodev option for /home"

echo

#RHEL-7:6:31, CIS 5.2.9. Disable SSH HostbasedAuthentication. Solution: from spreadsheet.
echo "---Start RHEL-7:6:31. Disable SSH HostbasedAuthentication ..."
sed -i -E "s/.*HostbasedAuthentication.*/HostbasedAuthentication no/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:31. Disable SSH HostbasedAuthentication"

echo

#RHEL-7:6:32, CIS 5.2.11. Disable SSH PermitEmptyPasswords. Solution: from spreadsheet.
echo "---Start RHEL-7:6:32. Disable SSH PermitEmptyPasswords ..."
sed -i -E "s/.*PermitEmptyPasswords.*/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:32. Disable SSH PermitEmptyPasswords"

echo

#RHEL-7:6:33, CIS 5.2.12. Disable SSH PermitUserEnvironment. Solution: from spreadsheet.
echo "---Start RHEL-7:6:33. Disable SSH PermitUserEnvironment ..."
sed -i -E "s/.*PermitUserEnvironment.*/PermitUserEnvironment no/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:33. Disable SSH PermitUserEnvironment"

echo

#RHEL-7:6:34, CIS 5.2.10. Disable SSH Root Login. Solution: from spreadsheet.
#echo "---Start RHEL-7:6:34. Disable SSH Root Login ..."
#sed -i -E "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
#grep -q -E '^PermitRootLogin.*no' /etc/ssh/sshd_config || echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
#echo "---End of RHEL-7:6:34. Disable SSH Root Login"

echo

#RHEL-7:6:35, CIS 5.2.6. Disable SSH X11 Forwarding. Solution: from spreadsheet.
echo "---Start RHEL-7:6:35. Disable SSH X11 Forwarding ..."
sed -i -E "s/.*X11Forwarding.*/X11Forwarding no/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:35. Disable SSH X11 Forwarding"

echo

#RHEL-7:6:36, CIS 1.2.5. Disable the rhnsd Daemon. Solution: from CIS.
echo "---Start RHEL-7:6:36. Disable the rhnsd Daemon ..."
systemctl stop rhnsd
systemctl --now mask rhnsd
echo "---End of RHEL-7:6:36. Disable the rhnsd Daemon"

echo

#RHEL-7:6:37, CIS 6.2.4. Do any '.' or group/world-writable directories not exist in root's $PATH. Solution: from CIS
echo "---Start RHEL-7:6:37. Finding bad directories in root's PATH variable ..."
echo "----Start examing root's PATH variable. If there is any finding, remove from PATH by examine all config files"
if echo "$PATH" | grep -q "::" ; then
  echo "Empty Directory in PATH (::)"
fi
if echo "$PATH" | grep -q ":$" ; then
  echo "Trailing : in PATH"
fi
for x in $(echo "$PATH" | tr ":" " " | xargs -n1 | sort | uniq) ; do
  if [ -d "$x" ] ; then
    ls -ldH "$x" | awk ' $9 == "." {print "PATH contains current working directory (.)"} $3 != "root" {print $9, "is not owned by root"} substr($1,6,1) != "-" {print $9, "is group writable"} substr($1,9,1) != "-" {print $9, "is world writable"}'
  else
    echo "$x is not a directory"
  fi
done
echo "----End of examing root's PATH variable"
echo "---End of RHEL-7:6:37. Finding bad directories in root's PATH variable"

echo

#RHoL-7:6:40, CIS 6.1.11-6.1.12. Do unowned files or ungrouped files or directories not exist on the system. Solution: already implemented, 
# see RHEL-7:6:46 and RHEL-7:6:47.

#RHEL-7:6:45, CIS 5.2.8. Enable SSH IgnoreRhosts. Solution: from spreadsheet instruction.
echo "---Start RHEL-7:6:45. Enable SSH IgnoreRhosts ..."
sed -i -E "s/.*IgnoreRhosts.*/IgnoreRhosts yes/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:45. Enable SSH IgnoreRhosts"

echo

#RHEL-7:6:46, CIS 6.1.12. Find Un-grouped Files and Directories. Solution: from CIS
# Could not fallback
echo "---Start RHEL-7:6:46. Find Un-grouped Files and Directories ..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup > $cwd/noGroupFiles
for j in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup)
do
#  echo "Found file that is owned by nogroup: ${j}"
#  rm -i "$j"
  chgrp nobody "$j"
done
for j in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup)
do
#  echo "Found file that is owned by nogroup: ${j}"
#  rm -i "$j"
  chgrp -h nobody "$j"
done
echo "---End of RHEL-7:6:46. Find Un-grouped Files and Directories"

echo

#RHEL-7:6:47, CIS 6.1.11. Find Un-owned Files and Directories. Solution: from CIS
# Could not fallback
echo "---Start RHEL-7:6:47. Find Un-owned Files and Directories ..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser > $cwd/noUserFiles
for j in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser)
do
#  echo "Found file that is owned by nouser: ${j}"
#  rm -i "$j"
  chown nobody "$j"
done
# Again, this time on symbolic links
for j in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser)
do
#  echo "Found file that is owned by nouser: ${j}"
#  rm -i "$j"
  chown -h nobody "$j"
done
echo "---End of RHEL-7:6:47. Find Un-owned Files and Directories"

echo

#RHEL-7:6:48, CIS 6.1.10. Find World Writable Files. Solution: from CIS
# Could not fallback
echo "---Start RHEL-7:6:48. Find World Writable Files ..."
df --local -P | awk '{if (NR!=1) print $6}'| xargs -I '{}' find '{}' -xdev -type f -perm -0002 > $cwd/worldWritableFiles
for j in $(df --local -P | awk '{if (NR!=1) print $6}'| xargs -I '{}' find '{}' -xdev -type f -perm -0002)
do
#  echo "Found file that is world writablei: ${j}"
  chmod o-w "$j"
done
echo "---End of RHEL-7:6:48. Find World Writable Files"

echo

#RHEL-7:6:49, CIS 1.10. GDM Login Banner. Solution: N/A. We are OK acoording to CIS: GDM not installed

#RHEL-7:6:5, CIS 1.1.7-1.1.9. Add noexec Option to /dev/shm Partition. Solution: from spreadsheet instruction.
# remount will accomplish all 3 items
echo "---Start RHEL-7:6:5. Add noexec Option to /dev/shm Partition ..."
mount | grep -q -E '\s/dev/shm\s'
if [ "$?" -eq 0 ]
then
# see if the entry exists in /etc/fstab, add if not
  grep -q -E '\s/dev/shm\s' /etc/fstab
  if [ "$?" -eq 0 ]
  then
    sed -i '/\/dev\/shm/d' /etc/fstab
  fi
  echo "tmpfs                  /dev/shm                tmpfs    noexec,nodev,nosuid     0 0" >> /etc/fstab
  mount -o remount,noexec,nodev,nosuid /dev/shm
fi
echo "---End of RHEL-7:6:5. Add noexec Option to /dev/shm Partition"

echo

#RHEL-7:6:51, CIS 5.2.16. Idle Timeout Interval for User Login. Solution: from CIS.
# CIS has different values: ClientAliveInterval 300, ClientAliveCountMax 3
echo "---Start RHEL-7:6:51. Idle Timeout Interval for User Login ..."
sed -i -E "s/.*ClientAliveInterval.*/ClientAliveInterval 900/g" /etc/ssh/sshd_config
sed -i -E "s/.*ClientAliveCountMax.*/ClientAliveCountMax 0/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:51. Idle Timeout Interval for User Login"

echo

#RHEL-7:6:53, CIS 5.2.4. Limit Access via SSH. Solution: from sshd_config setting in platform_security_hardening pkg.
# Here we add "admin" to DenyUsers. Add more to DenyUsers or AllowUsers as necessary
echo "---Start RHEL-7:6:53. Limit Access via SSH ..."
sed -i -E "s/.*DenyUsers.*/DenyUsers admin/g" /etc/ssh/sshd_config
if ! grep -q DenyUsers /etc/ssh/sshd_config
then
   echo "DenyUsers admin" >> /etc/ssh/sshd_config
fi
echo "---End of RHEL-7:6:53. Limit Access via SSH"

echo

#RHEL-7:6:62, CIS 1.5.1. Set Boot Loader Password. Solution: from platform_security_hardening script.
# Commented out, Category: N/A
#echo "---Start RHEL-7:6:62. Set Boot Loader Password ..."
#echo -e 'GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.DF0108DE9C271E8D58156DB4EA5F757B374AC952F90C0FD7FD6C5A01E5133A6383043F752481E89F7FC232C31CD70F67254AE0A685187AF35F5799ACAF399F67.7D2FF005FF236668CAC2DD3B82532898E48BC647C9298D202F0735E9740217CDFBB2E43B72CB634E9A01F560C396B3B7666CC78FE9B24B9577672B5A8135708F' > /boot/grub2/user.cfg
#echo "---Setting up boot loader password"
#grub2-setpassword
#chmod 600 /boot/grub2/user.cfg
#chown root:root /boot/grub2/user.cfg
#grub2-mkconfig -o /boot/grub2/grub.cfg
#echo "---End of RHEL-7:6:62. Set Boot Loader Password ..."

#RHEL-7:6:63, CIS 1.1.4. Add nodev option for /tmp. Solution: from spreadsheet instruction.
# Commented out, Category: N/A
#mount | grep -E '\s/tmp\s'
#if [ "$?" -eq 0 ]
#then
#  mount -o remount,noexec,nosuid,nodev /tmp
#fi

#RHEL-7:6:64, CIS 1.1.3. Add noexec option for /tmp. Solution: from spreadsheet instruction.
# Commented out, Category: N/A
#mount | grep -E '\s/tmp\s'
#if [ "$?" -eq 0 ]
#then
#  mount -o remount,noexec,nosuid,nodev /tmp
#fi

#RHEL-7:6:65, CIS 1.1.5. Add nosuid option for /tmp. Solution: from spreadsheet instruction.
# Commented out, Category: N/A. RHEL-7:6:63 - RHEL-7:6:65 could be accomplished by the same command
#mount | grep -E '\s/tmp\s'
#if [ "$?" -eq 0 ]
#then
#  mount -o remount,noexec,nosuid,nodev /tmp
#fi

#RHEL-7:6:7, CIS N/A. Add nosuid option set for /home. Solution: from spreadsheet instruction.
# Commented out, Category: N/A. Conflicting with RHEL-7:6:3 which is compliant
#mount | grep -E '\s/home\s'
#if [ "$?" -eq 0 ]
#then
#  mount -o remount,nosuid /home
#fi

#RHEL-7:6:70, CIS 5.2.5. SSH LogLevel to INFO. Solution: from spreadsheet instruction.
echo "---Start RHEL-7:6:70. SSH LogLevel to INFO ..."
sed -i -E "s/.*LogLevel.*/LogLevel INFO/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:70. SSH LogLevel to INFO"

echo

#RHEL-7:6:71, CIS 5.2.7. SSH MaxAuthTries to 4 or Less. Solution: from spreadsheet instruction.
echo "---Start RHEL-7:6:71. SSH MaxAuthTries to 4 or Less ..."
sed -i -E "s/.*MaxAuthTries.*/MaxAuthTries 4/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:71. SSH MaxAuthTries to 4 or Less"

echo

#RHEL-7:6:72, CIS N/A. RHEL-07-040390. SSH protocol 2. Solution: from spreadsheet instruction.
# This is Mavenir standard sshd_config setting (in Distro hardening pkg)
echo "---Start RHEL-7:6:72. SSH protocol 2 ..."
grep -q Protocol /etc/ssh/sshd_config && sed -i -E "s/.*Protocol.*/Protocol 2/g" /etc/ssh/sshd_config || echo "Protocol 2" >> /etc/ssh/sshd_config
echo "---End of RHEL-7:6:72. SSH protocol 2"

echo

#RHEL-7:6:74, CIS 5.2.13. Use Only Approved Cipher in Counter Mode. Solution: from spreadsheet instruction.
# This is Mavenir standard sshd_config setting (in Distro hardening pkg)
echo "---Start RHEL-7:6:74. Use Only Approved Cipher in Counter Mode ..."
sed -i -E "s/.*Ciphers.*/Ciphers  aes256-ctr,aes192-ctr,aes128-ctr/g" /etc/ssh/sshd_config
echo "---End of RHEL-7:6:74. Use Only Approved Cipher in Counter Mode"

echo

# RHEL-7:6:78, CIS 1.8.1. Warning Banner for Standard Login Services. Solution: from spreadsheet instruction
echo "---Start RHEL-7:6:78. Warning Banner for Standard Login Services ..."
touch /etc/motd
echo "Authorized access only. This system is the property of VodafoneIdea Mobile. Disconnect IMMEDIATELY if you are not an authorized user! All connection attempts are logged and monitored. All unauthorized connection attempts will be investigated and handed over to the proper authorities." > /etc/motd

touch /etc/issue
echo "Authorized access only. This system is the property of VodafoneIdea Mobile. Disconnect IMMEDIATELY if you are not an authorized user! All connection attempts are logged and monitored. All unauthorized connection attempts will be investigated and handed over to the proper authorities." > /etc/issue

touch /etc/issue.net
echo "Authorized access only. This system is the property of VodafoneIdea Mobile. Disconnect IMMEDIATELY if you are not an authorized user! All connection attempts are logged and monitored. All unauthorized connection attempts will be investigated and handed over to the proper authorities." > /etc/issue.net

chown root:root /etc/motd
chmod 644 /etc/motd
chown root:root /etc/issue
chmod 644 /etc/issue
chown root:root /etc/issue.net
chmod 644 /etc/issue.net
echo "---End of RHEL-7:6:78. Warning Banner for Standard Login Services"

echo

# restart sshd after changes to config file
echo "---Restarting sshd ..."
systemctl restart sshd
echo "---End of restarting sshd ..."

echo

#RHEL-7:6:52, CIS 1.4.1. Install AIDE. Solution: from CIS.
# This should be run before crontab entry for aide
echo "---Start RHEL-7:6:52. Install AIDE."
echo "---yum install will be used, if failed, download the rpm and use 'rpm -Uhv' to install"
yum install aide
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz 
echo "---End of RHEL-7:6:52. Install AIDE."

echo

# RHEL-7:1:3, CIS 1.4.2, Ensure filesystem integrity is regularly checked. Solution: from CIS
# Do we run aide? Don't think it is pkged by default. The following could only be done after aide is installed
echo "---Start RHEL-7:1:3. Ensure filesystem integrity is regularly checked."
\cp $cwd/crontab.sv $cwd/crontab.txt
[ -f /usr/sbin/aide ] && echo '0 5 * * * /usr/sbin/aide --check' >> /etc/crontab.txt
[ -f /usr/sbin/aide ] && crontab -u root crontab.txt
\rm -f $cwd/crontab.txt
echo "---End of RHEL-7:1:3. Ensure filesystem integrity is regularly checked."

echo

echo "--Script completed"
