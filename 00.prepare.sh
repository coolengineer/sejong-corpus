#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#

EXITSTATUS=

mkdir -p corpus-utf8 corpus dictionary download html logs stamps

check_executable() {
	EXE=$1
	EXEPATH=$(which $EXE)
	if test -n "$EXEPATH"; then
		echo "Check $EXE: $EXEPATH ok"
	else
		echo "Check $EXE: No $EXE executable found."
		echo "Install '$EXE' to be run in your current environment"
		EXITSTATUS=1
	fi
}

_check_python_module() {
    rm -rf /tmp/modpath.* 2>/dev/null
	$PYTHONBIN <<EOT > /tmp/modpath.$$
from __future__ import print_function
try:
    import $MODULE
    print($MODULE.__path__[0])
except:
    pass
EOT
    MODPATH=$(cat /tmp/modpath.$$)
}

check_python_module() {
	MODULE=$1
    _check_python_module
	if test -n "$MODPATH"; then
		echo "Check python module $MODULE: $MODPATH ok"
	else
		echo "Check python module: $MODULE not found"
		echo "Install $MODULE with '$PYTHONBIN -m pip install --target=. $MODULE'"
		echo "Enter to install"
		read yn

		"$PYTHONBIN" -m pip install $MODULE
        _check_python_module
        echo $MODPATH
		if test -n "$MODPATH"; then
			echo "Check python module $MODULE: $MODPATH ok"
		else
			echo "Failed to install"
			exit 1
		fi
	fi
}

check_executable curl
check_executable stat
check_executable unzip
check_executable iconv
check_executable patch

if test -n "$EXITSTATUS"; then
    exit $EXITSTATUS
fi

if test -n "$PYTHONBIN"; then
    :
elif which python >/dev/null 2>&1; then
    PYTHONBIN=python
else
    echo "There is no python executable nor PYTHONBIN env is set"
fi

if "$PYTHONBIN" -m pip -V; then
    :
else
    echo "There is no pip module with $PYTHONBIN"
    echo "If you have another python you can specifiy PYTHONBIN=<path of python>"
    exit 1
fi

check_python_module bs4

#Delete zero-sized files
stat -t corpus/* 2>/dev/null | awk '{if ($2 == 0) print $1}' | xargs rm -f

# vim: ts=4 noexpandtab sw=4 sts=4
