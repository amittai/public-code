#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

# amittai
# 2014

# released under MIT License (included at end). if you port or update
# this code, i'd appreciate a copy.

## 2014.11.08 given two files, each with a set of words,
## probabilities, and counts for a different corpus, merge and produce
## a list of # words, counts, probabilities, and the ratio of
## probabilities across # the corpora. usually used as model1 =
## in-domain task and model2 = # general data. so the ratio is "number
## of times more likely the word # is in the in-domain corpus than in
## the general corpus".

## 2015.06.04 if a word is only in one corpus, than the ratio is twice
## what it would have been if the word had appeared once in the other
## # corpus. that is, we smooth the count in the other corpus to be
## 0.5.  No real reason, just seems like we shouldn't ignore words
## that appear lots in one corpus but not at all in the other, and it
## should be more skewed than if it had been a singleton.

my $model1 = "";
my $model2 = "";
#my $outfile = "";
#my $mincount = 0; # minimum count
#my $factor = 1;  # minimum bias factor

GetOptions ("model1=s" => \$model1,
            "model2=s" => \$model2);
#            "outfile=s" => \$outfile,
#            "mincount=i" => \$mincount,
#            "factor=s" => \$factor);
open(MODEL1, "<$model1") or die "no such model1 file $model1: $!";
open(MODEL2, "<$model2") or die "no such model2 file $model2: $!";
#open(OUT, ">$outfile") or die "can't open output file $outfile: $!";

my %words1;
while(<MODEL1>) {
    chomp;
    ## read in triples {word, prob, count} in model1
    my @line1 = split(' ',$_);
    $words1{$line1[0]}{prob} = sprintf("%.10f",$line1[1]);
    $words1{$line1[0]}{count} = $line1[2];
}

#my $counter = 0;
while(<MODEL2>) {
    chomp;
    ## model2 contains same triples {word, prob, count}
    my @line2 = split(' ', $_);
    my $word = $line2[0];
    ## first the word itself
    my @output = ($word);
    ## compute the delta of the probabilities.
    ## if word $line2[1] was also in Model 1, produce the ratio of
    ## probs Model1/Model2. else just say... 1/(2*count_model2)?.  delta
    ## column should be the change _from_ model 1 score, because
    ## model1 is the in-domain (so delta * model 2 = model 1).
    (defined $words1{$word}{count})
        ? ($output[1] = sprintf("%.10f", ($words1{$word}{prob} / $line2[1])))
        : ($output[1] = sprintf("%.10f", (0.5 / $line2[2])) );
    ## same thing for the model1 probability and count
    (defined $words1{$word}{count}) 
        ? ($output[2] = $words1{$word}{prob})
        : ($output[2] = 0);
    (defined $words1{$word}{count} > 0) 
        ? ($output[3] = $words1{$word}{count})
        : ($output[3] = 0);
    ## now the model2 probability and count
    $output[4] = sprintf("%.10f",$line2[1]);
    $output[5] = $line2[2];
    ## print out all words
    if (defined $line2[2]) {
#	 && ($output[3] >= $mincount) 
#	 && ($line2[2] >= $mincount) 
#	 && (
#	     ($output[1] >= $factor)
#	     || ( ($line2[1]/$words1{$word}{prob})
#		  >= $factor )
#	    )
#       ){
	print STDOUT join("\t", @output) . "\n";
    }
    ## remove the word from model1
    delete $words1{$word};
}

## any remaining elements of Model1 aren't in Model2. Set to
## 2*count_model1.
#    if ($mincount == 0) {
foreach my $word (keys %words1) {
    # set ratio to 0, produce the model1 probability and count, set model2 to zero.
    my @output = ($word,
		  2*$words1{$word}{count},
		  sprintf("%.10f",$words1{$word}{prob}),
		  $words1{$word}{count},
		  0, 0); 
    print STDOUT join("\t", @output) . "\n";
}
#}
close MODEL1;
close MODEL2;
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
