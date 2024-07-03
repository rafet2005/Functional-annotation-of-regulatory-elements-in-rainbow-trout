#!/usr/bin/perl

use warnings;
use strict;

#`sed \'/^\$/d\' cpc_output.fa >cpc_output.fasta`;
my $line;
my @parts;
my %id;
if (scalar (@ARGV) != 3)
{
	print "This used to append sign to diffMeth csv file\n";
	print "need input file and output file\n";
	print "first is input csv file that needed to append to it\n";
	print "second input file has the whol genome methylation to extract the sign from \n";
	print(" all whole genome methylation files has teh same sign so one should be enough\n"); 
	print "third output file \n";
#	print "fourth the location of the value\n";
	exit(-1);
}

#my @files=<$ARGV[0]>;
open INPUT ,"$ARGV[0]" or die "couldn't open input file $!\n";
	if ($ARGV[1]=~ /.gz$/) {
		open(INPUT2, "gunzip -c $ARGV[1] |") || die "can not open pipe to $ARGV[1]";
	}
	else {
		open INPUT2 ,"$ARGV[1]" or die "couldn't open input file $!\n";
	}
#open INPUT2 ,"$ARGV[1]" or die "couldn't open input file $!\n";
open OUTPUT ,">$ARGV[2].csv" or die "couldn't open input file $!\n";
while(<INPUT2>)
{
	chomp;
	$line=$_;
	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
	@parts=split(/[\s,]+/,$line);
	#my $t = $parts[0];

#	$t =~ s/2010//g;
#	$t =~ s/2012//g;
#	$t = int($t /1000);

#	$id{$parts[1]}=$parts[2];
#	$id{$parts[0]}=$parts[1]."\t".$parts[2];
#	$id{$parts[0]}=$parts[2]."\t".$parts[3]."\t".$parts[4]."\t".$parts[5];
#	$id{$parts[1]}=$parts[-6].','.$parts[-5].','.$parts[-4].','.$parts[-3].','.$parts[-2].','.$parts[-1] ;#.','.$parts[25].','.$parts[26].','.$parts[27].','.$parts[28];
	$id{$parts[0]}{$parts[1]}=$parts[2] ;# .','.$parts[3].','.$parts[4];
}
# this part is special case

#while(<INPUT>)
#{
#	chomp;
#	$line=$_;
#	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
#	foreach my $key (keys  %id)
#	{
#		if ($line =~ $key)
#		{
#			@parts=split(/[\s,']+/,$line);
#			print OUTPUT "$parts[14]\t$parts[11]\t$parts[12]\t$parts[15]\t$parts[6]\n";
#		}
#	}
#}

while(<INPUT>)
{
	chomp;
	$line=$_;
	chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
	if($line =~ /#/)
	{
	#	$line =~ s/#//;
		print OUTPUT "#$line\tsubject\n";
	}
	@parts=split(/[\s,']+/,$line);
#	$parts[1] =~ s/\s+//g;
	if (exists $id{$parts[0]}{$parts[1]})
#	if (exists $id{$parts[1]})
	{
		$line =~ s/\*/$id{$parts[0]}{$parts[1]}/g;
		print OUTPUT "$line\n";
#		if($id{$parts[9]} ne ' ')
#		{
		#	my @tmp = split(/[\s,']+/,$id{$parts[22]});
	#		print 	OUTPUT "$parts[0] $id{$parts[1]} $parts[2] $parts[3] $parts[4]\n";
			#print 	OUTPUT "$line\t$id{$parts[1]}\n";
			#print 	OUTPUT "$line\t$id{$parts[0]}{$parts[1]}\n";
#			print 	OUTPUT "$line,$id{$parts[0]}{$parts[1]}\n";
#		}
	}
	else
	{
		print 	OUTPUT "$line\n";
	#	print 	OUTPUT "$line\tNANA\tNA\tNA\tNA\tNA\n";
	#	print "This line has no lab id match $line\n";
	}
}

close INPUT;
close INPUT2;
close OUTPUT;
