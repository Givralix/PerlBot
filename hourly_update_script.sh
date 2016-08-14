#!/bin/sh
#########################
# Hourly PerlBot Update #
#########################

date = ${date}
log = $date" - log"
rm -r /home/perlbot/PerlBot > /home/perlbot/log/$log
cd /home/perlbot/ >> /home/perlbot/log/$log
git clone https://github.com/Givralix/PerlBot.git >> /home/perlbot/log/$log
perl /home/perlbot/PerlBot/perlbot.py >> /home/perlbot/log/$log
cd /home/perlbot/PerlBot >> /home/perlbot/log/$log
git add chat_database log >> /home/perlbot/log/$log
git commit -m "updated the log and maybe chat_database" >> /home/perlbot/log/$log
