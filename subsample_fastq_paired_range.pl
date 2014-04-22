#!/usr/bin/perl -w
use strict;
use warnings;
use List::Util qw(shuffle);

##
##      Program name: subsample_fastq_paired_range.pl
##      Author: Qiongyi Zhao 
##      Email: q.zhao@uq.edu.au
##      This script is used to subsample Illumina paired-end reads. It will generate a random number between "read_num1" and "read_num2" for subsamling.
##      The input fastq file can be gzipped file (file name ends with .gz, eg. XXX.fq.gz or XXX.fastq.gz) or normal unzipped fastq file (eg. XXX.fq or XXX.fastq)
##
######################################################################

if(@ARGV != 6) {
    print STDERR "Usage: subsample_fastq_paired_range.pl read_num1(min) read_num2(max) input_fq1(only for gzipped or unzipped file format) input_fq2 output_fq1 output_fq2\n";
    exit(0);
}
my ($min_num, $max_num, $inf1, $inf2, $outf1, $outf2)= @ARGV;

my %read1;
my %read2;

#my @array1=(); my @array2=();

if($inf1=~/\.gz$/){
  ### read a gzip fastq file
  open(IN1, "gunzip -c $inf1 |") or die "can't open pipe to $inf1\n";
}else{
  ### read an unzipped fastq file
  open(IN1, $inf1) or die "can't open $inf1\n";
}

if($inf2=~/\.gz$/){
  ### read a gzip fastq file
  open(IN2, "gunzip -c $inf2 |") or die "can't open pipe to $inf2\n";
}else{
  ### read an unzipped fastq file
  open(IN2, $inf2) or die "can't open $inf2\n";
}

my $tmp_count=0;
while (my $line1=<IN1>) {
   if ($line1=~/^@/){
   		my $line2=<IN1>;
   		my $line3=<IN1>;
   		my $line4=<IN1>;
   		my $string=$line1.$line2.$line3.$line4;
      $tmp_count++;
      $read1{$tmp_count}=$string;
   	}else{
      print STDERR "File format ERROR in $inf1, pay attention!!! $line1\n";
    }

    $line1=<IN2>;
    if($line1=~/^@/){
      my $line2=<IN2>;
      my $line3=<IN2>;
      my $line4=<IN2>;
      my $string=$line1.$line2.$line3.$line4;
      $read2{$tmp_count}=$string;
    }else{
      print STDERR  "File format ERROR in $inf2, pay attention!!!\n$line1\n";
    }
}
close(IN1);
close(IN2);

print STDERR "Fastq files $inf1 and $inf2 have been read into the memory.\n";

my @array= shuffle(keys %read1);

my $total_reads= scalar(@array);

if($total_reads>=$max_num){
	print STDERR "Total number of fragments is ".$total_reads.". Your request is sub-sampling for $min_num - $max_num fragments.\n";
}else{
	print STDERR "Wrong!!! Total number of fragments for $inf1 and $inf2 is less than what you requested!\n"; exit;
}

my $tmp= $max_num - $min_num; 
my $number=$min_num+int(rand($tmp));

my $stat_out="Subsample_number_of_reads.stats.xls";
open(STAT, ">>$stat_out") or die "Cannot open $stat_out\n";
print STAT "$inf1 and $inf2\t$number\n";
close STAT;

my $number_of_reads=0;
open(OUT1,">$outf1") or die "Cannot open $outf1\n";
open(OUT2,">$outf2") or die "Cannot open $outf2\n";
while($number_of_reads<$number-1000){
	my $total=@array-1000;
	my $i=int(rand($total));
	for(my $j=0;$j<1000;$j++){
		print OUT1 $read1{$array[$i+$j]};
		print OUT2 $read2{$array[$i+$j]};
  }
	$number_of_reads+=1000;
	splice(@array,$i,1000);
}

while($number_of_reads<$number){
  my $total=@array-1;
  my $i=int(rand($total));
  print OUT1 $read1{$array[$i]};
  print OUT2 $read2{$array[$i]};
  $number_of_reads++;
  splice(@array,$i,1);
}

close(OUT1);
close(OUT2);

exit;
