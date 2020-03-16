#!/bin/bash

# echo "PWD=$PWD"
# echo "ARGV[0]=${0}"
# echo "here=${0%/*}"

ProjectName="${0#/*}"

source "${0%/*}/../tools/private_functions.bash_inc"
source "${0%/*}/../tools/svn.scan_release.bash_inc"
source "${0%/*}/../tools/svn.append_log_to_file.bash_inc"


ConfDir="${0%/*}/../config"
CredsDir="${0%/*}/../creds"
source_file="${0}"
compilation_logfile=${source_file}.log
cp ${source_file} ${compilation_logfile}  #fake a filled log by just copying this file into a fresh .log file

receivers="${ToAdminMail},${FromMail}"

CONFIG_FILE=${ConfDir}/pomabuse.cfg
if [ -r "${CONFIG_FILE}" ]; then
	source "${CONFIG_FILE}" && \
	echo "+ loaded ${CONFIG_FILE}"
else
	echo "! no configuration found in ${CONFIG_FILE}, EXITING!"
	exit 3
fi 

Revision="$(svn_scan_release ${source_file}/..)"
svn_append_log_to_file "${source_file}/.." "${compilation_logfile}" "213" "${Revision}"

# simulation of wrong sender -- FromMail="inval@id.sample"
#default_report_engine 3 "FAILED" "${FromMail}" "${ProjectName}" ${Revision} "${compilation_logfile}"  "${receivers}"
sendmail_report_engine 3 "FAILED" "${FromMail}" "${ProjectName}" ${Revision} "${compilation_logfile}"  "${receivers}"
