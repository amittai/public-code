#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

# amittai
# 2015.03.20 

# released under MIT License (included at end). if you port or update
# this code, i'd appreciate a copy.

# given the vocab stat file, a criterion, and a suffix: collapse words
# into their tags (produce POS$suffix__POS) from a sequence of
# word_POS word_POS ... it doesn't matter what the separator is in the
# tagged file, we're going to output a sequence that uses
# double-underscores "__" as the separator.

## note that this assumes/guarantees that your words are lowercased
## when they're output :)

## to just filter by mincount and ignore ratio, set ratio_min to
## 1,000,000, or set ratio_min=ratio_max.

my $vcb_file = "";
my $tagged_file = "";
my $separator = "_";
my $count_min = 0;
my $ratio_min = 0;
my $ratio_max = 1000000000;
my $tag_suffix = "/low";
GetOptions ("vcb_file=s" => \$vcb_file,
            "tagged_file=s" => \$tagged_file,
	    "separator=s" => \$separator,
	    "count_min=s" => \$count_min,
	    "ratio_min=s" => \$ratio_min,
	    "ratio_max=s" => \$ratio_max,
	    "tag_suffix=s" => \$tag_suffix);
open(VCB, "<$vcb_file") or die "no such vocabulary file $vcb_file: $!";
open(TAGGED, "<$tagged_file") or die "no such tagged corpus file $tagged_file: $!";

my %tag_suffixes;

## go through the vocab file and identify the tag_suffixes that need
## changing. 

while(<VCB>) {
    ## the $vcb_stats.$lang file has as columns: word,
    ## model1_prob/model2_prob, model1_prob, model1_count,
    ## model2_prob, model2_count.  sorted by the prob ratio.
    my @line = split('\s', $_);
    if (($line[3] < $count_min) || ($line[5] < $count_min)){    
	## word fails the minimum count criterion
	## will be collapsed down to "POS/low", or whatever
	## these are the words we're NOT keeping!
	$tag_suffixes{$line[0]}= $tag_suffix;
	next;
    } elsif ( ($line[1] >= $ratio_min)
	      && ($line[1] < $ratio_max) ) {
	## word has empirical frequency ratio within the range of
	## interest (greater than the min, less than the max). the
	## default max ratio is effectively infinity, and default min
	## ratio is 0, so by default all words get changed.
	$tag_suffixes{$line[0]} = $tag_suffix;
	next;
    } 
    ## else: word has at least the minimum count, and ratio is out of
    ## the range of interest, so don't change it.
}

# replace the POS tags of those tag_suffixes with the POS tag plus
# suffix, and also replace the word with the same thing. Eventually
# we're going to strip off the tags and keep the remaining words.
while(<TAGGED>) {
    chomp;
    my @line = split(' ', $_);
    # go through each word in the line
    for my $i (0..$#line) {
        # separator is the last such char in the token (might be doubled?).
        $line[$i] =~ m/(.+)$separator+(\S+)/g;
        my ($word,$tag) = ($1,$2);
	## note that sometimes the tagged text still has case info --
	## not our problem. sometimes we want to pass tagged text
	## through, and we don't want the POS tags lowercased.
        if (defined $tag_suffixes{$word}) {
	    ## these are the words we're not keeping!
            ## this is so that later, when we just keep what's to the
            # right of an underscore, we'll be keeping the tag plus suffix.
            $line[$i]="$tag$tag_suffixes{$word}\_\_$tag$tag_suffixes{$word}";
        } else {
	    $line[$i]="$word\_\_$tag";
	}
    }
    print STDOUT join(" ",@line) ."\n";
}

close VCB;
close TAGGED;
exit;


# The MIT License (MIT)

# Copyright (c) 2015 amittai

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
