#!/bin/sh
#########################
# Hourly PerlBot Update #
#########################

cd /home/bismuth/PerlBot
git pull
perl main.pl
git add blog_dialogue.txt answered_asks_ids
git commit -m "updated blog_dialogue.txt and answered_asks_ids"
git push
