#!/usr/bin/perl -w
use strict;
use warnings;
use List::Util qw(shuffle);

##
##      Program name: subsample_fastq_single_range.pl
##      Author: Qiongyi Zhao 
##      Email: q.zhao@uq.edu.au
##      This script is used to subsample Illumina single end reads. It will generate a random number between "read_num1" and "read_num2" for subsamling.
##      The input fastq file can be gzipped file (file name ends with .gz, eg. XXX.fq.gz or XXX.fastq.gz) or normal unzipped fastq file (eg. XXX.fq or XXX.fastq)
##
######################################################################

if(@ARGV != 4) {
    print STDERR "Usage: subsample_fastq_single_range.pl read_num1(min) read_num2(max) input_fq(only for gzipped or unzipped file format) output_fq\n";
    exit(0);
}
my ($min_num, $max_num, $inf, $outf)= @ARGV;

my %read;

if($inf=~/\.gz$/){
  ### read a gzip fastq file
  open(IN, "gunzip -c $inf |") or die "can't open pipe to $inf\n";
}else{
  ### read an unzipped fastq file
  open(IN, $inf) or die "can't open $inf\n";
}

my $tmp_count=0;
while (my $line1=<IN>) {
   if ($line1=~/^@/){
   		my $line2=<IN>;
   		my $line3=<IN>;
   		my $line4=<IN>;
   		my $string=$line1.$line2.$line3.$line4;
      $tmp_count++;
      $read{$tmp_count}=$string;
   	}else{
      print STDERR "File format ERROR in $inf, pay attention!!! $line1\n";
    }
}
close(IN);


print STDERR "Fastq file $inf has been read into the memory.\n";

my @array= shuffle(keys %read);

my $total_reads= scalar(@array);

if($total_reads>=$max_num){
	print STDERR "Total number of fragments is ".$total_reads.". Your request is sub-sampling for $min_num - $max_num fragments.\n";
}else{
	print STDERR "Wrong!!! Total number of fragments for $inf is less than what you requested!\n"; exit;
}

my $tmp= $max_num - $min_num; 
my $number=$min_num+int(rand($tmp));

my $stat_out="Subsample_number_of_reads.stats.xls";
open(STAT, ">>$stat_out") or die "Cannot open $stat_out\n";
print STAT "$inf\t$number\n";
close STAT;

my $number_of_reads=0;
open(OUT,">$outf") or die "Cannot open $outf\n";
while($number_of_reads<$number-1000){
	my $total=@array-1000;
	my $i=int(rand($total));
	for(my $j=0;$j<1000;$j++){
		print OUT $read{$array[$i+$j]};
  }
	$number_of_reads+=1000;
	splice(@array,$i,1000);
}

while($number_of_reads<$number){
  my $total=@array-1;
  my $i=int(rand($total));
  print OUT $read{$array[$i]};
  $number_of_reads++;
  splice(@array,$i,1);
}

close(OUT);

exit;
