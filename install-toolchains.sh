#!/bin/sh
#
#	credit for the structure of this shell script 
#	goes to http://stackoverflow.com/users/68587/john-kugelman
#	see  http://stackoverflow.com/questions/13588457/forward-declarations-in-bash
#	for information on this eloquent means of providing 
#	the equivalent of forward declarations in a shell script
#
set -x #echo on

#---------------------------------------------
#	main()
#---------------------------------------------
main()
{
	echo "entering main"
	echo "args are 0=$0 1=$1 2=$2"

	parse_cmdline "$@"				read and process cmdline arguments

	discover_platform				# windows or linux platform num cores etc

	install_dependencies			# install needed libs etc

#	install_mingw32_qt 				# install mingw32 i686 and QT libs etc

	discover_basedir				# establish our base address

	addpaths_bashrc					# update ~.bashrc with our PATHs

	remote_repositories				# define url's etc for remote repos

	create_dir_structure			# Setup embeddedDev directory structure

#	build_install_unzip				# unzip is required for extracting zip files

#	install_arm_freddiechopin 		# arm-none-eabi  optimised launchpad

#	install_arm_uclinux				# Codesourcery uclinux compiler

#	install_arm_launchpad			# Arm Launchpad arm-none-eabi compiler

	install_stm32cubemx				# STmicro Stm32CubeMX pin configuration tool
exit
	install_openstm32				# STMicro System Workbench IDE

	install_asciidocfx				# AsciidocFX asciidoc editor with live preview

	build_install_codelite			# Build custom Codelite

}

#---------------------------------------------
#	parse commandline arguments
#---------------------------------------------
parse_cmdline()
{

	install_gnu=0
	install_uclinux=0
	install_none=0
	install_linaro=0
	FORCE=0
	SKIP=0
	#echo "while getopts"
	while getopts g:fd:i:s arg
	do
	    case $arg in
			"i")
				INSTALL=$OPTARG;;
			"d")
				DOWNLOAD=$OPTARG;;
			"g")
				case $OPTARG in
					"gnu")
						install_gnu=1;;
					"uclinux")
						install_uclinux=1;;
					"none")
						install_none=1;;
					"linaro")
						install_linaro=1;;
				esac;;
			"f")
				FORCE=1
				echo "FORCE = $FORCE"
				;;
			"s")
				SKIP=1
				echo "SKIP = $SKIP"
				;;
			\?)
				usage
				exit 1;;
	    esac
	done
}

#---------------------------------------------
#	discover which platform we are on
#---------------------------------------------
discover_platform()
{
	uname | grep -i linux > /dev/null
	if [ $? -eq 0 ]; then
	    PLATFORM="pc-linux-gnu"
	else
	    PLATFORM="mingw32"
	fi
	echo "PLATFORM = $PLATFORM"

	NCPU=`grep -c processor /proc/cpuinfo`
	echo "NCPU = $NCPU"
	BB_NUMBER_THREADS=$NCPU
	PARALLEL_MAKE="-j $NCPU"
	echo "BB_NUMBER_THREADS = $BB_NUMBER_THREADS"
	echo "PARALLEL_MAKE = $PARALLEL_MAKE"
	USER=`whoami`
	echo $USER

}

#---------------------------------------------
#	install_dependencies()
#---------------------------------------------
install_dependencies()
{
	echo "entering install_dependencies function"
	if [ $PLATFORM = "mingw32" ]; then
		echo "platform is mingw32"
		pacman -Su
		pacman -S base-devel
		pacman -S msys2-devel
		pacman -S mingw-w64-x86_64-toolchain
		pacman -S git svn mercurial cvs p7zip ruby
	else
		echo "Platform is pc-linux-gnu"
		return
	fi
}


#---------------------------------------------
#	discover basdir
#---------------------------------------------
discover_basedir()
{
	SCRIPT=`perl -e 'use Cwd "abs_path";print abs_path(shift)' $0`
	BASEDIR=`dirname $SCRIPT | sed s/\\\/\\\///`
	echo "BASEDIR = $BASEDIR"
}

#---------------------------------------------
#	add our magic paths to ~/.bashrc
#---------------------------------------------
addpaths_bashrc()
{
	echo "adding our magic paths to ~/.bashrc"
	grep ".embeddedDev" ~/.bashrc >> /dev/null || echo "source $BASEDIR/.embeddedDev_profile" >> ~/.bashrc
}

#---------------------------------------------
#	remote repository defines
#---------------------------------------------
remote_repositories()
{
	if [ $PLATFORM = "pc-linux-gnu" ]; then
    	BIN_DIR=$BASEDIR/bin
    	DOWNLOAD_DIR=$BASEDIR/download
    	TC_INSTALL_DIR=$BASEDIR/tc
		IDE_INSTALL_DIR=$BASEDIR/ide
		EDITOR_INSTALL_DIR=$BASEDIR/editor

		CODELITE_URL="https://github.com/eranif/codelite.git"
		CODELITE_SRC="$DOWNLOAD_DIR/codelite"
		CODELITE_MAKE="-G \"Unix Makefiles\" -DCOPY_WX_LIBS=1 -DCMAKE_BUILD_TYPE=Release -DPREFIX=/opt/emDev/ide/codeliteMB .."


		ARM_UCLINUX="https://sourcery.mentor.com/GNUToolchain/package8744/public/arm-uclinuxeabi/arm-2011.03-46-arm-uclinuxeabi-i686-pc-linux-gnu.tar.bz2"
		ARM_UCLINUX_EXT=lin-uclinux-bz2
		ARM_UCLINUX_LICENSE=$TC_INSTALL_DIR/arm-2011.03/share/doc/arm-arm-uclinuxeabi/LICENSE.txt

		ARM_LAUNCHPAD="https://launchpad.net/gcc-arm-embedded/5.0/5-2015-q4-major/+download/gcc-arm-none-eabi-5_2-2015q4-20151219-linux.tar.bz2"
		ARM_LAUNCHPAD_EXT=lin-lpad-bz2
		ARM_LAUNCHPAD_LICENSE=$TC_INSTALL_DIR/arm-lpad/share/doc/gcc-arm-none-eabi/license.txt																			

		ARM_FREDDIECHOPIN="http://www.freddiechopin.info/phocadownload/bleeding-edge-toolchain/gcc-arm-none-eabi-5_3-151225-linux-x64.tar.xz"
		ARM_FREDDIECHOPIN_EXT=lin-fc-xz
		ARM_FREDDIECHOPIN_LICENSE=$TC_INSTALL_DIR/arm-freddiechopin/share/doc/gcc-arm-none-eabi/license.txt

		STM32CUBEMX_URL="http://www.st.com/st-web-ui/static/active/en/st_prod_software_internet/resource/technical/software/sw_development_suite/stm32cubemx.zip"
		STM32CUBEMX_EXT=lin-stm32cubemx-zip
		STM32CUBEMX_VFY=todo

		OPENSTM32_URL="http://www.ac6-tools.com/downloads/SW4STM32/install_sw4stm32_linux_64bits-latest.run"
		OPENSTM32_EXT=lin-openstm32-run
		OPENSTM32_VFY=todo

		ASCIIDOCFX_URL="https://github.com/asciidocfx/AsciidocFX/releases/download/v1.4.5/AsciidocFX_Linux.tar.gz"
		ASCIIDOCFX_EXT=lin-asciidocfx-gz
		ASCIIDOCFX_VFY=todo
	else
    	BIN_DIR=$BASEDIR/bin
    	DOWNLOAD_DIR=$BASEDIR/download
    	TC_INSTALL_DIR=$BASEDIR/tc
		IDE_INSTALL_DIR=$BASEDIR/ide
		EDITOR_INSTALL_DIR=$BASEDIR/editor

		MSYS2_PACKAGES_URL="https://github.com/Alexpux/MSYS2-packages.git"
		MSYS2_PACKAGES_SRC=$DOWNLOAD_DIR/"MSYS2-packages"
		MINGW_PACKAGES_URL="https://github.com/Alexpux/MINGW-packages.git"
		MINGW_PACKAGES_SRC=$DOWNLOAD_DIR/"MINGW-packages"

		CODELITE_URL="https://github.com/eranif/codelite.git"
		CODELITE_SRC="codelite"
		CODELITE_MAKE="-G \"Unix Makefiles\" -DCOPY_WX_LIBS=1 -DCMAKE_BUILD_TYPE=Release -DPREFIX=/opt/dev/ide/codeliteMB .."

		ARM_UCLINUX="https://sourcery.mentor.com/GNUToolchain/package8745/public/arm-uclinuxeabi/arm-2011.03-46-arm-uclinuxeabi-i686-mingw32.tar.bz2"
		ARM_UCLINUX_EXT=win-uclinux-bz2
		ARM_UCLINUX_LICENSE=$TC_INSTALL_DIR/arm-2011.03/share/doc/arm-arm-uclinuxeabi/LICENSE.txt

		ARM_LAUNCHPAD="https://launchpad.net/gcc-arm-embedded/5.0/5-2015-q4-major/+download/gcc-arm-none-eabi-5_2-2015q4-20151219-win32.zip"
		ARM_LAUNCHPAD_EXT=win-lpad-zip
		ARM_LAUNCHPAD_LICENSE=$TC_INSTALL_DIR/arm-lpad/share/doc/gcc-arm-none-eabi/license.txt

		ARM_FREDDIECHOPIN="http://www.freddiechopin.info/phocadownload/bleeding-edge-toolchain/gcc-arm-none-eabi-5_3-151225-win-x64.7z"
		ARM_FREDDIECHOPIN_EXT=win-fc-7z
		ARM_FREDDIECHOPIN_LICENSE=$TC_INSTALL_DIR/arm-freddiechopin/share/doc/gcc-arm-none-eabi/license.txt

		STM32CUBEMX_URL="http://www.st.com/st-web-ui/static/active/en/st_prod_software_internet/resource/technical/software/sw_development_suite/stm32cubemx.zip"
		STM32CUBEMX_EXT=win-stm32cubemx-zip
		STM32CUBEMX_VFY=todo

		OPENSTM32_URL="http://www.ac6-tools.com/downloads//SW4STM32/install_sw4stm32_win_64bits-v1.3.exe"
		OPENSTM32_EXT=win-openstm32-exe
		OPENSTM32_VFY=todo

		ASCIIDOCFX_URL="https://github.com/asciidocfx/AsciidocFX/releases/download/v1.4.5/AsciidocFX_Windows.zip"
		ASCIIDOCFX_EXT=win-asciidocfx-zip
		ASCIIDOCFX_VFY=todo
	fi
	echo "BIN_DIR = $BIN_DIR"
	echo "DOWNLOAD_DIR = $DOWNLOAD_DIR"
	echo "TC_INSTALL_DIR = $TC_INSTALL_DIR"
	echo "IDE_INSTALL_DIR = $IDE_INSTALL_DIR"
	echo "EDITOR_INSTALL_DIR = $EDITOR_INSTALL_DIR"

}


#---------------------------------------------
#	create directory structure
#---------------------------------------------
create_dir_structure()
{
	ERROR=0
	echo "mkdir -p $BIN_DIR"
	mkdir -p $BIN_DIR
	echo "mkdir -p $DOWNLOAD_DIR"
	mkdir -p $DOWNLOAD_DIR
	echo "mkdir -p $TC_INSTALL_DIR"
	mkdir -p $TC_INSTALL_DIR
	echo "mkdir -p $IDE_INSTALL_DIR"
	mkdir -p $IDE_INSTALL_DIR
	echo "mkdir -p $EDITOR_INSTALL_DIR"
	mkdir -p $EDITOR_INSTALL_DIR
}


#---------------------------------------------
#	install_arm_freddiechopin()
#---------------------------------------------
install_arm_freddiechopin()
{
	echo "entering install_arm_freddiechopin function"
	download $ARM_FREDDIECHOPIN $ARM_FREDDIECHOPIN_LICENSE
	install $ARM_FREDDIECHOPIN $ARM_FREDDIECHOPIN_LICENSE $ARM_FREDDIECHOPIN_EXT

}

#---------------------------------------------
#	install_arm_uclinux()
#---------------------------------------------
install_arm_uclinux()
{
	download $ARM_UCLINUX $ARM_UCLINUX_LICENSE
	install $ARM_UCLINUX $ARM_UCLINUX_LICENSE $ARM_UCLINUX_EXT
}

#---------------------------------------------
#	install_arm_launchpad()
#---------------------------------------------
install_arm_launchpad()
{
	download $ARM_LAUNCHPAD $ARM_LAUNCHPAD_LICENSE
	install $ARM_LAUNCHPAD $ARM_LAUNCHPAD_LICENSE $ARM_LAUNCHPAD_EXT
}

#---------------------------------------------
#	install_stm32cubemx()
#---------------------------------------------
install_stm32cubemx()
{
	download $STM32CUBEMX_URL $STM32CUBEMX_VFY
	install	$STM32CUBEMX_URL $STM32CUBEMX_VFY $STM32CUBEMX_EXT
}

#---------------------------------------------
#	install_openstm32()
#---------------------------------------------
install_openstm32()
{
	download $OPENSTM32_URL $OPENSTM32_VFY
	install	$OPENSTM32_URL $OPENSTM32_VFY $OPENSTM32_EXT
}

#---------------------------------------------
#	install_asciidocfx()
#---------------------------------------------
install_asciidocfx()
{
	download $ASCIIDOCFX_URL $ASCIIDOCFX_VFY
	install	$ASCIIDOCFX_URL $ASCIIDOCFX_VFY $ASCIIDOCFX_EXT
}

#---------------------------------------------
#	build_install_unzip()
#---------------------------------------------
build_install_unzip()
{
	echo "entering build_install_unzip function"
	echo "PLATFORM = $PLATFORM"
	if [ $PLATFORM = "mingw32" ]; then
		git_clone $MSYS2_PACKAGES_URL $MSYS2_PACKAGES_SRC
		build_msys2_package "$MSYS2_PACKAGES_SRC" "unzip"
	fi 
}

#---------------------------------------------
#	build_install_codelite()
#---------------------------------------------
build_install_codelite()
{
	echo "entering build_install_codelite function"
	if [ $PLATFORM = "pc-linux-gnu" ]; then
		git_clone $CODELITE_URL $CODELITE_SRC
		build_codelite "$CODELITE_SRC" "$CODELITE_MAKE"
		create_shortcut codeliteMB /opt/dev/ide/codeliteMB/bin/codelite
	else	# mingw32
		git_clone $MINGW_PACKAGES_URL $MINGW_PACKAGES_SRC
#exit
		echo "finished cloning MINGW-packages"
		build_codelite $MINGW_PACKAGES_SRC "mingw-w64-codelite-git"
	fi 
}

#---------------------------------------------
#	git_clone()
#---------------------------------------------
git_clone()
{
	echo "entering git_clone function"
	url=$1
	dest=$2
	echo "url = $url"
	echo "dest = $dest"
	if [ -d $dest ]; then
		echo "$dest already exists. download again? y/n"
		read -p "> " -r choice
		if [ "$choice" = "y" ]; then
			echo "url = $url dest = $dest"
			rm -rf $dest
			git clone $url $dest
			if [ $? -ne 0 ]; then
				echo "ERROR: unable to do git clone $url"
				ERROR=1		# flag that an error occurred
				rm -rf $dest
				return
			fi
		fi
		return
	else
		git clone $url $dest
		if [ $? -ne 0 ]; then
			echo "ERROR: unable to download $url"
			ERROR=1		# flag that an error occurred
			rm -rf $dest
			return
		fi
	fi	
}

#---------------------------------------------
#	build_msys2_package()
#---------------------------------------------
build_msys2_package()
{
	echo "entering build_msys2_package function"
	echo "arg 1 = $1"
	echo "arg 2 = $2"

	build_src=$1
	package_name=$2


	cd $build_src/$package_name
	echo "we are at `pwd`"
	makepkg -sLf
	pacman -U unzip*.pkg.tar.xz
exit
exit
}

#---------------------------------------------
#	build_mingw_package()
#---------------------------------------------
build_mingw_package()
{
	echo "entering build_msys2_package function"

	echo "arg 1 = $1"
	echo "arg 2 = $2"

	build_src=$1
	package_name=$2

	cd $build_src/$package_name
	echo "we are at `pwd`"
exit
	MINGW_INSTALLS=mingw64 makepkg-mingw -sLf
exit
}

#---------------------------------------------
#	build_codelite()
#---------------------------------------------
build_codelite()
{
	echo "entering build_codelite function"
	echo "arg 1 = $1"
	echo "arg 2 = $2"
		build_src=$1

	if [ $PLATFORM = "pc-linux-gnu" ]; then
		cmake_args=$2		
		cd $build_src
		echo "we are at `pwd`"
		mkdir -p build-release
		cd build-release
		echo	"cmake $cmake_args"
		eval cmake "$cmake_args"
		#make -j8
		make $PARALLEL_MAKE
		make install
	else	# mingw
		package_name=$2
		cd $build_src/$package_name
		cp /opt/dev/PKGBUILD-codelite PKGBUILD
		echo "we are at `pwd`"
		MINGW_INSTALLS=mingw64 makepkg-mingw -sLf
	fi
		create_shortcut codeliteMB $IDE_INSTALL_DIR/codelite/bin/codelite		
}


#---------------------------------------------
#		show_toolchain_option()
#---------------------------------------------
show_toolchain_option()
{
#	echo "entering show_toolchain_option function"
    local msg
    local license_filename

    msg=$1
    license_filename=$2
    if [ -f $license_filename ]; then
		echo "$msg - installed"
    else
		echo "$msg"
    fi
}
#install $ARM_FREDDIECHOPIN $ARM_FREDDIECHOPIN_LICENSE $ARM_FREDDIECHOPIN_EXT

#    install $ARM_UCLINUX $ARM_UCLINUX_LICENSE

#---------------------------------------------
#		create_shortcut()
#---------------------------------------------
create_shortcut()
{
	echo "entering create_shortcut args are $1 $2"
	# create a shortcut
	echo "creating $BIN_DIR/$1"
	cat > $BIN_DIR/$1 << EOF
#!/bin/sh 
exec_path="$2"
exec \$exec_path "\$@"
EOF
	chmod +x $BIN_DIR/$1
	cat $BIN_DIR/$1
}

#---------------------------------------------
#		rename_dir()
#---------------------------------------------
rename_dir()
{
	echo "entering rename_dir function"
	from=$1
	to=$2
	if [ -d "$from" ]; then
		if [ -d $2 ]; then
			echo "$2 exists so must remove"
			rm -rf $2
		fi
		mv $from/ $to/
	else
		echo "ERROR: invalid directory name: $from"
	fi
	echo "ending the mv process"
}

#---------------------------------------------
#		download()
#---------------------------------------------
download()
{
	echo "entering the download function"
   	url=$1
	fullname=`basename $url`
	namenoext=$(echo $fullname | cut -f 1 -d '.')
	file_to_download="$DOWNLOAD_DIR/`basename $url`"
	echo "url = $url"
	echo "fullname = $fullname"
	echo "namenoext = $namenoext"
	echo "file_to_download = $file_to_download"

	if [ -z "$SKIP" ]; then
		SKIP=0
	fi
	echo "SKIP= $SKIP"

	if [ -f $file_to_download ]; then
		echo "download file exists"
		if [ $SKIP -eq 1 ]; then
			echo "This package is already downloaded - skipping."
			return
		else
			echo "This package is already downloaded. download again? y/n"
			read -p "> " -r choice
			if [ "$choice" = "y" ]; then
				rm -rf $file_to_download
				wget --no-check-certificate -c -O $file_to_download $url
				if [ $? -ne 0 ]; then
					echo "ERROR: unable to download $url"
					ERROR=1		# flag that an error occurred
					rm -f $file_to_download
					return
				fi
			fi
			return
		fi
		return
	fi
	wget --no-check-certificate -c -O $file_to_download $url
		if [ $? -ne 0 ]; then
			echo "ERROR: unable to download $url"
			ERROR=1		# flag that an error occurred
			rm -f $file_to_download
			return
		fi

}

#---------------------------------------------
#		install()
#---------------------------------------------
install()
{
	echo "entering the install function"

   	url=$1
	license_filename=$2
	file_ext=$3
	fullname=`basename $url`
	namenoext=$(echo $fullname | cut -f 1 -d '.')
	file_to_install="$DOWNLOAD_DIR/`basename $url`"


	echo "url = $url"
	echo "license = $license_filename"
	echo "file_ext = $file_ext"
	echo "fullname = $fullname"
	echo "namenoext = $namenoext"
	echo "current directory is `pwd`"
	echo "file_to_install = $file_to_install"

    case $file_ext in
		"win-lpad-zip")
			cd $TC_INSTALL_DIR
			echo "current directory is `pwd`"
			unzip $file_to_install -d arm-lpad
			;;
		"win-uclinux-bz2")
			cd $TC_INSTALL_DIR
			tar -xvjf $file_to_install
			rename_dir arm-2011.03* arm-uclinux
			;;
		"win-fc-7z")
			cd $TC_INSTALL_DIR
			cp $file_to_install $fullname
			p7zip -d $fullname
			rename_dir gcc-arm-none-eabi* arm-freddiechopin
			;;
		"win-stm32cubemx-zip")
			cd $IDE_INSTALL_DIR
			echo "current directory is `pwd`"
			if [ -d $DOWNLOAD_DIR/$namenoext ]; then
				echo "$namenoext exists so must remove"
				rm -rf $DOWNLOAD_DIR/$namenoext
			fi
			unzip $file_to_install -d $DOWNLOAD_DIR/stm32cubemx
#			java -jar $DOWNLOAD_DIR/stm32cubemx/Setup*.exe win-auto-install.xml
			/opt/dev/powershell-install.bat $DOWNLOAD_DIR/stm32cubemx/Setup*.exe
			echo "name = $name"
			create_shortcut stm32cubemx $IDE_INSTALL_DIR/STMicroelectronics/STM32Cube/STM32CubeMX/STM32CubeMX
			;;
   		"win-openstm32-exe")
			cd $IDE_INSTALL_DIR
			echo "current directory is `pwd`"
#			chmod +x $file_to_install
			echo "installing into $IDE_INSTALL_DIR/openstm32"
			/opt/dev/powershell-install.bat $file_to_install
#			$file_to_install
			create_shortcut openstm32 $IDE_INSTALL_DIR/openstm32/eclipse
			echo $name
			;;
		"win-asciidocfx-zip")
			cd $EDITOR_INSTALL_DIR
			echo "current directory is `pwd`"
@			unzip $file_to_install -d AscidocFX
			unzip $file_to_install
#			tar -zxvf $file_to_install
			create_shortcut AsciidocFX $EDITOR_INSTALL_DIR/AsciidocFX/AsciidocFx
			;;
		"lin-lpad-bz2")
			cd $TC_INSTALL_DIR
			echo "current directory is `pwd`"
			tar -xvjf $file_to_install
			echo "now to change the directory name"
			name=`find -type d -name gcc-arm-none-eabi*`
			echo $name
			if [ -d "$name" ]; then
				mv $name/ arm-launchpad/
			else
				echo "ERROR: invalid directory name: $name"
			fi
			echo "ending the mv process"
			;;
		"lin-uclinux-bz2")
			cd $TC_INSTALL_DIR
			tar -xvjf $file_to_install
			rename_dir arm-2011.03* arm-uclinux
			;;
		"lin-fc-xz")
			cd $TC_INSTALL_DIR
			echo "current directory is `pwd`"
			tar -xJvf $file_to_install
			rename_dir gcc-arm-none-eabi* arm-freddiechopin
			;;
   		"lin-stm32cubemx-zip")
			cd $IDE_INSTALL_DIR
			echo "current directory is `pwd`"
			if [ -d $DOWNLOAD_DIR/$namenoext ]; then
				echo "$namenoext exists so must remove"
				rm -rf $DOWNLOAD_DIR/$namenoext
			fi
			unzip $file_to_install -d $DOWNLOAD_DIR/stm32cubemx
			java -jar $DOWNLOAD_DIR/stm32cubemx/Setup*.exe $BASEDIR/auto-install.xml
			echo "name = $name"
			create_shortcut stm32cubemx $IDE_INSTALL_DIR/stm32cubemx/STM32CubeMX
			;;
   		"lin-openstm32-run")
			cd $IDE_INSTALL_DIR
			echo "current directory is `pwd`"
			chmod +x $file_to_install
			echo "installing into $IDE_INSTALL_DIR/openstm32"
			$file_to_install
			create_shortcut openstm32 $IDE_INSTALL_DIR/openstm32/eclipse
			echo $name
			;;
		"lin-asciidocfx-gz")
			cd $EDITOR_INSTALL_DIR
			echo "current directory is `pwd`"
			tar -zxvf $file_to_install
			create_shortcut AsciidocFX $EDITOR_INSTALL_DIR/AsciidocFX/AsciidocFX
			;;
 	esac

    if [ $? -ne 0 ]; then
		echo "ERROR: unable to unpack file $file_to_install"
		ERROR=1		# flag that an error occurred
    fi
	cd -
	echo "exiting install"
	echo "current directory is `pwd`"

}

#---------------------------------------------
#		menu()
#---------------------------------------------
menu()
{
	echo "entering menu function"
    local choice
    show_toolchain_option "1\) arm-uclinuxeabi" "$ARM_UCLINUX_LICENSE"
    show_toolchain_option "2\) arm-launchpad" "$ARM_LAUNCHPAD_LICENSE"
    show_toolchain_option "3\) arm-freddiechopin" "$NONEEABI_LICENSE"
    show_toolchain_option "4\) Linaro GNU EABI" "$LINARO_LICENSE"

    echo "5\) Quit"
    read -p "> " -r choice
    case $choice in
		"1")
			echo "choice is $ARM_UCLINUX"
			install $ARM_UCLINUX $ARM_UCLINUX_LICENSE;;
		"2")
			echo "url = $ARM_LAUNCHPAD  license = $ARM_LAUNCHPAD_LICENSE"
			install $ARM_LAUNCHPAD $ARM_LAUNCHPAD_LICENSE;;
		"3")
			install $ARM_FREDDIECHOPIN $ARM_FREDDIECHOPIN_LICENSE;;
		"4")
			install $LINARO $LINARO_LICENSE;;
		"5")
			return 1;;
		*)
			;;
    esac
}

#---------------------------------------------
#		run_menu()
#---------------------------------------------
run_menu()
{
	echo "entering run_menu function"
    cat <<EOF
ARM toolchain installer - detected platform is $PLATFORM.

Choose a toolkit to install.
EOF
    while [ 1 ]
    do
		menu
		if [ $? -eq 1 ]; then
			return
		fi
    done
}

#exit

#---------------------------------------------
#		usage()
#---------------------------------------------
usage()
{
	echo "entering USAGE function"
    cat <<EOF
Usage:
  `basename $0` [options]

Options:
  -f              force
  -s              skip
  -d              package download path
  -i              package install base path
  -g {toolchain}  install a toolchain
      gnu       - GNU EABI
      uclinux   - ucLinux EABI
      none      - None EABI
      linaro    - Linaro GNU EABI

Run without any arguments the program presents an interactive menu.
EOF
}




main "$@"
echo "all done ERROR = $ERROR"
exit $ERROR

