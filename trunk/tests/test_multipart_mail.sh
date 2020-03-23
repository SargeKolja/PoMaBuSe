#!/usr/bin/bash

MAILTO="mr@example.com"
MAILFR="ms@example.com"
SUBJECT="A #15 subjective subject with HTML body and PNG attachment and more attachments"
BODY="./email_body5.html"
ATTACH_FULLNAME="./attachment.png"


function get_mimetype {
	local file=$(readlink -f ${1})
	if [ -r ${file} ]; then
		file --mime-type ${file} | sed 's/.*: //'
	else
		echo "application/octet-stream"
	fi
}


function send_mail {
	#arg1 = comma separated FROM list (Sender)
	#arg2 = comma separated TO list (Receiver)
	#arg3 = Subject as String
	#arg4 = Mail Text Body as file (.html or .txt)
	#arg5..n = list of files to attach
	local Mail_To="${1}"
	local Mail_From="${2}"
	local Mail_Subj="${3}"
	local Body_File="${4}"
	shift 4
	declare -a Atta_Files
	local Atta_Files=( $@ )
	
	local boundary="$(uuidgen)"

	#echo "Mail   To: ${Mail_To}" >&2
	#echo "Mail From: ${Mail_From}" >&2
	#echo "Mail Subj: ${Mail_Subj}" >&2
	
	if [ ! -f "${Body_File}" ]; then
		Body_File="/tmp/dummybody"
		echo "" > "${Body_File}"
	fi
	#echo "Mail Body: ${Body_File}" >&2
	#echo "Mail Attachments:" >&2
	for attached in "${Atta_Files[@]}"; do
		if [ ! -f "${attached}" ]; then
			echo "Warning: attachment ${attached} not found, skipping" >&2 
			continue
		#else
			#echo -e "\t: ${attached}" >&2 
		fi
	done
	
	cat <<-MAILHEADER
		From: ${Mail_From}
		To: ${Mail_To}
		Subject: ${Mail_Subj}
		Mime-Version: 1.0
		Content-Type: multipart/mixed; boundary="${boundary}"
		
		--${boundary}
		Content-Type: $(get_mimetype ${Body_File}); charset="UTF-8"
		Content-Transfer-Encoding: 7bit
		Content-Disposition: inline

	MAILHEADER
	
	cat "${Body_File}"
	
	for attached in "${Atta_Files[@]}"; do
		local FullName=$(readlink -f "${attached}")
		local ShortName=${FullName##*/}
		if [ ! -f "${FullName}" ]; then
			echo "Warning: attachment ${FullName} not found, skipping" >&2 
			continue
		else
			# echo -e "\t: ${ShortName}" >&2
			cat <<-MAILATTACHMENTS

				--${boundary}
				Content-Type: $(get_mimetype ${FullName})
				Content-Transfer-Encoding: base64
				Content-Disposition: attachment; filename="${ShortName}"

				$(base64 "${FullName}")

			MAILATTACHMENTS
		fi
	done
	echo "--${boundary}--"
}

send_mail "${MAILTO}" "${MAILFR}" "${SUBJECT}" "${BODY}" "${ATTACH_FULLNAME}" *.jpg | sendmail -f${MAILFR} -- ${MAILTO}

