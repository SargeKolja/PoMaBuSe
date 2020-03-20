#!/bin/bash

# ==== JOBS =====
# a job is a file, containing:
#	version checkout tool (svn)
#   remote repository address (svn+ssh://ourserver.local/repositories/coolprojects/thisone
#	local sandbox path (~/sandboxes)
#   specifier for branches (/trunk)
#   specifier for release version number (HEAD)
#   name of the Changes-Scanner (a bash include file in Tools, defining how to see if server has newer version)
#   name of the Release-Scanner (a bash include file in Tools, defining how to get the specific release version number)
#   name of credentials file

ConfDir=${1:-./config}
# or shall we get those from config?
JobsDir=${2:-./jobs}
CredsDir=${3:-./creds}
ToolsDir=${4:-./tools}

CONFIG_FILE=${ConfDir}/pomabuse.cfg
STOP_FLAG=./pomabuse.flg  # if seen this flag, all recent jobs will get finisehd, then not scanned again
COMPILER_LOGFILE=/tmp/logfile.log
REVISION_FILE=/tmp/revision.log

#SleepBetweenScans
#MAKE_ON_X_CORES
if [ -r "${CONFIG_FILE}" ]; then
	source "${CONFIG_FILE}" && \
	echo "+ loaded ${CONFIG_FILE}"
else
	echo "! no configuration found in ${CONFIG_FILE}, EXITING!"
	exit 3
fi

if [ -z "$(ls -1 ${ToolsDir}/*.bash_inc  2>/dev/null)" ]; then 
	echo "! No Sub-Functions found in ${ToolsDir}/*.bash_inc, EXITING!"
	exit 3
else
	for tool in $( ls -1 ${ToolsDir}/*.bash_inc  2>/dev/null ); do
		source ${tool} && \
		echo "+ loaded ${tool}"
	done
fi

if [ -z "$(ls -1 ${CredsDir}/*.cfg 2>/dev/null)" ]; then
	echo "? no Credentials found in ${CredsDir}/*.cfg, WARNING!"
fi

if [ -z "$(ls -1 ${JobsDir}/*.job 2>/dev/null)" ]; then
	echo "! no jobs found in ${JobsDir}/*.job, EXITING!"
	exit 3
fi

declare -i LAST_GOOD_REV=0
declare -i LAST_TRIED_REV=-1

Logfile=~/pomabuse_internal.log
echo "Start $(date --rfc-email)" > ${Logfile}    # just initial line for internal log

function report_error {
	# arg 1: error code
	# arg 2: Job or Project name
	# arg 3..n: additional text
	local ErrorCode=${1}
	local ProjectName=${3}
	shift 2
	local Information="${@}"

	echo "++++++++++ INTERNAL ISSUE ++++++++++" >> "${Logfile}"
	if [ -r "${COMPILER_LOGFILE}" ]; then cat "${COMPILER_LOGFILE}" >> "${Logfile}"; fi
	echo "++++++++++ INTERNAL ISSUE ++++++++++" >> "${Logfile}"
	echo "INTERNAL_FAILURE: ${Information}" | tee -a "${Logfile}" >&2
	
	default_report_engine ${ErrorCode} "INTERNAL_FAILURE" "${ToAdminMail}" "${ProjectName}" "0" "${Logfile}" "${ToAdminMail}"
}


while [ ! -f ${STOP_FLAG} ]; do
	echo "* Performing Jobs from ${JobsDir}/ ..."
	PoMaBuSeDir="${PWD}" # make it avail for jobs to access this scripts, f.i. to call automatic tests or demos
	
	if [ "Y" == "${VCS_JOBDIR_UPDATE_LOOP}" ]; then
		${VCS_JOBDIR_TYPE} ${VCS_JOBDIR_UPDATE} ${JobsDir}/ | tee -a "${Logfile}" >&2
	fi
	
	for job in $( ls -1 ${JobsDir}/*.job); do
		echo -e "\n===================[ Job ${job} starting.. ]=================="
		REVISION_FILE="./${job##*/}.rev"
		COMPILER_LOGFILE="$PWD/${job##*/}.log"
		echo "=>Job '${job}' started $(date --rfc-email)" | tee "${COMPILER_LOGFILE}"
		LAST_GOOD_REV=0
		LAST_TRIED_REV=-1
		if [ ! -r "${REVISION_FILE}" ]; then
			echo "- 1st time init ${REVISION_FILE} to LAST_GOOD_REV=0 LAST_TRIED_REV=-1" | tee -a "${COMPILER_LOGFILE}"
			tools_update_used_versions "${REVISION_FILE}" ${LAST_GOOD_REV} ${LAST_TRIED_REV} -1 2>&1 | tee -a "${COMPILER_LOGFILE}"  # setting last tried below last good forced 1st time compilation
		fi
		if [ -r "${REVISION_FILE}" ]; then
			source "${REVISION_FILE}"
			echo "LAST_GOOD_REV=${LAST_GOOD_REV}, LAST_TRIED_REV=${LAST_TRIED_REV}" | tee -a "${COMPILER_LOGFILE}"
		fi
		CFG_CONTENT=$(cat ${job} | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
		# --- debug -- echo -e "\n\n=====\nCFG_CONTENT=${CFG_CONTENT}\n=====\nCOMPILE_CPP=${COMPILE_CPP}\n\n"
		eval "$CFG_CONTENT"
		# -----
		tools_dump_jobdetails "${job}" | tee -a "${COMPILER_LOGFILE}"
		if [ "OKAY" != "$(CHECK_${REPORT_ENGINE})" ]; then
			echo "missing report engine, can't report this" | tee -a "${COMPILER_LOGFILE}"
			CHECK_${REPORT_ENGINE} 2>&1  | tee -a "${COMPILER_LOGFILE}"
			# stderr_report_engine $? "FAILED" "${FromMail}" "${ProjectName}" "1" "${COMPILER_LOGFILE}" "${FromMail}"
			report_error $? "${ProjectName}" "missing report engine ${REPORT_ENGINE}"
		fi
		echo "-----------------------------------------" | tee -a "${COMPILER_LOGFILE}"
		echo "checking if ${SANDBOX} is halfway working ..."
		if [ ! -r ${SANDBOX} ]; then
			echo "getting ${URL} / ${VCSTRUNK} revision ${REVISION}:" | tee -a "${COMPILER_LOGFILE}"
			${VCS_CHECKOUT} "${SANDBOX}" 2>&1 | tee -a "${COMPILER_LOGFILE}"
		fi
		if [ -r ${SANDBOX} ]; then
			echo "checking status ..." | tee -a "${COMPILER_LOGFILE}"
			# LastEditors=$(${SCAN_AUTHORS} "${SANDBOX}" "${LAST_GOOD_REV}" "${TRY_THIS_REV}")
			# echo "LastEditors=${LastEditors}"
			if [ "YES" == $(${CHECK_SANDBOX} "${SANDBOX}") ]; then
				echo "- is a ${VSCNAME} sandbox, ok" | tee -a "${COMPILER_LOGFILE}"
				if [ "YES" == $(${IF_CHANGED} "${SANDBOX}") -o ${LAST_GOOD_REV} -gt ${LAST_TRIED_REV} ]; then
					echo "- is more recent on the server, need to dive in ..." | tee -a "${COMPILER_LOGFILE}"
					echo "invoking ${VCS_UPDATE} ${SANDBOX}" | tee -a "${COMPILER_LOGFILE}"
					${VCS_UPDATE} "${SANDBOX}" 2>&1 | tee -a "${COMPILER_LOGFILE}"
					if [ "NO" == $(${IF_CHANGED} "${SANDBOX}") ]; then
						echo "- updated successfully, can BUILD now" | tee -a "${COMPILER_LOGFILE}"
						TRY_THIS_REV=$(${GET_RELEASEID} "${SANDBOX}")
						if [ ${TRY_THIS_REV} -gt ${LAST_TRIED_REV} ]; then
							echo "+ ${TRY_THIS_REV} newer than ${LAST_TRIED_REV}, so we can give it a new try" | tee -a "${COMPILER_LOGFILE}"
							tools_update_used_versions "${REVISION_FILE}" "${LAST_GOOD_REV}" "${LAST_TRIED_REV}" 2>&1 | tee -a "${COMPILER_LOGFILE}"
							LastEditors=$(${SCAN_AUTHORS} "${SANDBOX}" "${LAST_GOOD_REV}" "${TRY_THIS_REV}")
							echo -e "> LastEditors have been:\n\t${LastEditors}" | tee -a "${COMPILER_LOGFILE}"
							# compile ...
							echo "-----------------------------------------" | tee -a "${COMPILER_LOGFILE}"
							PoMaBuSeDir="${PWD}"
							cd "${SANDBOX}"
							echo "${PWD}" | tee -a "${COMPILER_LOGFILE}"
							echo -e "# calling compiler:\n\t${COMPILE}" | tee -a "${COMPILER_LOGFILE}"
							date --iso-8601=ns | tee -a "${COMPILER_LOGFILE}"
							( eval ${COMPILE} ) 2>&1 | tee -a "${COMPILER_LOGFILE}"
							Err=$?
							date --iso-8601=ns | tee -a "${COMPILER_LOGFILE}"
							if [ ${Err} -eq 0 ]; then
								cd ${PoMaBuSeDir}
								echo "+ compilation of version ${TRY_THIS_REV} was okay" | tee -a "${COMPILER_LOGFILE}"
								# todo: parameter or switch to decide if POSITIVE reports shall be sent (or sent after recovered failure to failure recipients?)
								${REPORT_ENGINE} ${Err} "SUCCESS" "${FromMail}" "${ProjectName}" "${TRY_THIS_REV}" "${COMPILER_LOGFILE}"  ${LastEditors}
								# setting both revisions equal on success:
								tools_update_used_versions "${REVISION_FILE}" "${TRY_THIS_REV}" "${TRY_THIS_REV}" 2>&1 | tee -a "${COMPILER_LOGFILE}"
							else
								cd "${PoMaBuSeDir}"
								echo "--- Changes since last successful compilation:" | tee -a "${COMPILER_LOGFILE}"
								${GET_LAST_CHANGES} "${SANDBOX}" "${COMPILER_LOGFILE}" "${LAST_GOOD_REV}" "${TRY_THIS_REV}"
								echo "reporting ERR to ${REPORT_ENGINE}" | tee -a "${COMPILER_LOGFILE}"
								${REPORT_ENGINE} ${Err} "FAILED" "${FromMail}" "${ProjectName}" "${TRY_THIS_REV}" "${COMPILER_LOGFILE}"  ${LastEditors}
								echo "compilation FAILED"
							fi
						else
							echo "? already tried to build version ${LAST_TRIED_REV}, skipping this"
						fi
					else
						echo "! failed updating or commit in progress, skipping this time"
					fi
				else
					echo "- is still unchanged, nothing to be done"
				fi
			else
				# echo "! FAILED, not a ${VSCNAME} sandbox in ${SANDBOX}"
				report_error $? "${ProjectName}" "! FAILED, not a ${VSCNAME} sandbox in ${SANDBOX}"
				mv "${job}" ${job}.broken  #to prevent stop of whole builder and to prevent endless mail loops
				# exit 4
			fi
		else
			# echo "! FAILED, unreadable sandbox ${SANDBOX}"
			# exit 5
			report_error $? "${ProjectName}" "! FAILED, unreadable sandbox ${SANDBOX}"
			mv "${job}" ${job}.broken  #to prevent stop of whole builder and to prevent endless mail loops
			# exit 5
		fi
		echo -e "===================[ Job ${job} done, next ]==================\n\n"
	done

	echo "~ all jobs done, wait some time ..."
	unchanged ${SleepBetweenScans} "${SANDBOX}"
	echo "~ loop again, until ${STOP_FLAG} is seen"
done # while [ ! -f ${STOP_FLAG} ]; do


#if qmake && make clean && make -j "${NUM_CPUS}" ; then echo YES; else echo NO; fi
#qmake "CONFIG+=release"
# make ${MAKE_ON_X_CORES}
# until becomming part of BiffProcessQ/BiffProcessQ.pro / Makefile, we call it by hand:
#cd BiffProcessQ
    #lupdate BiffProcessQ.pro
    #lrelease BiffProcessQ.pro
    # a second qmake is required, to have also the generated language files avail!
    #rm -f Makefile
    #qmake "CONFIG+=release"
#cd -
#
#sudo sh -c "export INSTALL_ROOT=\"$1\"; make install" 