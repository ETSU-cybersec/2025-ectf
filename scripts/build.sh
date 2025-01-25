#!/bin/bash

WORK_DIR="$(find ~/ -type d -name "2025-ectf" 2> /dev/null)"

main(){
	echo -e "Checking for correct project directory\n"
	if [[ $(pwd) != "$WORK_DIR" ]]; then
		echo -e "\nMoving to $WORK_DIR\n"
		cd $WORK_DIR
	fi

	echo -e "Checking for venv\n"
	if [[ "$VIRTUAL_ENV" == "" ]]; then
		echo -e "\nEntering venv\n"
		source ./.venv/bin/activate
	fi
	
	echo -e "Checking for build tools\n"
	if [[ ! $(pip list | grep ectf) == *"ectf"* ]]; then
		echo -e "\nInstalling build tools\n"
		python -m pip install ./tools
		python -m pip install -e ./design
	fi

	echo -e "Checking for secrets directory\n"
	if [[ ! -d ./secrets ]]; then
		echo -e "Creating Secrets directory"
		mkdir secrets
	fi

	echo -e "Checking for secrets.json\n"
	if [[ ! -f ./secrets/secrets.json ]]; then
		echo -e "\nCreating dummy secrets.json\n"
		python -m ectf25_design.gen_secrets secrets/secrets.json 1 3 4
	fi

	echo -e "Creating Build Deployment\n"
	if [[ $(pwd) != "$WORK_DIR/decoder" ]]; then
		cd $WORK_DIR/decoder
	fi

	docker build -t decoder .

	docker run --rm -v ./build_out:/out -v ./:/decoder -v ./../secrets:/secrets -e DECODER_ID=0xdeadbeef decoder

	echo -e "Generating Subscription Update\n"
	cd $WORK_DIR
	if [[ -f subscription.bin ]]; then
		echo -e "\nDeleting current subscription.bin to generate new one\n" 
		rm subscription.bin
	fi

	python -m ectf25_design.gen_subscription secrets/secrets.json subscription.bin 0xDEADBEEF 32 128 1
}

main 
