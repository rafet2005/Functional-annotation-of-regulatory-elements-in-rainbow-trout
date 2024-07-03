#!/usr/bin/perl

use warnings;
use strict;

#`sed \'/^\$/d\' cpc_output.fa >cpc_output.fasta`;
my $line;
my @parts;
my %id;
my $start;
my $end;
my $count = 0;
if (scalar (@ARGV) != 3)
{
	print "This used to append a CpG island  to csv file\n";
	print "need input file and output file\n";
	print "first is input csv file that needed to append to it\n";
	print "second input file has the CpG islan information need to be append from\n";
	print "third output file \n";
	exit(-1);
}

#my @files=<$ARGV[0]>;
open INPUT ,"$ARGV[0]" or die "couldn't open input file $!\n";
open INPUT2 ,"$ARGV[1]" or die "couldn't open input file $!\n";
open OUTPUT ,">$ARGV[2].csv" or die "couldn't open input file $!\n";
while(<INPUT2>)
{
	chomp;
	$line=$_;
	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
	@parts=split(/[\s,]+/,$line);
#	$id{$parts[1]}{$parts[2]}{$parts[3]} =$parts[0];  # used in the old format
	$id{$parts[0]}{$parts[1]}{$parts[2]} = ",island" .$count++;

}
while(<INPUT>)
{
	chomp;
	$line=$_;
	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
	@parts=split(/[\s,]+/,$line);
	my $flag = 0;
	foreach  $start(keys %{$id{$parts[0]}})
	{
		foreach $end (keys %{$id{$parts[0]}{$start}})
		{
			if ($start < $parts[1] and  $end > $parts[1])
			{	
				if($line =~ m/First/)
				{
					print 	OUTPUT "$line$id{$parts[0]}{$start}{$end},$start,$end\n";
				}
				else
				{
					print 	OUTPUT "$line,NA$id{$parts[0]}{$start}{$end},$start,$end\n";
				}
				$flag = 1;
			}
		}
	}
	if ($flag == 0)
	{
		if($line =~ m/First/)
		{
			print OUTPUT "$line,out\n";
		}
		else
		{
			print OUTPUT "$line,NA,out\n";
		}
	}
}

close INPUT;
close INPUT2;
close OUTPUT;
