#!/bin/bash

# echo "PWD=$PWD"
# echo "ARGV[0]=${0}"
# echo "here=${0%/*}"

source "${0%/*}/../tools/private_functions.bash_inc"

receivers="root builder, team"
# root=zack.and@example.com
# builder=miri.make@example.com
# team=a@example.com, xxx@example.com, movie@example.com 

CredsDir="${0%/*}/../creds"

# read_mail_alias ${CredsDir}/*.alias
  read_mail_alias ${CredsDir}/*.alias.rename_to_extension_alias

echo "from these aliases:'${receivers}'"
mails=$(replace_mail_alias "${receivers}")
echo "to these mails:'${mails}'"
