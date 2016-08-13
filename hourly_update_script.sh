#########################
# Hourly PerlBot Update #
#########################

rm -r /home/perlbot/PerlBot
cd /home/perlbot/
git clone https://github.com/Givralix/PerlBot.git
perl /home/perlbot/PerlBot/perlbot.py >> /home/perlbot/PerlBot/log
cd /home/perlbot/PerlBot
git add chat_database log
git commit -m "updated the log and maybe chat_database"
