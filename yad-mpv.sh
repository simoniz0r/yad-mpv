#!/bin/bash
# Title: yad-mpv
# Author: simonizor
# URL: http://www.simonizor.gq/linuxapps
# Dependencies: mpv, yad
# Description: A simple script that launches a yad GUI for opening files or urls in mpv.  Also has some useful arguments added that can be easily customized.

STARTFILE="$@"
YMDIR="$(dirname $0)"

savesettingsfunc () {
    echo "MPVARGS="\"$MPVARGS\""" > ~/.config/yad-mpv/yad-mpv.conf
}

mpvhelpfunc () {
    yad --html --window-icon="$YMDIR/yad-mpv.png" --title="yad-mpv" --width=600 --height=400 --uri="https://mpv.io/manual/master/#options" --button=gtk-ok:0
    mpvfile "$STARTFILE"
}

mpvfile () {
    . ~/.config/yad-mpv/yad-mpv.conf
    MPVFILE="$(yad --form --window-icon="$YMDIR/yad-mpv.png" --title="yad-mpv" --width=600 --height=400 --button=gtk-close:1 --button=gtk-help:2 --button=gtk-ok:0 --separator="," --item-separator=" " --text="yad-mpv\n\nInput the arguments you would like to run mpv with.\nThen select the files you would like to play or input a url to play (or both).\n\n\n" --field="mpv arguments" "$MPVARGS" --field="File(s)":MFL "" --field="URL(s) and/or file(s)" "$STARTFILE")"
    case $? in
        0)
            MPVARGS="${MPVARGS##,*}"
            if [[ "${MPVARGS::1}" != " " ]]; then
                MPVARGS=" $MPVARGS"
            fi
            savesettingsfunc
            MPVFILE="$(echo "$MPVFILE" | tr ',' ' ')"
            mpvrun
            ;;
        1)
            exit 0
            ;;
        2)
            mpvhelpfunc
            ;;
    esac
}

mpvrun () {
    mpv$MPVFILE
    case $? in
        0)
            if [ ! -f ~/.config/mpv/mpv.conf ]; then
                yad --question --title=yad-mpv --text="Would you like to make a mpv.conf file with the arguments you just used?"
                if [ $? -eq 0 ]; then
                    if [ ! -d ~/.config/mpv ]; then
                        mkdir ~/.config/mpv
                    fi
                    echo " $MPVARGS" | sed -e 's: --:\n:g' > ~/.config/mpv/mpv.conf && yad --window-icon="$YMDIR/yad-mpv.png" --info --title=yad-mpv --width=600 --height=400 --text="Config file written to ~/.config/mpv/mpv.conf"
                fi
            fi
            mpvfile
            ;;
        *)
            yad --error --window-icon="$YMDIR/yad-mpv.png" --title="yad-mpv" --width=600 --height=400 --button=gtk-ok:0 --text="mpv closed unexpectedly!"
            mpvfile
            ;;
    esac
}

if [ ! -d ~/.config/yad-mpv ]; then
    mkdir ~/.config/yad-mpv
fi
if [ ! -f ~/.config/yad-mpv/yad-mpv.conf ]; then
    MPVARGS=" --border=no --vo=opengl --hwdec=vaapi"
    savesettingsfunc
fi
mpvfile "$STARTFILE"