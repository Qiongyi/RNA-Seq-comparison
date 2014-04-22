#!/usr/bin/perl -w
use strict;
use warnings;

##
##      Program name: Generate_fasta_SE.pl
##      Author: Qiongyi Zhao 
##      Email: q.zhao@uq.edu.au
##      This script is used to generate all possible reads from a given list of genes based on gene sequences 
##		generated from (2) and a gene list generated from (1). The output is in fasta format. The read lenght 
##		is adjustable and should be set in the first parameter.
##
######################################################################

if(@ARGV != 4) {
    print STDERR "Usage: Generate_fasta_SE.pl read_length(eg. 35) gene.add.list.txt gene_seq outf_fasta\n";
    exit(0);
}

my ($read_len, $gene_list, $inf, $outf)= @ARGV;

my %hash; ## to store gene sequences

open(IN, $inf) or die "Cannot open $inf\n"; 
while(<IN>){
	if($_=~/^>([^\s]+)/){
		my $seq=<IN>;
		chomp($seq);
		push(@{$hash{$1}}, $seq);
	}
}
close IN;

open(OUT, ">$outf") or die "Cannot open $outf\n"; 
open(IN, $gene_list) or die "Cannot open $gene_list\n"; 
while(<IN>){
	if($_=~/\w/){
		chomp;
		my $count=0;
		foreach my $seq (@{$hash{$_}}){
			for(my $i=0; $i<=length($seq)-$read_len; $i++){
				$count++;
				my $read=substr($seq, $i, $read_len);
				print OUT ">$_.S$count\n$read\n";
				$count++;
				$read= &rc($read);
				print OUT ">$_.S$count\n$read\n";
			}
		}
	}
}
close IN;
close OUT;


##reverse complement
sub rc{
	my $seq=shift;
	$seq=reverse $seq;
  	$seq=~tr/ATCGatcg/TAGCtagc/;
  	return $seq;
}
