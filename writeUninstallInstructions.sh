cat << ****
Instructions to Fully Uninstall Poplog
======================================

Poplog is installed in a single folder and it is sufficient to remove that
folder and the single symlink that points into it. So, from inside a terminal, 
type the following commands.

    sudo rm ${bindir}/poplog 
    sudo rm -rf ${POPLOG_HOME_DIR}

And that's it.

----------
Stephen Leach, July 2021
****
