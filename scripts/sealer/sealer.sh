#!/bin/bash

### DEFAULTS
# tested age version
tested_version="v1.3.1"
# path to age ident file (e.g. you can generate one with age-keygen | age -p > age-ident)
age_ident_file=$(pwd)/age-ident
# directories for encryption targets
enc_dir="$(pwd)/myfiles"
# placeholder public key
pub_key="none"
# placeholder action
enc_action="none"
# logo print
logo_only="false"

while [ $# -gt 0 ]; do
  case $1 in
    -d|--directory)
      shift
      enc_dir=$1
      shift
      ;;
    -a|--action)
      shift
      enc_action=$1
      shift
      ;;
    -i|--identfile)
      shift
      age_ident_file=$1
      shift
      ;;
    -l|--logo)
      shift
      logo_only="true"
      shift
      ;;
    -h|--help)
      help
      ;;
    *)
      echo -n "$1 "
      shift
      echo "$1 not found!"
      shift
      ;;
  esac
done

echo -e "\e[36;1m"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠟⠛⠉⠉⠉⠀⠈⠉⠉⠉⠛⠷⣦⣄⠀⠀⠀⠀⠀ _______________________"
echo -e "⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⠀⠀⠀⠀/⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      \\"
echo -e "  ⠀⠀⠀⢰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣧⠀⠀< Do you SEAL it through?|"
echo -e "  ⠀⠀⠀⣾⠁⠠⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡆⠀⠀\\_______________________/"
echo -e "⠀⠀⠀⠀⠀⣿⢰⣿⡷⣀⣄⡀⠀⠠⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠐⠶⣼⡏⠘⠛⠁⢴⣦⡇⡀⠀⠙⠛⠛⠁⠖⠚⠉⠀⠀⠀⠀⢸⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠐⠒⣿⠀⠀⠀⠳⠼⠧⠤⠝⠁⠀⠀⠀⠐⠒⠲⠆⠀⠀⠀⠀⠑⠘⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠒⢻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠙⢷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠙⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡏⠀⠀⠀⠀⠀⢠⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢷⡄⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⢳⣱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠈⢿⣄⠀⠀⠀⠀⠀⠀⠀⣸⠀⠀⠀⠀⠀⠀⠀⠀⢿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡆⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠻⣷⣄⠀⠀⠀⠀⠀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡀⠀⠀⠈⠙⠷⣦⡀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣧⠀⠀⠀⠀⠀⠈⢻⣷⣦⣿⡇⠀⠀⠀⠀⠀⢦⠀⢠⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠠⣄⢀⡾⠁⠈⢹⣧⠀⠀⢀⠀⠀⠈⢛⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣦⡀⣀⣽⠟⠀⠀⠀⠀⠻⣧⡀⠘⢦⡀⢀⣾⠷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠀⠀⠀⠀⠀⠀⠀⠙⢿⣤⣈⣻⠿⠁⠀⠈⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣭⡽⠿⠶⠦⣤⣄⣼⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠇"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠦⣀⡀⣀⣤⠶⠛⠉⠀⠀⠀⠀⠀⠐⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠏"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢀⡴⠋⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡆⠀⠀⠀⠀⠀⠀⠀⢀⡴⣚⡥⠾⠂⠀⠀⠀⠀⠀⠀⠀⢰⣹⠋⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠢⣀⠀⠀⠀⠀⣠⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠓⢲⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠁⠀⠀⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡇⠀⠀⠀⠀⢀⣀⣀⣀⡤⠤⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⡄⠀⣴⠟⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"⠀
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠓⠋⠀⠀Sealer V1⠀⠀⠀⠀⠀⠀⠀"⠀
echo -e "\e[0;0m"

if [ "$logo_only" == "true" ]; then
  exit 0
fi

c_red="\e[31;1m"
c_green="\e[32;1m"
c_yellow="\e[33;1m"
c_cyan="\e[36;1m"
c_clear="\e[0;0m"

mockingbird() {
  if [ $1 -eq 1 ]; then echo -e "${c_red}[!] st00pid! ($2 unknown)${c_clear}"; exit 1; fi
}

parrot() {
  echo -e "${c_green}[+] ${1}${c_clear}"
}

help() {
  echo -en "${c_cyan}"
  echo -e "Flags:"
  echo -e "------"
  echo -e " -d|--directory  Target directory of files to en/decrypt (default pwd/myfiles)"
  echo -e " -a|--action     Action to perform (seal/unseal) (default none)"
  echo -e " -i|--identfile  Path to age ident file (default pwd/age-ident)"
  echo -e " -h|--help       Displays this help"
  echo -e ""
  echo -e "Usage:"
  echo -e "------"
  echo -e " - e.g. ./sealer.sh -d ./mydir -a seal -i ./myident"
  echo -e " - e.g. ./sealer.sh -d ./mydir -a unseal -i ./myident"
  echo -e ""
  echo -e "Info:"
  echo -e "-----"
  echo -e " - if you do not have an ident file it will be created on first use (don't lose it)"

  echo -en "${c_clear}"
  exit 0
}

unsealSafeCheckDir() {
  d=$1
  agefiles=$(ls -l $d | grep -c "\.age")
  if [ $agefiles -eq 0 ]; then
    echo -e "${c_red}[!] No files to decrypt!${c_clear}"
    exit 1
  fi
}

sealSafeCheckDir() {
  d=$1
  agefiles=$(ls -l $d | grep -c "\.age")
  if [ $agefiles -gt 0 ]; then
    echo -e "${c_red}[!] Already encryted files in directory (aborting)!${c_clear}"
    exit 1
  fi
}

sealDir() {
  d=$1
  cd $d
  echo -en "${c_green}"
  echo -e "[+] About to seal files in ${d}:"
  
  for F in $(ls -l | awk '{print $NF}' | sed "1d"); do
    echo -e "[>] - $F"
  done

  echo -n "[?] Wanna proceed? (y/n): ";read answer
  if [ "$answer" != "y" ]; then
    echo -e "${c_red}[!] Aborting ...${c_clear}"
    exit 1
  fi
  
  for F in $(ls -l | awk '{print $NF}' | sed "1d"); do
    parrot "Using ident file: $age_ident_file"
    age -r $pub_key $F > ${F}.age
    ret=$(echo $?)
    if [ $ret -eq 0 ]; then
      parrot "encrypted file $F to ${F}.age"
      rm $F
    else
      echo -e "${c_red}[!] Error on encryption attempt!${c_clear}"
      exit 1
    fi
  done
  
  echo -en "${c_clear}"
}

unsealDir() {
  d=$1
  idf="${age_ident_file}.dec"
  
  echo -en "${c_green}"
  echo -e "[+] About to unseal files in ${d}:"
  
  for F in $(ls -l $d | awk '{print $NF}' | sed "1d"); do
    echo -e "[>] - $F"
  done

  echo -n "[?] Wanna proceed? (y/n): ";read answer
  if [ "$answer" != "y" ]; then
    echo -e "${c_red}[!] Aborting ...${c_clear}"
    exit 1
  fi
  
  for F in $(ls -l $d | awk '{print $NF}' | sed "1d"); do
    parrot "Using ident file: ${idf}"
    fname=$(echo $F | sed "s/\.age//g")
    age -d -i $idf $d/$F > $d/${fname}
    ret=$(echo $?)
    if [ $ret -eq 0 ]; then
      parrot "decrypted file $d/$F to $d/${fname}"
      rm $d/$F
    else
      echo -e "${c_red}[!] Error on decryption attempt!${c_clear}"
      if [ -f $idf ]; then
        rm $idf
      fi
      exit 1
    fi
  done
  
  echo -en "${c_clear}"
  
  rm ${idf}
  parrot "Cleaned up $idf"
}

mockingbird $(which -s age && echo $?) "age-binary"
parrot "age binary exists"

age_ver=$(age --version)
if [ "$age_ver" != "$tested_version" ]; then
  echo -e "[${c_red}!] age version not ${tested_version}"${c_clear}
  exit 1
fi
parrot "age binary has correct version ($tested_version)"

# create ident file if non-existent
if [ ! -f $age_ident_file ]; then
  echo -e "${c_yellow}[?] Identity file not found! Creating one ...${c_clear}"
  age-keygen | age -p > $age_ident_file
  parrot "Remember the passphrase at all cost or save it in a vault!"
  parrot "Please save this file ($age_ident_file) in a safe place."
  parrot "This file and your passphrase is your only way to decrypt your files!"
fi

# extract public key from ident file
if [ "$enc_action" == "seal" ]; then
  parrot "getting public key from ident file ->"
  age -d $age_ident_file > ${age_ident_file}.dec
  pub_key=$(cat ${age_ident_file}.dec | grep public | awk -F: '{print $NF}')
  rm ${age_ident_file}.dec
  parrot "extracted public key"
fi

# decrypting ident file for bulk decryption 
if [ "$enc_action" == "unseal" ]; then
  parrot "decrypt ident file with password ->"
  age -d $age_ident_file > ${age_ident_file}.dec
  parrot "ident file decrypted"
fi

# action check
act_list=( "seal" "unseal" )
act_hit=1

for ACT in ${act_list[@]}; do
  if [ "$ACT" == "$enc_action" ]; then
    act_hit=0
  fi
done

mockingbird $act_hit "action"
parrot "action is valid ($enc_action)"

# target dir check
if [ ! -d $enc_dir ]; then
  echo -e "${c_red}[!] Target directory does not exist! ($enc_dir)${c_clear}"
  exit 1
fi
parrot "target directory found ($enc_dir)"

case $enc_action in
  seal)
    sealSafeCheckDir $enc_dir
    sealDir $enc_dir
  ;;
  unseal)
    unsealSafeCheckDir $enc_dir
    unsealDir $enc_dir
  ;;
  *)
    mockingbird 1 "retardation"
  ;;
esac

parrot "Done!"
