#!/bin/bash
PS1='┌[\[\e[1;34m\]\u@\h\[\e[0m\] \[\e[1;36m\]\s \v\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]]\n└─ \\$ '
export LS_OPTIONS='--color=auto'
eval "$(dircolors -b)"

complete -F _command d
complete -F _command de

#Aliases
alias pacman='sudo pacman'
alias killyourself='poweroff'
alias ls='ls $LS_OPTIONS'
alias wifereset='systemctl restart NetworkManager.service'
alias searchit='d firefox --private-window'
alias gamingtime='d steam && d discord'
alias updatemirror='sudo reflector --country France,Germany,Romania,SK,CZ,Moldova,Hungary,Bulgaria,Poland,Ukraine --age 18 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'
alias funzip='for i in *.zip; do ark -ab "$i"; done'
alias bsource='. ~/.bashrc'
#Binds
bind '"\x08":backward-kill-word'

#Functions
function d() {
  setsid -f -- "$@" 0<&- &>/dev/null
}

function de() {
  d "$@"
  exit
}

function wakeserver() {
  #wol 18:a9:05:95:57:68 -p 9
  wol c8:5b:76:53:ad:aa -p 9
}

function mntwin() {
  case $1 in
  -u)
    #unmount command, man I hate dolphin
    sudo umount /mnt/uindos
    ;;
  *)
    #echo "Haha, Dolphin got its shit together, not needed anymore :)"
    #so that was a fucking lie
    echo "GODDAMNIT"
    sudo ntfs-3g /dev/sda3 /mnt/uindos
    ;;
  esac
}

function ffshrink() {
  for name in "$@"; do
    input="$name"
    output="$HOME/Videos/Compressed/${input%.*}-comp.${input##*.}"

    #ffmpeg -i $input -vcodec h264 -b:v 1000k -an $output
    #this one leaves no sound

    yes | ffmpeg -i $input -vcodec libx265 -crf 24 $output >/dev/null

    if [[ -f $output ]]; then
      i_size=$(du $input | awk '{print $1}')
      o_size=$(du $output | awk '{print $1}')

      echo "Input file size: $(du -h $input | awk '{print $1}')"
      echo "Output file size: $(du -h $output | awk '{print $1}')"
      echo "Compression percent: $(echo $(echo "scale=3; perc = ${o_size} / $i_size * 100; perc" | bc -l) | sed 's/\([0-9]*\.[0-9]*[1-9]\)0*$/\1/')%"
      echo
      mv $input $HOME/Videos/Raw/
    else
      echo "bro ts don\'t exist no mo"
      echo
    fi
  done
}

function ffboost() {
  for name in "$@"; do
    input="$name"
    ffmpeg -i $input -filter:a "volume=2.0" tmp.mp3
    mv tmp.mp3 $input
  done
}

function ffextract() {
  for name in "$@"; do
    input="$name"
    output="$HOME/Music/Things/Unlistened/${input%.*}-audio.mp3"

    yes | ffmpeg -i $input -vn $output

    if [ -e $output ]; then
      echo "Audio extracted"
    else
      echo "bro ts don\'t exist"
    fi
  done
}

function fix-flac-data() {
  declare -i max=0
  for name in "$@"; do
    metaflac --preserve-modtime --remove-tag TRACKNUMBER "$name"
    max=$max+1
  done
  max=$max-1

  declare -i i=1
  for name in "$@"; do
    metaflac --preserve-modtime --set-tag "TRACKNUMBER=$i/$max" "$name"
    i=$i+1
  done
}

function mount.gentoo() {
  sudo mount /dev/sdb4 /mnt/gentoo/ -o subvol=/@
  sudo mount /dev/sdb4 /mnt/gentoo/home -o subvol=/@home
  sudo mount /dev/sdb4 /mnt/gentoo/var/cache/ -o subvol=/@pkg
  sudo mount /dev/sdb1 /mnt/gentoo/efi

  sudo arch-chroot /mnt/gentoo
}

function umount.gentoo() {
  sudo umount -R /mnt/gentoo
}




fortune | cowsay -e *o
# cowsay -e -- Study for your exams, you won\'t pass otherwise...

[ -f "/home/dumi/.ghcup/env" ] && . "/home/dumi/.ghcup/env" # ghcup-env

# pnpm
export PNPM_HOME="/home/dumi/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
