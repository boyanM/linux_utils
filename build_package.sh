#!/bin/bash

[ -f /usr/bin/dpkg-deb ] || exit 1

if [ $? == 1 ] ; then echo "Please install dpkg-deb to build packages !" ; fi

build_command="/usr/bin/dpkg-deb"

read -p "Enter name for your package (without .deb): " package_name
echo ${package_name}

read -p "Enter full path where do you want your package to be made: " package_location
package_location = "$(echo ${package_location%/})"

ls $package_location 1>/dev/null 2>&1 || exit 1
if [ $? == 1 ] ; then "Invalid location, exiting script ....." ; fi

full_path_to_dir="$package_location/$package_name"
mkdir ${full_path_to_dir}

cd ${full_path_to_dir}

mkdir DEBIAN
touch "DEBIAN/control"
touch "DEBIAN/md5sums"

echo "Please answer the following questions for general information of the package"

PKG_NAME="Package: ${package_name}"

read -p "Enter the version of the package: " PKG_VERSION
PKG_VERSION="Version: ${PKG_VERSION}"
echo ${PKG_VERSION}

read -p "Enter the architecture on which your package will work (all,arm64,amd64,i386,Arm): " PKG_ARCH
PKG_ARCH="Architecture: ${PKG_ARCH}"
echo "Here is no validation, please check carefully ! your choise -> ${PKG_ARCH}"

read -p "Enter the maintainer of the package (can be organization): " PKG_MAIN
PKG_MAIN="Maintainer: ${PKG_MAIN}"
echo ${PKG_MAIN}

read -p "Enter the installed size of package: " PKG_SIZE
PKG_SIZE="Installed-Size: ${PKG_SIZE}"
echo ${PKG_SIZE}

read -p "Enter all dependent packages: " PKG_DEPS
PKG_DEPS="Depends: ${PKG_DEPS}"
echo ${PKG_DEPS}

read -p "Enter section (perl,python,nginx,apache): " PKG_SEC
PKG_SEC="Section: ${PKG_SEC}"
echo ${PKG_SEC}

read -p "Enter priority (optional,required,important,standart,extra): " PKG_PRIOR
PKG_PRIOR="Priority: ${PKG_PRIOR}"
echo ${PKG_PRIOR}

read -p "Enter homepage (https://metacpan.org): " PKG_HOME
PKG_HOME="Homepage: ${PKG_HOME}"
echo ${PKG_HOME}

read -p "Enter short description of the package: " PKG_DESC
PKG_DESC="Description: ${PKG_DESC}"
echo ${PKG_DESC}

read -p "Enter long description of the package: " PKG_LONG_DESC
echo ${PKG_LONG_DESC}


echo
echo "Control Information:"
echo -e "${PKG_NAME}\n${PKG_VERSION}\n${PKG_ARCH}\n${PKG_MAIN}\n${PKG_SIZE}\n${PKG_DEPS}\n${PKG_SEC}\n${PKG_PRIOR}\n${PKG_HOME}\n${PKG_DESC}\n ${PKG_LONG_DESC}" | tee "DEBIAN/control"


echo "Enter full paths of files that you want package to install (FULL PATHS)"

while true
do
	read -p "Enter full path to files that you want package to install or -1 to exit the infinity loop (FULL PATHS !!!!!): " file
	if [ "$file" = "-1" ] ; then break ; fi
	file_path="$(pwd)/$(dirname ${file})"
	mkdir -p ${file_path}
	cp ${file} "${file_path}/$(basename ${file})"
	md5sum "${file}" >> "DEBIAN/md5sums"
done

cd ..

${build_command} -b ${package_name} ${package_name}.deb

if [ $? == 0 ] ; then echo "Package build sucessfully!" ; else echo "Failed building package !!!" ; fi


