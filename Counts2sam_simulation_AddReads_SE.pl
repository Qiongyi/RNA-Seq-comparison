#!/usr/bin/perl -w
use strict;
use warnings;

##
##      Program name: Counts2sam_simulation_AddReads_SE.pl
##      Author: Qiongyi Zhao 
##      Email: q.zhao@uq.edu.au
##      This script is designed to simulate a .sam file by randomly adding reads based on a count_file and a custom generated .sam file.
##
######################################################################

if(@ARGV != 3) {
    print STDERR "Usage: Counts2sam_simulation_AddReads_SE.pl count_file(eg. S1.count) custom_sam_file AddReads_sam_file\n";
    exit(0);
}

my ($count, $sam, $outf)=@ARGV;

my %hash; # record all genes in which simulation needs to be done by randomly adding reads 
open(IN, $count) or die $!;
while(<IN>){
	chomp;
	if($_=~/\w/){
		my @info=split(/\t/,$_);
		if(@info>=5 && $info[3]>0){
			$hash{$info[0]}= $info[3];
		}
	}
}
close IN;

my %add; # record all aligned reads for each gene
open(IN, $sam) or die $!;
while(<IN>){
	if($_=~/\s+XF:Z:([^\s\n]+)/){
		my $gene_id=$1;
		if(exists $hash{$gene_id}){
			# need to add reads
			$add{$gene_id}.=$_;
		}
	}
}
close IN;

open(OUT, ">>$outf") or die $!;
foreach my $gene_id (keys %add){
	my @reads=split(/\n/,$add{$gene_id});
	for (my $i = $hash{$gene_id}; $i>0 ; $i--) {
			my $random_number = int(rand(@reads));
			print OUT "$reads[$random_number]\n";
	}
}
close OUT;


