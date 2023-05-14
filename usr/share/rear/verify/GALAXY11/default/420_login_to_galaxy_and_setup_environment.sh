#
# Commvault requires a logon to the backup system that is independent from the system
# logon. The logon stores a session file on the system (/opt/commvault/qsession.0) so that
# a session might exist already.


# we first try to run a Commvault command and try to logon if it fails
qlist backupset -c $HOSTNAME -a Q_LINUX_FS >/dev/null
let qlist_ret=$?
if test $qlist_ret -eq 0; then
	Log "CommVault client logged in automatically"
elif test $qlist_ret -eq 2; then
	if test "$GALAXY11_USER" && { test "$GALAXY11_PASSWORD" ; } 2>/dev/null ; then
		# try to login with Credentials from env
        # Using "if COMMAND ; then ... ; else echo COMMAND failed with $? ; fi" is mandatory
        # because "if ! COMMAND ; then echo COMMAND failed with $? ..." shows wrong $? because '!' results $?=0
		if { qlogin -u "$GALAXY11_USER" -clp "$GALAXY11_PASSWORD" ; } 2>/dev/null ; then
            LogPrint "CommVault client logged in with credentials from GALAXY11_USER '$GALAXY11_USER' and GALAXY11_PASSWORD"
        else
            Error "CommVault 'qlogin -u $GALAXY11_USER -clp GALAXY11_PASSWORD' failed with exit code $? (retry on command line to see error messages)"
		fi
	else
        is_true "$NON_INTERACTIVE" && \
            Error "Login is not possible in non-interactive mode. Set variables GALAXY11_USER and GALAXY11_PASSWORD."
        
		# try to logon manually
		Print "Please logon to your Commvault CommServe with suitable credentials:"
		qlogin $(test "$GALAXY11_Q_ARGUMENTFILE" && echo "-af $GALAXY11_Q_ARGUMENTFILE") 0<&6 1>&7 2>&8 || \
			Error "Could not logon to Commvault CommServe. Check the log file."
	fi
else
	Error "Unknown error in qlist [$qlist_ret], check log file"
fi
