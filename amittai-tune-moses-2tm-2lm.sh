#!/bin/sh -xe
# amittai, 2014 jun 06
# tune a 2TM 2LM Moses system
# released under MIT License (included at end). if you port or update
# this code, i'd appreciate a copy.

# set up
dir_sys_baseline=PATH_TO_SYSTEM_1
dir_sys_other=PATH_TO_SYSTEM_2
baseline=NAME_OF_SYSTEM_1
other=NAME_OF_SYSTEM_1
exp=PATH_TO_2TM2LM_SYSTEM
mkdir -p  $exp
mkdir -p  $exp/lm
mkdir -p  $exp/model
mkdir -p  $exp/tuning
cd  $exp/

## pull the two trained systems. first get baseline system:
cp  $dir_sys_baseline/model/moses.ini.1 \
    $exp/model/moses.$baseline.ini
cp  $dir_sys_baseline/model/phrase-table.1.gz \
    $exp/model/phrase-table.$baseline.gz
cp $dir_sys_baseline/model/reordering-table.1.wbe-msd-bidirectional-fe.gz \
    $exp/model/reordering-table.wbe-msd-bidirectional-fe.$baseline.gz
cp $dir_sys_baseline/lm/lm.1.gz \
    $exp/lm/lm.$baseline.gz

## now get the other system:
cp  $dir_sys_other/model/moses.ini.1 \
    $exp/model/moses.$other.ini
cp  $dir_sys_other/model/phrase-table.1.gz \
    $exp/model/phrase-table.$other.gz
cp $dir_sys_other/model/reordering-table.1.wbe-msd-bidirectional-fe.gz \
    $exp/model/reordering-table.wbe-msd-bidirectional-fe.$other.gz
cp $dir_sys_other/lm/lm.1.gz \
    $exp/lm/lm.$other.gz

## modify the config file to include both TM and both LMs. steps:
#  . change current $exp dir
#  . add "1 T 1" to score with either TM
#  . change first phrase table to phrase-table.$baseline
#  . add second phrase table
#  . change the (only) reordering table to phrase-table.$other.$n (assume $other is much larger, so has better reordering)
#  . add second language model
#  . add weights for second phrase table
#  . add weights for second language model
sudo cat ~/exp/$exp/model/moses.$baseline.ini                \
  | perl -pe 's/'"$dir_sys_baseline"'/'"$exp"'/'              \
  | perl -pe 's/(0 T 0)/$1\n1 T 1/'                            \
  | perl -pe 's/phrase-table\.1/phrase-table\.'"$baseline"'/'   \
  | perl -pe 's/(PhraseDictionaryMemory .*)$/$1\nPhraseDictionaryMemory name=TranslationModel1 table-limit=20 num-features=5 path='"$exp"'\/model\/phrase-table\.'"$other"'\.'"$n"' input-factor=0 output-factor=0/'    \
  | perl -pe 's/(reordering-table)\.1\.(wbe-msd-bidirectional-fe)\.gz/$1\.$2\.'"$other"'\.'"$n"'\.gz/'    \
  | perl -pe 's/^(.*)\/lm.1 (order=4)/$1\/lm\.'"$baseline"'\.gz $2\nKENLM lazyken=0 name=LM1 factor=0 path='"$exp"'\/lm\/lm\.'"$other"'\.'"$n"'\.gz order=4/'                  \
  | perl -pe 's/(TranslationModel0= .*)/$1\nTranslationModel1= 0\.2 0\.2 0\.2 0\.2 0\.2/' \
  | perl -pe 's/(LM0= 0.5)/$1\nLM1= 0\.5/'                                                 \
  > $exp/model/moses.2TM-2LM.untuned.ini

# run MERT manually
date
sudo  nohup  /opt/mosesdecoder/scripts/training/mert-moses.pl \
  $dev_set.en  $dev_set.fr    /opt/mosesdecoder/bin/moses      \
  $exp/model/moses.2TM-2LM.untuned.ini                          \
  --nbest 100  --working-dir $exp/tuning                         \
  --decoder-flags "-search-algorithm 1 -cube-pruning-pop-limit 5000 -s 5000 -threads all" \
  --rootdir  /opt/mosesdecoder/scripts                             \
  -mertdir /opt/mosesdecoder/bin  >  $exp/tuning/log.txt

exit;

# The MIT License (MIT)

# Copyright (c) 2014 amittai

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#####
# eof
