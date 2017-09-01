#!/bin/bash
EXITSTATUS=

mkdir -p corpus-utf8 corpus dictionary download html logs

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

check_python_module() {
	MODULE=$1
	MODPATH=$(python -c "import $MODULE; print $MODULE.__path__[0]")
	if test -n "$MODPATH"; then
		echo "Check python module $MODULE: $MODPATH ok"
	else
		echo "Check python module: $MODULE not found"
		echo ""
		echo "Install $MODULE with 'pip install --target=. $MODULE'"
		echo "Enter to install"
		read yn
		pip install $MODULE
		MODPATH=$(python -c "import $MODULE; print $MODULE.__path__[0]")
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

check_python_module bs4

echo "Done checking running environment"
exit $EXITSTATUS
