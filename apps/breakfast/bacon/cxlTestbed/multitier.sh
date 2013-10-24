#!/bin/bash

function runTestbed(){
  testDuration=$((60 * 60))
  installTS=$(date +%s)
  for i in $(seq 2)
  do
    ./testbed.sh installTS $installTS $@
    sleep 60
  done
  sleep $testDuration
  pushd .
  cd ~/tinyos-2.x/apps/Blink
  ./burn map.all
  sleep 60
  popd
}

while true
do
  #multitier: fix frames per slot, vary routers, test at idle and
  # active
  for map in map.flat map.patches.4 map.patches.8 
  do
    for ppd in 0 50 
    do
      runTestbed efs 1 ppd $ppd map $map mdr 100 fps 60 td 0 tpl 128
    done
  done
  
  #overhead: fix frames per slot, vary packets per download
  for ppd in 25 50 100
  do
    runTestbed efs 1 ppd $ppd map map.flat mdr 100 fps 60 td 0 tpl 128
  done

  #overhead: fix packets per download, vary frames per slot
  for fps in 30 60 90 120
  do
    runTestbed efs 1 ppd 50 map map.flat mdr 100 fps $fps td 0 tpl 128
  done
  
done
