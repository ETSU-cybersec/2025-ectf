#!/bin/bash

WORK_DIR="$(find ~/ -type d -name "2025-ectf" 2> /dev/null)" 

main(){

	echo -e "Checking for correct directory\n"

	if [[ $(pwd) != "$WORK_DIR" ]]; then
		echo -e "\nMoving to $WORK_DIR\n"
		cd $WORK_DIR
	fi

	echo -e "Checking for active venv\n"
	
	if [[ "$VIRTUAL_ENV" == "" ]]; then
		echo -e "\nEntering venv\n"
		source ./.venv/bin/activate
	fi

	echo -e "Checking Build tools\n"

	if [[ ! $(pip list | grep ectf) == *"ectf"* ]]; then
		echo -e "\nInstalling Build Tools\n"
		python -m pip install ./tools
		python -m pip install -e ./design
	fi

	echo -e "Checking for image\n"
	if [[ ! -f $WORK_DIR/decoder/build_out/max78000.bin ]]; then
		echo -e "\nMust create build before flashing\n"
		source $WORK_DIR/scripts/build.sh
	fi

	echo -e "Checking for decoder directory\n"
	if [[ ! $(pwd) == "$WORK_DIR/decoder" ]]; then
		echo -e "Moving to $WORK_DIR/decoder\n"
		cd $WORK_DIR/decoder
	fi

	echo -n "Enter Serial Port: "
	read -r SERIAL_PORT

	python -m ectf25.utils.flash ./build_out/max78000.bin /dev/tty$SERIAL_PORT

	cd $WORK_DIR
}

main 
