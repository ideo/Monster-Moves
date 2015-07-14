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

indir="24fps/"$1"/"

# outdir="../Resources/images/"$device"/actors/"$1"/"
outdir="out24/"$device"/actors/"$1"/"

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
                 --opt RGBA8888 \
                 --texture-format png \
                 --trim-mode Trim \
                 --png-opt-level 7 \
                 --size-constraints POT \
                 --padding 1 \
                 --scale 0.9375 \
                 --sheet $sheet $tmpDir

  rm -rf $tmpDir/*

}


packAction $1 "eggIdle" 0 18
packAction $1 "eggCrack" 19 20
packAction $1 "crackEntrance" 21 79
packAction $1 "moveRight" 80 99
packAction $1 "moveLeft" 100 119
packAction $1 "moveForward" 120 139
packAction $1 "exit" 140 159
packAction $1 "idle" 160 199
packAction $1 "reaction1" 200 219
packAction $1 "reaction2" 220 239
packAction $1 "reaction3" 240 259
packAction $1 "reaction4" 260 279
packAction $1 "dance1" 280 339
packAction $1 "dance2" 340 399
packAction $1 "dance3" 400 459
packAction $1 "dance4" 460 519
packAction $1 "dance5" 520 579
packAction $1 "dance6" 580 639
packAction $1 "dance7" 640 699
packAction $1 "dance8" 700 759
