#!/bin/bash

# echo $1

TEXTUREPACKER=/usr/local/bin/TexturePacker

TINYPNG_APIKEY="nUeW3ZEDF5fW2JHiwl06XGk8Y_E4hy7M"

# if [ -z "$1" ]
#   then
#   echo "Usage packtexture actorName [device]"
#   exit -1
# fi

packAction()
{

  indir="20fps/"$1"/"

  scale=1.0

  if [ "$2" = "iPhone" ]
    then
    scale=0.6
  fi

  outdir="out20/"$device"/actors/"$1"/"

  # echo "Packing action "$3" of "$1" for device "$2" from "$4" to "$5" scale : "$scale

  if [ ! -d "$outdir" ]; then
    mkdir -p $outdir
  fi

  tmpDir="tmp"

  # echo $outdir

  if [ ! -d "$tmpDir" ]; then
    mkdir -p $tmpDir
  fi

  rm -rf $tmpDir/*

  for (( i=$4; i<=$5; i++ ))
  do
    infile=$indir$(printf "%s%04d.png" $1 $i)
    # echo $infile
    cp -f $infile $tmpDir
  done

  plist=$outdir$3".plist"
  # echo $plist
  sheet=$outdir$3".png"
  # echo $sheet
  #  --premultiply-alpha \
  #  --scale 0.9375 \
  #  --png-opt-level 1 \
  # --size-constraints POT \
  #--force-squared \
  #--force-word-aligned \
  $TEXTUREPACKER --data $plist \
                 --format cocos2d \
                 --max-width 4096 \
                 --max-height 4096 \
                 --opt RGBA8888 \
                 --texture-format png \
                 --trim-mode Trim \
                 --size-constraints POT \
                 --scale $scale \
                 --padding 1 \
                 --sheet $sheet $tmpDir

  rm -rf $tmpDir/*

}

packAllActions()
{
  # echo "Packing "$1" for device "$2
  packAction $1 $2 "eggIdle" 0 14
  packAction $1 $2 "eggCrack0" 15 16
  packAction $1 $2 "eggCrack1" 17 17
  packAction $1 $2 "crackEntrance" 18 49
  packAction $1 $2 "moveRight" 50 99
  packAction $1 $2 "moveLeft" 100 149
  packAction $1 $2 "moveForward" 150 199
  packAction $1 $2 "exit" 200 219
  packAction $1 $2 "idle" 220 249
  packAction $1 $2 "reaction1" 250 266
  packAction $1 $2 "reaction2" 267 283
  packAction $1 $2 "reaction3" 284 299
  packAction $1 $2 "dance1" 300 349
  packAction $1 $2 "dance2" 350 399
  packAction $1 $2 "dance3" 400 449
  packAction $1 $2 "dance4" 450 499
  packAction $1 $2 "dance5" 500 549
  packAction $1 $2 "dance6" 550 599
  packAction $1 $2 "dance7" 600 649
  packAction $1 $2 "dance8" 650 699
  packAction $1 $2 "idle0" 700 700
}

packMonster()
{
  device="iPad"
  scale=1.0

  if [ "$2" = "iPhone" ]
    then
    device=$2
    scale=0.6
  fi
  packAllActions $1 $device
}

packiPadMonsters()
{
  packMonster "LeBlob" "iPad"
  packMonster "Sausalito" "iPad"
  packMonster "Guac" "iPad"
  packMonster "Pom" "iPad"
  packMonster "Meep" "iPad"
  packMonster "Freds" "iPad"
}

packiPhoneMonsters()
{
  packMonster "LeBlob" "iPhone"
  packMonster "Sausalito" "iPhone"
  packMonster "Guac" "iPhone"
  packMonster "Pom" "iPhone"
  packMonster "Meep" "iPhone"
  packMonster "Freds" "iPhone"
}

# packiPadMonsters
# packiPhoneMonsters
packMonster "Pom" "iPhone"
