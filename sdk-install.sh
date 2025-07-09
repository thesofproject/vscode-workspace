#!/bin/bash
#
# Sound Open Firmware SDK installer.
#
# This scripts install the SOF SDK in the users directory of choice and downloads
# and installs dependecies required to build and deploy firmware images, tooling
# and debug scripts.
#

# default workspace directory, can be overriden on script cmd line.
workspace="$HOME/work/sof"

# download and install system dependecies required for SDK, cmd line option.
install_system=false

# download and install staging modules. cmd line option.
install_staging=false

# function to display help/usage information
usage() {
    echo "Usage: $0 [-w <workspace directory>]"
    echo "Options:"
    echo "  -w              Specify SOF workspace directory. $HOME/work/sof is default."
    echo "  -i              Install system package dependecies. Needs sudo."
    echo "  -s              Install staging source code dependecies into workspace."
    echo "  -h              Display this help message."
    exit 1
}

# --- Option Parsing with getopts ---
while getopts "w:his" OPTION; do
    case "${OPTION}" in
        i)
            # Option -v (verbose)
            install_system=true
            echo "Installing system packages."
            ;;
        s)
            # Option -f (force)
            install_staging=true
             echo "Installing staging sources."
            ;;
        w)
            # Option workspace
            workspace="${OPTARG}"
            ;;
        h)
            # Option -h (help)
            usage
            ;;
        \?)
            # Unknown option
            echo "Error: Invalid option: -${OPTARG}" >&2 # Output error to stderr
            usage
            ;;
    esac
done

# install system dependencies.
# TODO: this is for latest Ubuntu, but need similar list for RHEL/Fedora.
install_system_deps() {
    echo "*** Installing system dependencies (needs sudo)."
    sudo apt install --no-install-recommends git cmake ninja-build gperf \
        ccache dfu-util device-tree-compiler wget \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
        make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 default-jre python3-venv \
         octave libssl-dev libtool gettext libncurses-dev
}

# Start of SDK installation
echo "*** SOF SDK installer. ***"
echo "*** Installation workspace is: ${workspace}"

read -r -p "Do you want to continue? (Y/N): " response

# Convert response to lowercase for case-insensitive comparison
response_lower=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response_lower" == "y" ]]; then
  echo "Continuing..."
  # rest of script is now executed.....
else
  echo "Exiting."
  exit 1 # Exit the script
fi

# Dont install over an existing SOF SDK workspace.
if [ -d ${workspace} ]; then
  echo "SOF workspace directory already exists. Exiting."
  exit
fi

if [ "$install_system" = "true" ]; then
    install_system_deps
fi

# clone all SOF SDK source repositories.
echo "*** Setting up workspace and cloning repositories."
mkdir -p ${workspace}
cd ${workspace}
git clone --progress https://github.com/thesofproject/vscode-workspace.git .
git clone --progress --recursive https://github.com/thesofproject/sof.git
git clone --progress https://github.com/thesofproject/sof-test.git
git clone --progress https://github.com/thesofproject/sof-docs.git
git clone --progress https://github.com/thesofproject/sof-bin.git

# we also need to install a lot of python packages for SDK
echo "*** Setting up python virtual environment."
python3 -m venv .venv
source .venv/bin/activate

# install python packages and setup west
echo "*** Installing and initialising west and zephyr"
pip install west
west init .
west zephyr-export
west packages pip --install

# install the Zephyr SDK
echo "*** Installing Zephyr SDK Toolchain"
cd zephyr
west sdk install
cd ..

# install all the tooling required to build documentation
echo "*** Install SOF documentation tooling."
pip install -r sof-docs/scripts/requirements.txt

# SOF SDK needs an environment variable 
echo "*** Setting SOF_WORKSPACE environment variable."
export SOF_WORKSPACE=${workspace}

# Test SDK install by building all SOF targets with Zephyr SDK
echo "*** Now building all platforms supported by Zephyr SDK."
rm -fr .west
west init -l sof
west update
./sof/scripts/xtensa-build-zephyr.py -a

# Now build SOF userspace tools.
echo "***  Now Build tools."
./sof/scripts/build-tools.sh -A
./sof/scripts/build-tools.sh
./sof/scripts/rebuild-testbench.sh

# Complete !
echo "*** All done !"
