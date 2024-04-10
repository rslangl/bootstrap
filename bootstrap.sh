#!/bin/sh

SCRIPTS_DIR="$(dirname "$0")/scripts"
CONFIG_DIR="$(dirname "$0")/configs"
OUTPUT_DIR="$(dirname "$0")/output"
OUTPUT_FILE="$OUTPUT_DIR/output.txt"

GREEN='\033[0;32m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

clean() {
	rm -rf $OUTPUT_DIR
	kill "$script_pid"
	exit
}

# Source the spinner functions
. "$(dirname "$0")/utils/spinner.sh"

# Create output dir
if [ ! -d "$OUTPUT_DIR" ]; then
	echo -n "Creating output directory... "
	mkdir $OUTPUT_DIR
	touch $OUTPUT_FILE
	if [ $? -eq 0 ]; then
		echo "OK"
	else
		echo "Failed"
		exit 1
	fi
fi

# Iterate and execute all tasks
# for script in "$SCRIPTS_DIR"/*.sh; do
for script in $(ls -v "$SCRIPTS_DIR"/*.sh); do
	if [ -x "$script" ]; then

		# Get base name of script being executed
		script_name=$(basename "$script")

		printf "Running script: %s... \n" "$script_name"

		# Store script output
		tmpfile=$(mktemp)

		# Start script in the background
		"$script" >"$tmpfile" 2>&1 &
		PID=$!

		# Start spinner
		spinner $PID &
		SPINNER_PID=$!

		# Wait for script to finish
		wait $PID
		SCRIPT_EXIT_CODE=$?

		# Stop spinner
		kill $SPINNER_PID
		wait $SPINNER_PID 2>/dev/null

		# Display script output
		cat "$tmpfile"
		rm "$tmpfile"

		if [ $SCRIPT_EXIT_CODE -eq 0 ]; then
			echo "${GREEN}OK${NOCOLOR}"
		else
			echo "${RED}$script_name execution failed with exit code $SCRIPT_EXIT_CODE${NOCOLOR}"
		fi

		echo "===================="

	fi
done
