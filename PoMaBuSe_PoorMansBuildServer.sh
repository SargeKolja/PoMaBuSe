#!/bin/bash

# ==== JOBS =====
# a job is a file, containing:
#	version checkout tool (svn)
#   remote repository address (svn+ssh://ourserver.local/repositories/coolprojects/thisone
#	local sandbox path (~/sandboxes)
#   specifier for branches (/trunk)
#   specifier for release version number (HEAD)
#   name of the Changes-Scanner (a bash include file in lib, defining how to see if server has newer version)
#   name of the Release-Scanner (a bash include file in lib, defining how to get the specific release version number)
#   name of credentials file

ConfDir=${1:-./config}
CONFIG_FILE=${ConfDir}/pomabuse.cfg

if [ -r "${CONFIG_FILE}" ]; then
	source "${CONFIG_FILE}" && \
	echo "+ loaded ${CONFIG_FILE}"
else
	echo "! no configuration found in ${CONFIG_FILE}, EXITING!"
	exit 3
fi


# ToDo: always use './xxxx' or shall we get the prefix from config?
lib=./lib
JobsDir=./jobs
CredsDir=./creds
LogDir=./log
FlagDir=./flags

mkdir -p ${JobsDir}  2>/dev/null
mkdir -p ${CredsDir} 2>/dev/null
mkdir -p ${LogDir}   2>/dev/null
mkdir -p ${FlagDir}  2>/dev/null

STOP_FLAG=$(readlink -f ${FlagDir}/pomabuse.flg)  # if seen this flag, all recent jobs will get finisehd, then not scanned again
REVISION_FILE=$(readlink -f ${FlagDir}/revision.log)
COMPILER_LOGFILE=$(readlink -f ${LogDir}/logfile.log)
Logfile=$(readlink -f ${LogDir}/pomabuse_internal.log)

if [ -z "$(ls -1 ${lib}/*.bash_inc  2>/dev/null)" ]; then 
	echo "! No Sub-Functions found in ${lib}/*.bash_inc, EXITING!"
	exit 3
else
	for library in $( ls -1 ${lib}/*.bash_inc  2>/dev/null ); do
		source ${library} && \
		echo "+ loaded ${library}"
	done
fi

if [ -z "$(ls -1 ${CredsDir}/*.cfg 2>/dev/null)" ]; then
	echo "? no Credentials found in ${CredsDir}/*.cfg, is this intentional?"
fi

if [ -z "$(ls -1 ${JobsDir}/*.job 2>/dev/null)" ]; then
	echo "! no jobs found in ${JobsDir}/*.job, EXITING!"
	exit 3
fi

declare -i LAST_GOOD_REV=-1
declare -i LAST_TRIED_REV=-1


echo "Start $(date --rfc-email)" > ${Logfile}    # just initial line for internal log


while [ ! -f ${STOP_FLAG} ]; do
	echo "* Performing Jobs from ${JobsDir}/ ..."
	PoMaBuSeDir="${PWD}" # make it avail for jobs to access this scripts, f.i. to call automatic tests or demos
	
	if [ "Y" == "${VCS_JOBDIR_UPDATE_LOOP}" ]; then
		${VCS_JOBDIR_TYPE} ${VCS_JOBDIR_UPDATE} ${JobsDir}/ | tee -a "${Logfile}" >&2
	fi
	
	for job in $( ls -1 ${JobsDir}/*.job); do
		echo -e "\n===================[ Job ${job} starting.. ]=================="
		REVISION_FILE=$(readlink -f "${FlagDir}/${job##*/}.rev")
		COMPILER_LOGFILE=$(readlink -f "${LogDir}/${job##*/}.log")
		echo "=>Job '${job}' started $(date --rfc-email)" | tee "${COMPILER_LOGFILE}"
		LAST_GOOD_REV=0
		LAST_TRIED_REV=-1
		if [ ! -r "${REVISION_FILE}" ]; then
			echo "- 1st time init ${REVISION_FILE} to LAST_GOOD_REV=${LAST_GOOD_REV} LAST_TRIED_REV=${LAST_TRIED_REV}" | tee -a "${COMPILER_LOGFILE}"
			tools_update_used_versions "${REVISION_FILE}" ${LAST_GOOD_REV} ${LAST_TRIED_REV} 2>&1 | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"  # setting last tried below last good forced 1st time compilation
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
			echo "Warning: missing report engine, can't report this" | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
			CHECK_${REPORT_ENGINE} 2>&1  | tee -a "${COMPILER_LOGFILE}"
			# stderr_report_engine $? "FAILED" "${FromMail}" "${ProjectName}" "1" "${COMPILER_LOGFILE}" "${FromMail}"
			report_error $? "${ProjectName}" "missing report engine ${REPORT_ENGINE}"
		fi
		echo "-----------------------------------------" | tee -a "${COMPILER_LOGFILE}"
		echo "checking if ${SANDBOX} is halfway working ..."
		if [ ! -r ${SANDBOX} ]; then
			echo "getting ${URL} / ${VCSTRUNK} revision ${REVISION}:" | tee -a "${COMPILER_LOGFILE}"
			${VCS_CHECKOUT} "${SANDBOX}" 2>&1 | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
		fi
		if [ -r ${SANDBOX} ]; then
			echo "checking status ..." | tee -a "${COMPILER_LOGFILE}"
			# LastEditors=$(${SCAN_AUTHORS} "${SANDBOX}" "${LAST_GOOD_REV}" "${TRY_THIS_REV}")
			# echo "LastEditors=${LastEditors}"
			if [ "YES" == $(${CHECK_SANDBOX} "${SANDBOX}") ]; then
				echo "- is a ${VSCNAME} sandbox, okay" | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
				if [ "YES" == $(${IF_CHANGED} "${SANDBOX}") \
				     -o ${LAST_GOOD_REV} -lt ${LAST_TRIED_REV} \
					 -o ${LAST_GOOD_REV} -le 0 \
					 -o ${LAST_TRIED_REV} -le 0 ]; then
					echo "- is more recent on the server, need to dive in ..." | tee -a "${COMPILER_LOGFILE}"
					echo "invoking ${VCS_UPDATE} ${SANDBOX}" | tee -a "${COMPILER_LOGFILE}"
					${VCS_UPDATE} "${SANDBOX}" 2>&1 | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
					if [ 0 -eq ${PIPESTATUS[0]} -a "NO" == $(${IF_CHANGED} "${SANDBOX}") ]; then
						echo "- updated successfully, can BUILD now" | tee -a "${COMPILER_LOGFILE}"
						TRY_THIS_REV=$(${GET_RELEASEID} "${SANDBOX}")
						if [ ${TRY_THIS_REV} -gt ${LAST_TRIED_REV} ]; then
							echo "+ ${TRY_THIS_REV} newer than ${LAST_TRIED_REV}, so we can give it a new try" | tee -a "${COMPILER_LOGFILE}"
							tools_update_used_versions "${REVISION_FILE}" "${LAST_GOOD_REV}" "${LAST_TRIED_REV}" 2>&1 | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
							LastEditors=$(${SCAN_AUTHORS} "${SANDBOX}" "${LAST_GOOD_REV}" "${TRY_THIS_REV}")
							echo -e "> LastEditors have been:\n\t${LastEditors}" | tee -a "${COMPILER_LOGFILE}"
							# compile ...
							echo "-----------------------------------------" | tee -a "${COMPILER_LOGFILE}"
							PoMaBuSeDir="${PWD}"
							cd "${SANDBOX}"
							echo "${PWD}" | tee -a "${COMPILER_LOGFILE}"
							DO_REPORT=' && echo "+++OKAY+++$?" || echo "---FAIL---$?"'
							DO_BUILD_AND_REPORT=${COMPILE}${DO_REPORT}
							echo -e "# calling compiler:\n\t${DO_BUILD_AND_REPORT}" | tee -a "${COMPILER_LOGFILE}"
							date --iso-8601=ns | tee -a "${COMPILER_LOGFILE}"
							# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
							# here we compile!
							# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
							( eval "${DO_BUILD_AND_REPORT}" ) 2>&1 | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
							Err=$?
							Res="$(tail -1 < "${COMPILER_LOGFILE}")"
							# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
							# echo "Err=$Err, Res=$Res, Res:0:9=${Res:0:9}, Res:10=${Res:10}"
							if [ ${Err} -eq 0 -a "---FAIL---" == ${Res:0:10} ]; then
								let Err=${Res:10}
								echo "imported error code Err=$Err" | ColorizeANSI
							fi
							# does not work here!? -- echo "PIPESTATUS[*]=${PIPESTATUS[*]}"
							echo "compiler/script returned ${Err}" | tee -a "${COMPILER_LOGFILE}"
							date --iso-8601=ns | tee -a "${COMPILER_LOGFILE}"
							AttachedLogfile="${COMPILER_LOGFILE}"
							if [ ${Err} -eq 0 ]; then
								cd ${PoMaBuSeDir}
								echo "+ compilation of version ${TRY_THIS_REV} was okay" | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
								# todo: parameter or switch to decide if POSITIVE reports shall be sent (or sent after recovered failure to failure recipients?)
								if ${UseAnsiColorFilter}; then ColorwashANSI_file  "${COMPILER_LOGFILE}"; fi
								if ${UseHTMLlogfile}; then
									ToColorHTMLDOC_file "${COMPILER_LOGFILE}" "${COMPILER_LOGFILE}.html"
									AttachedLogfile="${COMPILER_LOGFILE}.html"
								fi
								${REPORT_ENGINE} ${Err} "SUCCESS" "${FromMail}" "${ProjectName}" "${TRY_THIS_REV}" "${AttachedLogfile}"  ${LastEditors}
								# setting both revisions equal on success:
								tools_update_used_versions "${REVISION_FILE}" "${TRY_THIS_REV}" "${TRY_THIS_REV}" 2>&1 | ColorizeANSI | tee -a "${COMPILER_LOGFILE}"
							else
								cd "${PoMaBuSeDir}"
								echo "--- Changes since last successful compilation:" | tee -a "${COMPILER_LOGFILE}"
								${GET_LAST_CHANGES} "${SANDBOX}" "${COMPILER_LOGFILE}" "${LAST_GOOD_REV}" "${TRY_THIS_REV}"
								echo "reporting ERR to ${REPORT_ENGINE}" | tee -a "${COMPILER_LOGFILE}"
								if ${UseAnsiColorFilter}; then ColorwashANSI_file  "${COMPILER_LOGFILE}"; fi
								if ${UseHTMLlogfile}; then
									ToColorHTMLDOC_file "${COMPILER_LOGFILE}" "${COMPILER_LOGFILE}.html"
									AttachedLogfile="${COMPILER_LOGFILE}.html"
								fi
								${REPORT_ENGINE} ${Err} "FAILED" "${FromMail}" "${ProjectName}" "${TRY_THIS_REV}" "${AttachedLogfile}" ${LastEditors}
								echo "compilation FAILED" | ColorizeANSI
							fi
						else
							echo "? already tried to build version ${LAST_TRIED_REV}, skipping this"
						fi
					else
						# echo "! failed updating or commit in progress, skipping this time"
						report_error $? "${ProjectName}" "! FAILED updating sandbox ${SANDBOX}"
						mv "${job}" ${job}.broken  #to prevent stop of whole builder and to prevent endless mail loops
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
