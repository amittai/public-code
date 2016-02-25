#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

# amittai
# 2014.03.10

# released under MIT License (included at end). if you port or update
# this code, i'd appreciate a copy.

my $corpus = "";
my $vcb_file = "";
my $print_singletons;

GetOptions ("corpus=s" => \$corpus,
            "vcb_file=s" => \$vcb_file,
            "print_singletons" => \$print_singletons);
open(CORPUS, "<$corpus") or die "no such file $corpus: $!";
open(VCB, ">$vcb_file") or die "no such vocabulary file $vcb_file: $!";
open(SINGLE, ">$vcb_file.singles") or die "no such vocabulary file $vcb_file.singles: $!" if ($print_singletons);

my %words;
my $corpus_size=0;
while(<CORPUS>) {
    chomp;
    # increment counter for each word in file
    foreach my $token (split(' ', $_)) {
        $words{$token}++;
        $corpus_size++;
    }
}

# sorts by word count (decreasing) and then alphabetically (increasing)
foreach ( sort { ($words{$b} <=> $words{$a}) || ($a cmp $b) } (keys %words) ) {
    my $token = $_;
    my $count=$words{$token};
    # print the word, prob, and count
    print VCB "$token\t". sprintf("%.10f",$count/$corpus_size) ."\t$count\n";
    print SINGLE "$token\t". sprintf("%.10f",$count/$corpus_size) ."\t$count\n" 
        if (($print_singletons) && ($words{$token} < 2));
}

close CORPUS;
close VCB;
close SINGLE;
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
