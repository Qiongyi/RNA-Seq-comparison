#!/usr/bin/perl -w
use strict;
use warnings;

##
##      Program name: Counts2sam_simulation_DelReads_SE.pl
##      Author: Qiongyi Zhao 
##      Email: q.zhao@uq.edu.au
##      This script is used to generate a .sam file by randomly delete aligned reads based on a count_file and an existing .sam file. 
## 		It will also generate a list of genes in which simulation needs to be done by randomly adding reads by another script named as 
##		"Counts2sam_simulation_AddReads_SE.pl".
##
######################################################################

if(@ARGV != 3) {
    print STDERR "Usage: Counts2sam_simulation_DelReads_SE.pl count_file(eg. S1.count) original_sam_file new_sam_file\n";
    exit(0);
}

my ($count, $sam, $outf)=@ARGV;

my %hash;
open(IN, $count) or die $!;
while(<IN>){
	chomp;
	if($_=~/\w/){
		my @info=split(/\t/,$_);
		if(@info>=5 && $info[3]!=0){
			$hash{$info[0]}= $info[3];
		}
	}
}
close IN;

my %add; # for genes need to add reads
my %del; # for genes need to delete reads

open(OUT, ">$outf") or die $!;
open(IN, $sam) or die $!;
while(<IN>){
	if($_=~/\s+XF:Z:([^\s\n]+)/){
		my $gene_id=$1;
		if(exists $hash{$gene_id} && $hash{$gene_id}>0){
			# genes need to add reads
			print OUT $_;
			$add{$gene_id}=1;
		}elsif(exists $hash{$gene_id} && $hash{$gene_id}<0){
			# genes need to delete reads
			$del{$gene_id}.=$_;
		}else{
			# genes need to keep the original reads
			print OUT $_;
		}
	}
}
close IN;

### randomly delete aligned reads
for my $key (keys %del){
 	my @info=split(/\n/,$del{$key});
	for (my $i = $hash{$key}; $i<0 ; $i++) {
			my $random_number = int(rand(@info));	
			splice(@info, $random_number, 1);
	}
	if(@info>=1){
			my $remain= join "\n", @info;
			print OUT "$remain\n";
	}
}
close OUT;

### generate a list of genes in which simulation needs to be done by randomly adding reads
if($count=~/([^\/]+)$/){
	my $outf_gene_add="tmp.$1.gene.add.list.txt";
	open(OUT, ">$outf_gene_add") or die "Cannot open $outf_gene_add\n";
	for my $key (keys %add){
		print OUT "$key\n";
	}
	close OUT;
}

