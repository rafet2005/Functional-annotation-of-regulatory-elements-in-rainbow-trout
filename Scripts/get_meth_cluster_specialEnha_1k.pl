#!/usr/bin/perl

use warnings;
use strict;

if(scalar (@ARGV) != 4)
{
	print "use for: get the meth cluster compare to gene TSS\n";
	print "need three arguments\n";
	print "first gff file\n";
	print "Second meth file\n";
	print "third output file\n";
	print "fourth cut off value\n";
	exit(-1)
}

my @parts;
my @name;
my @name2;
my $line;
my %list;
my %length;
my %signe;
my %end;
my %limit;
my %Nelimit;
my %ExonStart;
my %ExonEnd;
my $count =1;
my $flag = 0;
my $NeExon = "";
my $tmp;
my $start;
my $dist;
my $countP = 0;
#open(INPUT, "gunzip -c $ARGV[0] |") || die "can not open pipe to $ARGV[0] $!\n";
open List , "<$ARGV[0]" or die " could not open $ARGV[0] $!\n";
open INPUT , "<$ARGV[1]" or die " could not open $ARGV[1] $!\n";
open OUTPUT, ">$ARGV[2].csv" or die " could not open $ARGV[2] $!\n";
#open OUTPUT2, ">$ARGV[2]_gene_snp_info" or die " could not open $ARGV[2] $!\n";
#open LOG , ">$ARGV[1]/chr_$ARGV[2].log" or die "could not open $ARGV[1] $!\n";

#create a hash to hold the genes and use the chr and start point as key and gene Id as value
while(<List>)
{
	chomp;
	$line = $_;
	if ($line !~ /##/)
	{
	@parts = split(/[\s]+/, $line);
	if ($parts[2] eq "gene")
	{
		#print "$NeExon\n";
		@name = split('Name' , $parts[8]);
		@name2 = split(';', $name[1]);
		$name2[0]=~ s/\=//;
	#	print "$parts[0]\t$parts[3]\t$name2[0]\n";
		$start = $parts[3];
		$list{$parts[0]}{$parts[3]} = $name2[0];
		$signe{$parts[0]}{$parts[3]} = $parts[6];
		$end{$parts[0]}{$parts[3]} = $parts[4];
		$length{$parts[0]}{$parts[3]} = $parts[4] - $parts[3] ;
		# if length is greater than the $ARGV[3] adjust upper limit and lower limite of the positive and negativ
		# accordinaly 
		if ($length{$parts[0]}{$parts[3]} > $ARGV[3]) # set up the upper limit for positive and negative signe
		{
			$limit{$parts[0]}{$parts[3]} =   $ARGV[3]; # 
			$Nelimit{$parts[0]}{$parts[3]} =  $ARGV[3];
		}
		else
		{
			$limit{$parts[0]}{$parts[3]} = $length{$parts[0]}{$parts[3]};
			$Nelimit{$parts[0]}{$parts[3]} = $length{$parts[0]}{$parts[3]};
		}
		$flag = 1;
	}
	elsif( $parts[2] eq  "exon" and $flag == 1 ) #and $parts[6] ne '-')
	{
	#	@parts = split(/[\s]+/, $line);
	#	@name = split('GeneID:' , $parts[8]);
	#	@name2 = split(',', $name[1]);
		#print "$parts[0]\t$parts[2]\t$parts[3]\t$parts[4]\t$name[0]\n";
		$ExonStart{$parts[0]}{$start} = $parts[3];
		$ExonEnd{$parts[0]}{$start} = $parts[4];
	#	print "$parts[0]\t$parts[3]\t$parts[4]\n";
		$flag = 0
		
	}
#	elsif( $parts[2] eq  "exon" and $flag == 1 and $parts[6] eq '-' )
#	{
#		@parts = split(/[\s]+/, $line);
#		@name = split('GeneID:' , $parts[8]);
#		@name2 = split(',', $name[1]);
#		$NeExon = "$parts[0]\t$parts[2]\t$parts[3]\t$parts[4]\t$parts[6]\t$name[0]";
#		$ExonStart{$parts[0]}{$parts[3]} = $parts[3];
#		$ExonEnd{$parts[0]}{$parts[3]} = $parts[4];
#	#	$flag = 0
#		
#	}
	}
}
# this is a special print statment for the header and should be adjusted base on input file

print OUTPUT "Chr,EnhStart,EnhEnd,Enhstrand, , , , , , , ,Gene,Body,Promoter1K,2K,3K,5K,10K,GeneStart,GeneEnd,GeneStrand,FirstExon,disTSS\n";
#print OUTPUT "Chr,start,strand,B1,,B2,,I1,,I2,,K1,,K2,,L1,,L2,,S1,,S2,,WM1,,WM2,,Gene,Body,Promoter1K,2K,3K,5K,10K,GeneStart,GeneEnd,GeneStrand,FirstExon,disTSS\n";
#print OUTPUT "Chr,start,strand,MRM13,,CG,CpG,MB1,,ML2,,MRM3,,MT4,,MWM5,,MB6,,ML7,,MRM8,,MT9,,MWM10,,MB11,,ML12,,MT14,,MWM15,,FB16,,FL17,,FRM18,,FO19,,FWM20,,FB21,,FL22,,FRM23,,FO24,,FWM25,,FB26,,FL27,,FRM28,,FO29,,FWM30,,Gene,Body,Promoter2K,3K,5K,10K,GeneStart,GeneEnd,GeneStrand,FirstExon\n";
while(<INPUT>)
{
	chomp;
	$line = $_;
	# keep the header
	@parts = split(/[\s,]+/, $line);
#	if (($parts[3]+$parts[4]+$parts[7]+$parts[8]+$parts[9]+$parts[10]+$parts[11]+$parts[12]+$parts[13]+$parts[14]+$parts[15]+$parts[16])>= 10 )
#	if (($parts[3]+$parts[4]+$parts[7]+$parts[8]+$parts[9]+$parts[10]+$parts[11]+$parts[12]+$parts[13]+$parts[14]+$parts[5]+$parts[6])>= 10 )
#{
	if ($line !~ /^#/)
	{
        $line=~ s/\t/,/g;
		$tmp = $line;
		foreach my $key(keys %{$list{$parts[0]}})
		{
			if( $signe{$parts[0]}{$key} eq '+' or $signe{$parts[0]}{$key} eq '.')
			{
				if (($key - $ARGV[3]) < $parts[1] and ($key + $limit{$parts[0]}{$key}    > $parts[1] ))  
				{
					#	print "Positive,$parts[1],$parts[0],$key,$ExonStart{$parts[0]}{$key},$ExonEnd{$parts[0]}{$key}\n";
					$line.=",". $list{$parts[0]}{$key}; #  add gene name;
					if (($key ) <= $parts[1] and ($end{$parts[0]}{$key}  >=  $parts[1] ))  
					{
						$line.=",". "Body,NA,NA,NA,NA,NA"; #  add body;
					}
					else
					{
						$line.=",". "NA"; # ;
						if (($key - 1000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."1K,2K,3k,5k,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							$countP++;
						}
						elsif (($key - 2000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,2K,3k,5k,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 3000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,NA,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 5000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - $ARGV[3]) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,NA,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						else
						{
							$line.=",". "NA,NA,NA,NA,NA,NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
					}
					$line.=",".$key.",". $end{$parts[0]}{$key}.",".$signe{$parts[0]}{$key}; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					if($parts[1] > $ExonStart{$parts[0]}{$key}  and $parts[1] < $ExonEnd{$parts[0]}{$key} )
					{
						$line.= "," ."FirstExon"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					}
                    else
                    {
						$line.= ",NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";

                    }
                    $dist =  $key -  $parts[1]   ;
					print 	OUTPUT "$line,$dist\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					$line = $tmp;
				#	last;
				}
			}
			else
			{
				if (  ($end{$parts[0]}{$key} - $Nelimit{$parts[0]}{$key})  <= $parts[1] and (($end{$parts[0]}{$key} + $ARGV[3] )  >= $parts[1] ))  
				{
					#	print "Negative,$parts[1],$parts[0],$key,$ExonStart{$parts[0]}{$key},$ExonEnd{$parts[0]}{$key}\n";
					$line.=",". $list{$parts[0]}{$key}; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					if (($key ) <= $parts[1] and ($end{$parts[0]}{$key}  >=  $parts[1] ))  
					{
						$line.=",". "Body,NA,NA,NA,NA,NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					}
					else
					{
						$line.=",". "NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						if (($end{$parts[0]}{$key} + 2000 >= $parts[1]) and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."1K,2K,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							$countP++;
						}
						elsif (($end{$parts[0]}{$key} + 2000 >= $parts[1]) and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,2K,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($end{$parts[0]}{$key} + 3000) >= $parts[1] and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,NA,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($end{$parts[0]}{$key} + 5000) >= $parts[1] and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($end{$parts[0]}{$key} + $ARGV[3]) >= $parts[1] and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,NA,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						else
						{
							$line.=",". "NA,NA,NA,NA,NA,NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
					}
					$line.=",".$key.",". $end{$parts[0]}{$key}.",".$signe{$parts[0]}{$key}; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					if($parts[1] > $ExonStart{$parts[0]}{$key}  and $parts[1] < $ExonEnd{$parts[0]}{$key} )
					{
						$line.= "," ."FirstExon"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					}
                    else
                    {
						$line.= ",NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";

                    }
                    $dist =  $end{$parts[0]}{$key} -  $parts[1] ; 
					print 	OUTPUT "$line,$dist\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					$line = $tmp;
					#last;
				}
			}
		}

	}
#}
}
print "there are $countP within 1K\n";
close INPUT;
close OUTPUT;
close List;
=cut
foreach my $key(keys %gene)
{
	if($gene_count{$key} > 1)
	{
		print OUTPUT "$key $gene{$key}\n";
	}
	else
	{
		print OUTPUT2 "$key $gene{$key}\n";
	}
}
#=cut
		#if (length($parts[3]) == 1 and length( $parts[4]) == 1 and $parts[6] eq 'PASS' and $parts[0] == $ARGV[2])
		# keep pass
		if ( $parts[6] eq 'PASS')
		{
			$Pcount++;
			if($parts[0] eq $ARGV[2])
			{
				# classify based on number of allele 	
				if ( length($parts[3]) == 1 and length( $parts[4]) == 1)
				{	
					$Scount++;		
					print OUTPUT "$line\n";
				}
			}
		}
	} 

}
#record stat to log file
print LOG "The following was observed:\n";
print LOG "\n\nTotla number of variants is           : $Tcount\n";
print LOG "Totla number of Passing variants is   : $Pcount\n";
print LOG "Totla number of Passing Biallelic variants for $ARGV[2] : $Scount\n";
close INPUT;
close OUTPUT;
close LOG;
