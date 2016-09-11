#!/bin/sh
#########################
# Hourly PerlBot Update #
#########################

cd /home/bismuth/PerlBot
git pull
perl perlbot.pl
cd /home/bismuth/PerlBot
git add chat_database answered_asks_ids
git commit -m "updated chat_database and answered_asks_ids"
git push
