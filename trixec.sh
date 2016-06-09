#!/bin/bash
# Copyright Cédric Picard 2016 -- License WTFPL

HELP="\
Automated discovery toolset

Usage: ${0##*/}

Change the configuration directly in the script
"

##############################################################################
# Configuration
##############################################################################

need_root=true

output_dir=trixec

target_domains=()

target_ranges=()

# Choose here what to launch
todo() {
    launch traceroute 8.8.8.8 &
    launch traceroute yahoo.com &
    launch traceroute gateway &
    launch traceroute $target_domains &
    launch nmap_discover  $target_ranges &
    launch nmap_targetted $target_ranges &
    launch theharverster $target_domains &
    launch dnsenum $target_domains &
}

##############################################################################
# Tool definitions
##############################################################################

launch_traceroute() {
    if [ $# -eq 0 ] ; then
        return 1
    fi

    tcptraceroute "$1"
}

launch_nmap_discover() {
    nmap -sP "$1"
}

launch_nmap_targetted() {
    general_options="-sS --top-ports 2048 -T4 -vvv --reason"
    nmap -AO $general_options "$@"
    nmap -sU $general_options "$@"
}

launch_theharvester() {
    theharvester -b all -d "$1" -v -n -t -h
}

launch_dnsenum() {
    dnsenum --nocolor "$1"
}

##############################################################################
# Internals
##############################################################################

STATUS_FILE="$(mktemp -u)"
export REPORT=""

# do tool args...
launch() {
    local type="$1"

    if [ "$#" -ge 2 ] ; then
        shift
    fi

    while [ $# -ne 0 ] ; do
        local target="$type\e[0m$(if [ "$type" != "$1" ]; then
                                            echo ": $1";
                                         fi)"

        echo -e "\e[33mLaunch \e[0m$target"

        local filename_base="${type}__$1"

        "launch_${type}" "$1" >>"${filename_base}.out" 2>"${filename_base}.err"

        if [ $? -ne 0 ] ; then
            touch "$STATUS_FILE"
            echo -en "\e[31m"
        else
            echo -en "\e[32m"
        fi
        echo -e "Finish \e[0m$1"

        shift
    done
}

launch_() {
    echo "The command you have asked for doesn't exist."
    echo "Please add a function named launch_<command_name>"
    echo "in the 'Tool definition' section of trixec"
    false
}

###############################################################################
# Process management
##############################################################################

if [ $# -ne 0 ] ; then
    echo -e "$HELP"
    exit 1
fi

if [ "$(whoami)" != root ] ; then
    exec sudo "$0" "$@"
fi

mkdir -p "$output_dir"
cd "$output_dir"

todo

wait

echo -e "$REPORT"

if [ -e "$STATUS_FILE" ] ; then
    rm "$STATUS_FILE"
    exit "1"
fi

printf "%s" "[0m[0m __________________ [0m
[0m< SUCCESS!!!!!!!!![0m >[0m
[0m ------------------ [0m[00m
                  [0m\[0m                                [00m
                   [0m\[0m                               [00m
                    [0m\[0m                              [00m
                     [0m\[0m                             [00m
                      [0m\[0m      [38;5;97m▄▄[39m                    [00m
        [38;5;97m▄[48;5;97;38;5;104m▄▄▄▄▄▄▄[48;5;229;38;5;229m█[38;5;104m▄[48;5;104m██[48;5;97m▄[49;38;5;97m▄▄▄▄[39m [38;5;97m▄[48;5;97;38;5;104m▄[48;5;104m██[48;5;97;38;5;97m█[49;39m                    [00m
       [48;5;97;38;5;104m▄[48;5;229;38;5;229m█[48;5;104;38;5;104m██████████████[48;5;153;38;5;153m█[48;5;104;38;5;104m█[48;5;97m▄[48;5;104m████[48;5;110;38;5;255m▄[38;5;153m▄[49;38;5;110m▄[39m                  [00m
      [38;5;97m▄[48;5;104;38;5;104m████[48;5;153m▄[38;5;153m█[38;5;104m▄[48;5;104m███████[48;5;153m▄▄[38;5;153m█[38;5;104m▄[48;5;104m███[38;5;97m▄[48;5;97;38;5;74m▄[48;5;255;38;5;153m▄▄[48;5;153;38;5;255m▄[48;5;110;38;5;153m▄[49m▄[39m                [00m
      [48;5;97;38;5;97m█[48;5;104;38;5;104m█████[38;5;97m▄[38;5;104m██[38;5;229m▄[38;5;104m██[38;5;229m▄[48;5;229m█[48;5;104m▄[38;5;104m█████[38;5;97m▄[48;5;97;38;5;74m▄[48;5;74m██[48;5;67;38;5;16m▄[48;5;153m▄[38;5;153m██[48;5;255;38;5;255m█[49;39m                [00m
       [48;5;153;38;5;153m█[38;5;104m▄▄[48;5;104m█[48;5;97;38;5;97m█[49;39m [38;5;97m▀[38;5;104m▀[38;5;229m▀[48;5;104;38;5;104m██[38;5;153m▄[48;5;229;38;5;104m▄[48;5;104m█████[38;5;97m▄[48;5;74;38;5;74m███[48;5;67m▄[48;5;16;38;5;67m▄[48;5;74m▄[48;5;16;38;5;74m▄[48;5;255m▄▄[48;5;110;38;5;110m█[49;39m  [38;5;110m▄[39m            [00m
       [48;5;104;38;5;97m▄[38;5;104m███[48;5;97;38;5;97m█[49;39m     [48;5;97;38;5;97m█[48;5;104;38;5;104m██████[38;5;97m▄[48;5;97;38;5;74m▄[48;5;16m▄▄▄▄[48;5;74m█████[48;5;110;38;5;153m▄[49;38;5;110m▄▄[48;5;255;38;5;255m█[49;39m  [38;5;60m▄▄▄[39m       [00m
        [38;5;97m▀[48;5;104m▄▄▄[49;38;5;104m▄[38;5;97m▄[39m    [48;5;97;38;5;97m█[48;5;104;38;5;104m███[38;5;97m▄[48;5;97;38;5;74m▄[48;5;74m█[48;5;16;38;5;16m█[48;5;74;38;5;74m██████[48;5;67;38;5;218m▄[49;38;5;74m▀▀[48;5;153;38;5;153m███[38;5;110m▄[49;38;5;60m▄[48;5;60;38;5;74m▄▄[48;5;74m██[48;5;60m▄[49;38;5;60m▄[39m     [00m
            [38;5;97m▀[39m    [48;5;97;38;5;67m▄[48;5;104m▄[48;5;67;38;5;111m▄▄[48;5;97;38;5;67m▄[48;5;74;38;5;74m██████████[48;5;67;38;5;67m█[49m▀[39m [38;5;110m▀▀▀[39m [48;5;60;38;5;74m▄[48;5;74m████[38;5;60m▄[48;5;60m█[49;39m     [00m
                [48;5;67;38;5;67m█[48;5;111;38;5;111m████[48;5;74;38;5;74m█[48;5;67m▄[38;5;67m█[48;5;74m▄[38;5;74m█████[49;38;5;67m▀▀[39m      [48;5;60;38;5;60m█[48;5;74;38;5;74m█████[49;38;5;60m▀[39m      [00m
                [48;5;97;38;5;97m█[48;5;67m▄[48;5;111;38;5;67m▄[38;5;74m▄▄[48;5;74m█████[38;5;67m▄[38;5;97m▄▄▄[38;5;74m█[48;5;67m▄[48;5;97;38;5;97m█[38;5;104m▄[49;38;5;97m▄[39m [48;5;60;38;5;60m█[48;5;74;38;5;74m█████[38;5;60m▄[49m▀[39m       [00m
                    [38;5;67m▀[48;5;74m▄[38;5;74m█████[48;5;67m▄[48;5;104;38;5;67m▄[38;5;104m█[48;5;74;38;5;110m▄[48;5;110;38;5;231m▄[38;5;255m▄[48;5;104;38;5;110m▄[48;5;97;38;5;97m█[48;5;60;38;5;74m▄[48;5;74m████[38;5;60m▄[49m▀[39m         [00m
                [38;5;97m▄▄[48;5;97m█[38;5;104m▄[48;5;104m█[48;5;153;38;5;97m▄[48;5;104m▄[48;5;67m▄[38;5;67m█[48;5;74m▄[38;5;74m████[48;5;97;38;5;67m▄[48;5;110;38;5;74m▄▄[48;5;74m█[48;5;67;38;5;67m█[48;5;74;38;5;74m███[38;5;60m▄[49;39m            [00m
          [38;5;97m▄▄[48;5;97;38;5;104m▄▄▄▄[48;5;104m█[48;5;153;38;5;97m▄▄[48;5;97m███████[48;5;67;38;5;67m█[48;5;74m▄[38;5;74m██[48;5;67m▄[48;5;74m█████[38;5;60m▄[48;5;60;38;5;97m▄[48;5;97m██████[49m▄▄▄[39m    [00m
      [38;5;97m▄▄▄[48;5;97m█████████████████[38;5;67m▄[48;5;67;38;5;74m▄▄[48;5;74;38;5;67m▄[38;5;74m█████[48;5;60;38;5;97m▄[48;5;97m█████████████[49m▄▄[39m[00m
    [38;5;97m▄[48;5;97m█████████[38;5;110m▄▄▄[38;5;97m████████[38;5;67m▄[48;5;74;38;5;74m█████████[48;5;97;38;5;97m██████████████[49m▀▀[39m[00m
  [38;5;97m▄[48;5;97m█████████[38;5;153m▄[48;5;110;38;5;255m▄[48;5;153m▄[48;5;255m█[48;5;153m▄[48;5;110m▄▄[48;5;97m▄▄[38;5;97m█[38;5;67m▄[38;5;74m▄[48;5;67m▄[48;5;74m█████████[38;5;67m▄[48;5;97;38;5;97m██████████[49m▀▀[39m    [00m
     [38;5;97m▀▀[48;5;97m█████[48;5;255;38;5;255m█[38;5;153m▄[48;5;153m█████[48;5;255m▄▄[48;5;67;38;5;67m█[38;5;74m▄[48;5;74m█[48;5;153m▄[48;5;74m████████[48;5;67;38;5;67m█[38;5;97m▄[48;5;97m█████████[49;39m       [00m
         [38;5;97m▀▀▀[48;5;255;38;5;255m█[48;5;153;38;5;153m███[48;5;255;38;5;255m█[38;5;153m▄▄[38;5;110m▄[48;5;153m▄[48;5;74;38;5;74m█[48;5;153m▄[38;5;231m▄[48;5;231m█[48;5;74m▄[38;5;74m█████[38;5;67m▄[48;5;67m█[38;5;97m▄[48;5;97m████████[49m▀[39m        [00m
            [48;5;255;38;5;255m█[48;5;153;38;5;153m███[38;5;255m▄[38;5;153m█[48;5;110;38;5;110m█[49;39m  [48;5;74;38;5;74m█[48;5;153m▄▄[48;5;67;38;5;67m█[48;5;74;38;5;74m███[48;5;67;38;5;67m█[48;5;74;38;5;74m█[48;5;67;38;5;60m▄[49;39m                    [00m
            [48;5;255;38;5;255m█[48;5;153;38;5;153m███[48;5;255;38;5;255m█[48;5;153m▄[48;5;110;38;5;153m▄[49;38;5;110m▄[39m [48;5;74;38;5;74m█[48;5;153m▄[48;5;74m████[38;5;67m▄[48;5;67m██[48;5;60;38;5;74m▄[49;38;5;60m▄[39m                   [00m
            [48;5;255;38;5;255m███[48;5;153;38;5;153m██[48;5;255;38;5;255m█[48;5;153;38;5;153m██[48;5;110;38;5;110m█[49;38;5;67m▀[48;5;74m▄[38;5;74m███[48;5;67;38;5;67m█[49;38;5;60m▀[48;5;74m▄[38;5;74m███[48;5;60;38;5;60m█[49;39m                  [00m
            [48;5;110;38;5;110m█[48;5;255;38;5;255m██[48;5;153;38;5;153m██[48;5;255;38;5;255m██[48;5;153;38;5;153m█[48;5;110;38;5;110m█[49;39m [48;5;67;38;5;67m█[48;5;74;38;5;74m███[48;5;67m▄[49;38;5;67m▄[38;5;60m▀[48;5;74m▄[38;5;74m██[48;5;60m▄[38;5;60m█[49;39m                 [00m
          [48;5;110;38;5;110m█[49m▄▄[48;5;110;38;5;255m▄[48;5;153;38;5;153m██[48;5;110;38;5;110m█[48;5;153;38;5;153m███[48;5;110;38;5;110m█[49;39m [38;5;67m▀[48;5;74m▄[38;5;74m███[48;5;67;38;5;67m█[49;39m [48;5;60;38;5;60m█[48;5;74;38;5;74m███[48;5;60m▄[49;38;5;60m▄[39m                [00m
          [48;5;110;38;5;110m█[48;5;255;38;5;255m█[38;5;153m▄[48;5;153m██[38;5;110m▄[38;5;153m██[38;5;110m▄▄[49m▀[39m  [48;5;67;38;5;67m█[48;5;74;38;5;74m███[48;5;67m▄[49;38;5;67m▄[38;5;60m▀[48;5;74;38;5;74m████[48;5;60;38;5;60m█[49;39m                [00m
           [38;5;110m▀▀[38;5;153m▀[38;5;110m▀[38;5;153m▀[38;5;110m▀▀[39m     [38;5;67m▀[48;5;74m▄▄▄▄[48;5;67m█[49;39m [38;5;60m▀▀▀▀▀[39m                [00m
"
exit 0
