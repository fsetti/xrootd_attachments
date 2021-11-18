#!/bin/bash

#############################################################
#   This script is used by McM when it performs automatic   #
#  validation in HTCondor or submits requests to computing  #
#                                                           #
#      !!! THIS FILE IS NOT MEANT TO BE RUN BY YOU !!!      #
# If you want to run validation script yourself you need to #
#     get a "Get test" script which can be retrieved by     #
#  clicking a button next to one you just clicked. It will  #
# say "Get test command" when you hover your mouse over it  #
#      If you try to run this, you will have a bad time     #
#############################################################

#cd /afs/cern.ch/cms/PPD/PdmV/work/McM/submit/HIG-RunIISummer19UL17DIGIPremix-00197/

# Make voms proxy
voms-proxy-init --voms cms --out $(pwd)/voms_proxy.txt --hours 24
export X509_USER_PROXY=$(pwd)/voms_proxy.txt

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_4/src ] ; then
  echo release CMSSW_10_6_4 already exists
else
  scram p CMSSW CMSSW_10_6_4
fi
cd CMSSW_10_6_4/src
eval `scram runtime -sh`

scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 2.7364s
# Threads for each sequence: 8
# Time per event for single thread for each sequence: 8 * 2.7364s = 21.8912s
# Which adds up to 21.8912s per event
# Single core events that fit in validation duration: 20160s / 21.8912s = 920
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 920 and 10000, but more than 0 -> 920
# It is estimated that this validation will produce: 920 * 1.0000 = 920 events
EVENTS=920


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer19UL17DIGIPremix-00197_1_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:HIG-RunIISummer19UL17DIGIPremix-00197.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer19ULPrePremix-UL17_106X_mc2017_realistic_v6-v1/PREMIX" --conditions 106X_mc2017_realistic_v6 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:HIG-RunIISummer19UL17SIM-00310.root --datamix PreMix --era Run2_2017 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;
