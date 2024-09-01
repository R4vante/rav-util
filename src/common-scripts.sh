#! /bin/sh -e


# Colors
RC='\033[0m' # Reset color
RED='\033[0;31m'
GREEN='\033[0;32m'

command_exists() {
# Check if a command exists
  which "$1" > /dev/null 2>&1
}

check_escalation_tool() {
  # Check which tool is available for privilege escalation
  if [ -z "$ESCALATION_TOOLS_CHECKED"]; then
    ESCALATION_TOOLS='sudo doas'
    for tool in $ESCALATION_TOOLS; do
      if command_exists ${tool}; then
        ESCALTION_TOOL=${tool}
        echo -e "${GREEN}Using ${tool} for privilege escalation${RC}"
        ESCALATION_TOOLS_CHECKED=1
        return 0
      fi
    done
    
    echo -e "${RED}No privilege escalation tool found. Exiting...${RC}"
    exit 1

  fi
}



check_package_manager() {
# Check which package manager is available
  PACKAGEMANAGER=$1
  for pgm in $PACKAGEMANAGER; do
    if command_exists "${pgm}"; then
      PACKAGER=${pgm}
      echo -e "${GREEN}Using ${pgm} as package manager${RC}"
      return 0
    fi
  done

  if [ -z "$PACKAGER" ]; then
    echo -e "${RED}No package manager found. Exiting...${RC}"
    exit 1
  fi
}


check_os() {
  # Check which OS is running
  DTYPE="unknown"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DTYPE=$ID
  fi
}

check_super_user() {
  # Check if user is in super user group
  SUPERUSERGROUP='wheel sudo root'
  for sug in $SUPERUSERGROUP; do
    if groups | grep -qw ${sug}; then
      SUGROUP=${sug}
      echo -e "${GREEN}User is in super user group: ${sug}${RC}"
      return 0
    fi
  done
  
  if [ -z "$SUGROUP" ]; then
    echo -e "${RED}User is not in super user group. Exiting...${RC}"
    exit 1
  fi
}



check_required_tools(){
# Check for required tools
  REQUIRED_TOOLS=$1
  for tool in $REQUIRED_TOOLS; do
    if ! command_exists ${tool}; then
      echo -e "${RED} ${tool} is required but not found${RC}"
      exit 1
    fi
  done
}


check_dir_write_permission() {
  # Check if current directory has write permissions
  GITPATH="$(dirname $(reapath $0))"
  if [ ! -w ${GITPATH} ]; then
    echo -e "${RED}Cannot write to ${GITPATH}. Exiting...${RC}"
    exit 1
  fi
}

check_escalation_tool
check_package_manager 'apt dnf yum pacman zypper'
check_os
check_super_user
check_required_tools 'curl sudo groups'
