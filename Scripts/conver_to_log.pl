#!/usr/bin/perl

use warnings;
use strict;

if(scalar (@ARGV) != 2)
{
	print "use for: convert coloum (2) to log 10\n";
	print "need three arguments\n";
	print "first file to be conver to\n";
	print "Second output file\n";
#	print "third coloumn numbere\n";
	exit(-1)
}

my @parts;
my @name;
my @name2;
my $line;
my %list;
my %stat;
my %used;
my %end;
my %limit;
my %Nelimit;
my %ExonStart;
my %ExonEnd;
my $count =1;
my $flag = 0;
my $NeExon = "";
my $tmp;
my $dist;
my $start;
my $center;
my $countP = 0;
#open(INPUT, "gunzip -c $ARGV[0] |") || die "can not open pipe to $ARGV[0] $!\n";
open INPUT , "<$ARGV[0]" or die " could not open $ARGV[1] $!\n";
open OUTPUT, ">$ARGV[1].csv" or die " could not open $ARGV[2] $!\n";
#open OUTPUT2, ">$ARGV[2]_gene_snp_info" or die " could not open $ARGV[2] $!\n";
#open LOG , ">$ARGV[1]/chr_$ARGV[2].log" or die "could not open $ARGV[1] $!\n";


while(<INPUT>)
{
	chomp;
	$line = $_;
	# keep the header
	@parts = split(/[\s,]+/, $line);
	if ($parts[1] == 0 )
	{
		print 	OUTPUT "$line\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
	}
	elsif ($parts[1] > 0)
	{
		print 	OUTPUT "$parts[0],",sprintf("%.2f",log10($parts[1])),",$parts[2]\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
	}
	else
	{
		print 	OUTPUT "$parts[0],-",sprintf("%.2f",log10(abs($parts[1]))),",$parts[2]\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
	}

}

close INPUT;
close OUTPUT;
# Function for log10 calculator
sub log10 
{
    my $n = shift;
      
    # using pre-defined log function
    return log($n) / log(10);
}

=cut				if($key < $center) # Meth to the left
				{
					if (($key  >= $parts[1] ))  
					{
						#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
						$line.=",". "-0.5"; #  add body;
					}
					else
					{
						if (($key + 1000) >= $center  )  
						{
							$line.= ",-1" ; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
						}
						elsif (($key + 2000) >= $center   )  
						{
							$line.= ",-2";# ."0,0,1,0,0,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
						}
						elsif (($key + 3000) >= $center  )  
						{
							$line.= ",-3";# ."0,0,0,1,0,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
						}
						elsif (($key + 4000) >= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-4";# ."0,0,0,0,1,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key + 5000) >= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-5";# ."0,0,0,0,0,1,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key + 6000) >= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-6";# ."0,0,0,0,0,0,1,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key + 7000) >= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-7";# ."0,0,0,0,0,0,0,1,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key + 8000) >= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-8";# ."0,0,0,0,0,0,0,0,1,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key + 9000) >= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-9";# ."0,0,0,0,0,0,0,0,0,1,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						else  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",-10";# ."0,0,0,0,0,0,0,0,0,0,1"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
					}
					print 	OUTPUT "$parts[0],$parts[1],$parts[2],$parts[3]$line\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
				}
				else
				{
					if (($key  < $parts[2] ))  
					{
						$line.=",0.5";#. "1,0,0,0,0,0,0,0,0,0,0"; #  add body;
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
					}
					else
					{
						if (($key - 1000) <= $center  )  
						{
							$line.= ",1";# ."0,1,0,0,0,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$countP++;
						}
						elsif (($key - 2000) <= $center   )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",2";# ."0,0,1,0,0,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 3000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",3";# ."0,0,0,1,0,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 4000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",4";# ."0,0,0,0,1,0,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 5000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",5";# ."0,0,0,0,0,1,0,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 6000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",6";# ."0,0,0,0,0,0,1,0,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 7000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",7";# ."0,0,0,0,0,0,0,1,0,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 8000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",8" ;#."0,0,0,0,0,0,0,0,1,0,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 9000) <= $center  )  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",9";# ."0,0,0,0,0,0,0,0,0,1,0"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						else  
						{
							#$used{$parts[0]}{$parts[1]}{$parts[2]}= "used";
							$line.= ",10";# ."0,0,0,0,0,0,0,0,0,0,1"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
					}
					print 	OUTPUT "$parts[0],$parts[1],$parts[2],$parts[3]$line\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
				}
				
			}
		}
		}
	}
					#print 	OUTPUT "$line\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
}
close INPUT;
close OUTPUT;
close List;

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
