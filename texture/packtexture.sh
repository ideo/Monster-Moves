#!/bin/bash

# echo $1

TEXTUREPACKER=/usr/local/bin/TexturePacker

device="iPad"

if [ -z "$1" ]
  then
  echo "Usage packtexture actorName [device]"
  exit -1
fi

if [ "$2" ]
  then
  device=$2
fi

indir="actors/"$1"/"

# outdir="../Resources/images/"$device"/actors/"$1"/"
outdir="out/"$device"/actors/"$1"/"

if [ ! -d "$outdir" ]; then
  mkdir -p $outdir
fi

packAction()
{

  tmpDir="tmp"

  # echo $outdir

  if [ ! -d "$tmpDir" ]; then
    mkdir -p $tmpDir
  fi

  rm -rf $tmpDir/*

  for (( i=$3; i<=$4; i++ ))
  do
    infile=$indir$(printf "%s%04d.png" $1 $i)
    # echo $infile
    cp -f $infile $tmpDir
  done

  plist=$outdir$2".plist"
  # echo $plist
  sheet=$outdir$2".png"
  # echo $sheet
  #  --premultiply-alpha \
  $TEXTUREPACKER --data $plist \
                 --format cocos2d \
                 --max-width 4096 \
                 --max-height 4096 \
                 --opt RGBA4444 \
                 --texture-format png \
                 --trim-mode Trim \
                 --png-opt-level 7 \
                 --size-constraints POT \
                 --padding 1 \
                 --scale 0.9375 \
                 --sheet $sheet $tmpDir

  rm -rf $tmpDir/*

}


packAction $1 "eggIdle" 0 22
packAction $1 "eggCrack" 23 25
packAction $1 "crackEntrance" 26 99
packAction $1 "moveRight" 100 124
packAction $1 "moveLeft" 125 149
packAction $1 "moveForward" 150 174
packAction $1 "exit" 175 199
packAction $1 "idle" 200 249
packAction $1 "reaction1" 250 274
packAction $1 "reaction2" 275 299
packAction $1 "reaction3" 300 324
packAction $1 "reaction4" 325 349
packAction $1 "dance1" 350 424
packAction $1 "dance2" 425 499
packAction $1 "dance3" 500 574
packAction $1 "dance4" 575 649
packAction $1 "dance5" 650 724
packAction $1 "dance6" 725 799
packAction $1 "dance7" 800 874
packAction $1 "dance8" 875 949
