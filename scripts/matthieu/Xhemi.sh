#!/bin/bash

SUBJECTS_DIR=$1
subject=$2
  
surfreg --s ${subject} --t fsaverage_sym --lhrh
surfreg --s ${subject} --t fsaverage_sym --lhrh --xhemi