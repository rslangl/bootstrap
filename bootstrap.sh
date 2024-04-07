#!/bin/sh

SCRIPTS_DIR="scripts"
OUTPUT_DIR="$(dirname "$0")/output"
OUTPUT_FILE="$OUTPUT_DIR/output.txt"
CONFIG_DIR="$(dirname "$0")/configs"

clean() {
	rm $OUTPUT_FILE
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
for script in "$SCRIPTS_DIR"/*.sh; do
	if [ -x "$script" ]; then
		# Get base name of script being executed
		script_name=$(basename "$script")

		printf "Running script: %s... " "$script_name"

		start_spinner &
		SPINNER_PID=$!

		printf "OK"

		# Execute script and capture its output
		output=$("$script" 2>&1)

		stop_spinner $SPINNER_PID

		echo "$output" | tail -n 5

		#echo "OK"
	fi
done
