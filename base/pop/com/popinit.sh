#!/bin/sh
# --- Copyright University of Sussex 1992. All rights reserved. ----------
# File:            C.unix/com/popinit.sh
# Purpose:         Login definitions for POPLOG users, no message displayed
# Author:          John Gibson (see revisions)
# Documentation:
# Related Files:   C.unix/com/popenv.sh, $poplocal/local/com/popinit.sh

. $usepop/pop/com/popenv.sh

PATH=$popsys\:$PATH\:$popcom
export PATH

if [ -f $poplocal/local/com/popinit.sh ]
then
	. $poplocal/local/com/popinit.sh
fi


# --- Revision History ---------------------------------------------------
# --- Stephen Leach, Jun 24 2021
#       Based on poplog.sh but the display of the message.login file removed
# --- Simon Nichols, Oct  5 1990
#		Removed $Xpopbin from $PATH.
# --- Ian Rogers, Feb 14 1990
#		Added $Xpopbin to PATH
# --- John Williams, Feb 23 1989
#       No longer adds ":" to $PATH; tests $HOME/.hushlogin
