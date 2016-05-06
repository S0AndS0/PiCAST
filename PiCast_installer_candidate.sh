#!/bin/bash
echo "Checking permissions run level..."
if [ "${EUID}" = "0" ]; then
	echo "Error encoutered, permissions level is to lax, please run as non-root user or without sudo"
	echo "You will be prompted automaticly for permission exclation only when required."
	exit 1
else
	echo "Setting run-time and globlal variables"
	 : ${USER?}
	 : ${HOME?}
	Var_aptget_depends_list='python-dev python-pip nodejs npm youtube-dl lame mpg321 mplayer livestreamer git'
	export CONCURRENCY_LEVEL=$(($(nproc)+2))
	Var_arch=$(dpkg --print-architecture)
	Var_error_file="${HOME}/PiCAST/errors_and_info.txt"
	echo "Welcome ${USER} to Bashed PiCAST 3 installer!"
	echo "PiCAST start & stop scripts will be downloaded to: ${HOME}/PiCAST"
	echo "Continue?"
	echo -n "Press 'Enter' to continue or 'Ctrl C' to quit now"
	read _unused_var_prompt
	echo "Making PiCAST Folder under: ${HOME}..."
	mkdir -p ${HOME}/PiCAST
fi
PiCast_Error_Logger(){
	Error_Command_to_Log="$@"
	echo "Error encountered trying the following command"
	echo "${Error_Command_to_Log}" | tee -a ${Var_error_file}
	echo "Above has been logged to: ${Var_error_file}"
	echo "Please take notes on any errors or warnings printed prior to this message now!"
	echo -n "Press 'Ctrl C' to quit now or 'Enter' to continue with error logging... "
	read _internal_un_used_var
	echo -n "[Yy/nN]: Would you like to include information about your system in the log file? "
	read Var_REPLY
	case "${Var_REPLY}" in
		[yY][eE][sS]|[yY])
			echo "## $(date) ## Releace and CPU info..." | tee -a ${Var_error_file}
			cat /etc/*-release | grep -vE 'HOME_URL|SUPPORT_URL|BUG_REPORT_URL' | tee -a ${Var_error_file}
			cat /proc/cpuinfo | grep -vE 'Serial' | tee -a ${Var_error_file}
		;;
		*)
			echo "Good Night"
			echo exit
			exit 1
		;;
	esac
	exit 1
}
PiCast_install_apt_depends(){
	echo "Performing update and upgrade via apt-get before attempting to install dependancies..."
	sudo apt-get update && sudo apt-get upgrade
	echo "Installing apt-get'ble dependancies now..."
	sudo apt-get install -y ${Var_aptget_depends_list} || PiCast_Error_Logger "# Installing dependancies: sudo apt-get install -y ${Var_aptget_depends_list}"
}
PiCast_install_source_x264(){
	echo "Downloading and installing source files for H264 encoding/decoding to /usr/src directory"
	cd /usr/src
	sudo git clone git://git.videolan.org/x264
	cd /usr/src/x264
	sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl || PiCast_Error_Logger '# X264 source install: sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl'
	sudo make || PiCast_Error_Logger '# X264 source install: sudo make'
	sudo make install || PiCast_Error_Logger '# X264 source install: sudo make install'
}
PiCast_install_source_ffmpeg(){
	echo "Downloading and installing source files for ffmpeg..."
	cd /usr/src
	sudo git clone git://source.ffmpeg.org/ffmpeg.git
	cd /usr/src/ffmpeg
	sudo ./configure --arch=${Var_arch} --target-os=linux --enable-gpl --enable-nonfree --enable-libx264 || PiCast_Error_Logger '# Ffmpeg source install: sudo ./configure --arch=armel --target-os=linux --enable-gpl --enable-nonfree --enable-libx264'
	sudo make || PiCast_Error_Logger '# Ffmpeg source install: sudo make'
	sudo make install || PiCast_Error_Logger '# Ffmpeg source install: sudo make install'
	if ffmpeg -version; then
		echo "ffmpeg seems to have installed correctly!"
	else
		PiCast_Error_Logger "Error installing ffmpeg: cannot even print ffmpeg version"
	fi
}
PiCast_install_npm_deps(){
	echo "Downloading and installing 'forever' and 'forever-monitor' via 'npm' to allow PiCAST to run without active terminal"
	sudo npm install forever -g
	sudo npm install forever-monitor -g
	if ! [ -d /var/run/forever ]; then
		sudo mkdir -p /var/run/forever
		sudo chown ${USER}:${USER} /var/run/forever
	fi
}
PiCast_install_picast_source(){
	echo "Almost done, now downloading PiCAST start/stop scripts and java script file"
	clear
	echo "Entering PiCAST Folder..."
	cd ${HOME}/PiCAST
	echo "Getting PiCAST Server file..."
	sleep 1
	wget https://raw.githubusercontent.com/lanceseidman/PiCAST/master/picast.js
	echo "Getting Start/Stop Server files..."
	sleep 1
	wget https://raw.githubusercontent.com/lanceseidman/PiCAST/master/picast_start.sh
	wget https://raw.githubusercontent.com/lanceseidman/PiCAST/master/picast_stop.sh
}
PiCast_install_picast_daemon(){
	echo -n "[Yy/nN]: Do you want to start PiCAST automatically on system boot? "
	read Var_REPLY
	# (optional) move to a new line
	echo ''
	case "${Var_REPLY}" in
		[yY][eE][sS]|[yY])
#			if yes, then start risking changes
			cd /etc/init.d
			echo "Downloading PiCAST Daemon file to: /etc/init.d..."
			sleep 1
			sudo wget https://raw.githubusercontent.com/lanceseidman/PiCAST/master/picast_daemon
			sudo mv picast_daemon picast
			sudo chown root:root picast
			sudo chmod +x picast
			sudo update-rc.d picast defaults
			cd ${HOME}
			echo "	Notice: Start and stop service manually with"
			echo '	sudo service picast stop'
			echo '	sudo service picast start'
			echo "	Addtitonally to remove picast from auto-start at boot, if you so desire"
			echo '	sudo update-rc.d picast disable'
		;;
		*)
#			Otherwise exit..
			echo "Good Night"
			echo exit
			exit
		;;
	esac
}
PiCast_first_run(){
	chmod +x ${HOME}/PiCAST/picast_start.sh
	chmod +x ${HOME}/PiCAST/picast_stop.sh
	echo "Goodbye from PiCAST3 Installer! In the future, run PiCAST3 from picast_start.sh..."
	sleep 2
	echo "Remember, build upon PiCAST3 & make donations to lance@compulsivetech.biz via PayPal & Help Donate to Opportunity Village."
	sleep 3
	echo "Launching PiCAST3 for the first time... \n sh ${HOME}/PiCAST/picast_start.sh"
	sh picast_start.sh
}
## Call Functions in correct order
PiCast_install_apt_depends
PiCast_install_source_x264
PiCast_install_source_ffmpeg
PiCast_install_npm_deps
PiCast_install_picast_source
PiCast_install_picast_daemon
PiCast_first_run

