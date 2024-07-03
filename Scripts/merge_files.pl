#!/usr/bin/perl

use warnings;
use strict;

#`sed \'/^\$/d\' cpc_output.fa >cpc_output.fasta`;
my $line;
my @parts;
my %id;
my %tmp;
my %count;
my $file;
my $count =0;
if (scalar (@ARGV) != 4)
{
	print "This used to merger whol genom methylation files\n";
	print "need input file and output file\n";
	print "first is input first whole geome  file that needed to append to it try to use the file with max number of lines\n";
	print "second input file has the list of the rest of the files\n";
	print "third output file \n";
	print "fourth the minmum value of reads to keep \n";
	exit(-1);
}

#my @files=<$ARGV[0]>;
	if ($ARGV[0]=~ /.gz$/) {
		open(INPUT, "gunzip -c $ARGV[0] |") || die "can not open pipe to $ARGV[0]";
	}
	else {
		open INPUT ,"$ARGV[0]" or die "couldn't open input file $!\n";
	}
open INPUT2 ,"$ARGV[1]" or die "couldn't open input file $!\n";
open OUTPUT ,">$ARGV[2].csv" or die "couldn't open input file $!\n";
while(<INPUT>)
{
	chomp;
	$line=$_;
	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
	@parts=split(/[\s,]+/,$line);
	#my $t = $parts[0];

#	$t =~ s/2010//g;
#	$t =~ s/2012//g;
#	$t = int($t /1000);
#	if($parts[0] !~ /NW/)
#	{
		$line=~ s/\s+/,/g;
		$id{$parts[0]}{$parts[1]}= $line; # $parts[3].' '.$parts[4];
		$count{$parts[0]}{$parts[1]}= $parts[3]+ $parts[4]
#	}
}


while(<INPUT2>)
{

	chomp;
	$line=$_;
	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
	$file = $line;
	print "Processing file: $file\n";
	if ($file =~ /.gz$/) {
		open(Meth, "gunzip -c $file |") || die "can not open pipe to $file";
	}
	else {
	open(Meth, $file) || die "can not open $file";
	}

	$count++;
	while(<Meth>)
	{
		chomp;
		$line=$_;
		chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
		
		@parts=split(/[\s,']+/,$line);
	#	if ($line !~ /NW/)
	#	{
#	$parts[1] =~ s/\s+//g;
		if (exists $id{$parts[0]}{$parts[1]})
		{
	#	$tmp{$parts[0]}{$parts[1]} = $parts[0].','.$parts[1].",".$parts[3].','.$parts[4].','.$id{$parts[0]}{$parts[1]};
	#	$tmp{$parts[0]}{$parts[1]} = $line." ".$id{$parts[0]}{$parts[1]};
			$id{$parts[0]}{$parts[1]}.=",".$parts[3].",".$parts[4];
			$count{$parts[0]}{$parts[1]}= $count{$parts[0]}{$parts[1]} +  $parts[3]+ $parts[4]
		}
		else
		{
			$id{$parts[0]}{$parts[1]}=$parts[0].",".$parts[1].",".$parts[2].",0,0".$parts[5].",".$parts[6];
			for (my $i = 0; $i < $count -1 ; $i++)
			{
				$id{$parts[0]}{$parts[1]}.=",0,0";
			}
			$id{$parts[0]}{$parts[1]}.=",".$parts[3].",".$parts[4];
			$count{$parts[0]}{$parts[1]} =  $parts[3]+ $parts[4]
		}
	#	}
	}
	close Meth;
}
foreach my $key( keys %id)
{
	foreach my $start (keys %{$id{$key}})
	{
		if ($count{$key}{$start} > $ARGV[3])
		{
			print OUTPUT "$id{$key}{$start}\n";
		}
	}
}  
close INPUT;
close INPUT2;
close OUTPUT;
