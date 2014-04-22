#!/usr/bin/perl -w
use strict;
use warnings;

##
##      Program name: gtf2fas_gene.pl
##      Author: Qiongyi Zhao 
##      Email: q.zhao@uq.edu.au
##      This script is used to generate the gene sequences based on genome sequences and the GTF file.
##
######################################################################

if(@ARGV != 3) {
    print STDERR "Usage: gtf2fas_gene.pl gtf(eg. hg19.gtf) genome.fa(eg. hg19.fasta) outf(output is in .fasta format)\n";
    exit(0);
}

my ($gtf, $fas, $outf)= @ARGV;

my %hash;

my $chr;
open(IN, $fas) or die "Cannot open $fas\n"; 
while(<IN>){
	if($_=~/^>(.+)/){
		$chr=$1;
	}elsif($_=~/\w/){
		chomp;
		$hash{$chr}.=$_;
	}
}
close IN;

print STDERR "$fas has been read into the memory.\n";

my %seq;
my %strand;
open(IN, $gtf) or die "Cannot open $gtf\n"; 
while(<IN>){
	my @info=split(/\t/,$_);
	if($info[2] eq "exon" && $info[8]=~/gene_id "([^"]+)"; transcript_id "([^"]+)";/){
		my $id= "$1 $2";
		$seq{$id}.=substr($hash{$info[0]}, $info[3]-1, $info[4]-$info[3]+1);
		$strand{$id}=$info[6];
	}
}
close IN;

open(OUT, ">$outf") or die $!;
foreach my $key (keys %seq){
	if($strand{$key} eq "+"){
		print OUT ">$key\n$seq{$key}\n";
	}elsif($strand{$key} eq "-"){
		my $seq= &rc($seq{$key});
		print OUT ">$key\n$seq\n";
	}
}
close IN;

##reverse complement
sub rc{
	my $seq=shift;
	$seq=reverse $seq;
  	$seq=~tr/ATCGatcg/TAGCtagc/;
  	return $seq;
}
