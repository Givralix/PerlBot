#!/bin/sh
#########################
# Hourly PerlBot Update #
#########################

cd /home/bismuth/PerlBot
git pull
perl main.pl
git add blog_dialogue.txt
git commit -m "updated blog_dialogue.txt"
git push
