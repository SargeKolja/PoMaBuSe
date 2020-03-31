#!/bin/bash

InputLogfile="../log/sample_ERROR.job.log"
OutColoredFile="../log/sample_ERROR.job.col"

source ../config/pomabuse.cfg
source ../lib/10_ANSI_colorizing.bash_inc
source ../lib/11_HTML_colorizing.bash_inc






# ------------------------------------------------------------------

cat ${InputLogfile} | ColorizeANSI | tee ${OutColoredFile}
echo '-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#'
cat ${OutColoredFile} | ColorwashANSI | tee ${OutColoredFile}.txt

cat ${InputLogfile} | ToColorHTMLDOC | tee ${OutColoredFile}.html

Message="OKAY. Yes we can\nWARNING: new president\nERROR: bad hair day?\nSUCCESS: The Germans: Wir schaffen das!\n"

echo -e "${Message}" | ToColorHTMLDOC | tee email_to_the_people.html
echo -e "${Message}" | ColorizeANSI   | tee stdout_to_the_nerds.txt
