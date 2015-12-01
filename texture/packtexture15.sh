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

  indir="15fps/"$1"/"

  scale=0.9375

  if [ "$2" = "iPhone" ]
    then
    scale=0.65
  fi

  outdir="out15/"$device"/actors/"$1"/"

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
                 --padding 0 \
                 --sheet $sheet $tmpDir

  rm -rf $tmpDir/*

}

packAllActions()
{
  # echo "Packing "$1" for device "$2
  packAction $1 $2 "eggIdle" 0 10
  packAction $1 $2 "eggCrack0" 11 12
  packAction $1 $2 "eggCrack1" 13 13
  packAction $1 $2 "crackEntrance" 14 37
  packAction $1 $2 "moveRight" 38 74
  packAction $1 $2 "moveLeft" 75 112
  packAction $1 $2 "moveForward" 113 149
  packAction $1 $2 "exit" 150 164
  packAction $1 $2 "idle" 165 187
  packAction $1 $2 "reaction1" 188 199
  packAction $1 $2 "reaction2" 200 212
  packAction $1 $2 "reaction3" 213 224
  packAction $1 $2 "dance1" 225 262
  packAction $1 $2 "dance2" 263 299
  packAction $1 $2 "dance3" 300 337
  packAction $1 $2 "dance4" 338 374
  packAction $1 $2 "dance5" 375 412
  packAction $1 $2 "dance6" 413 449
  packAction $1 $2 "dance7" 450 487
  packAction $1 $2 "dance8" 488 525
  packAction $1 $2 "idle0" 526 526
}

packMonster()
{
  device="iPad"

  if [ "$2" = "iPhone" ]
    then
    device=$2
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
# packMonster "Meep" "iPad"
# packMonster "Guac" "iPad"
# packMonster "Sausalito" "iPad"
#
# packMonster "Freds" "iPhone"
packMonster "Meep" "iPhone"
# packMonster "Sausalito" "iPhone"
