#!/usr/bin/perl -w

my $usage = << "EOF";

Usage: $0
        -i input file
	-c cutoff value
        -o output file
EOF

use Getopt::Long;

my %par = (
                  );

&GetOptions("i=s" => \$par{infile},
	    "c=f" => \$par{cutoff},
            "o=s" => \$par{outfile});

($par{infile} && $par{outfile} && $par{cutoff}) or die $usage;

&go (\%par );

print STDERR "$0 done\n";

###############################################

sub go {
    my ( $par ) = @_;

    my ($mx, $nspec, $nchar, $weights) = &readMx($par->{infile});

    open (OF, ">$par->{outfile}") or die "Cannot open outfile $par->{outfile} $!\n";

    my ($a, $c, $flags, $nused) = &getCharRelDiv($mx, $nspec, $nchar, $par->{cutoff}, $weights, \*OF);
    my $dists = &calcDists($mx, $flags, $nspec, $nchar, $nused, $weights, \*OF);

    close (OF);
}

sub readMx {
	my $mf = shift;
	my %mx = ();
	my %weights = ();
	my $nspec = 0;
	my $nchar = 0;

	open (M, "<$mf")  or die "Cannot open infile $mf $!\n";
    	while(<M>){
    	    	chomp;
    	    	next if /^\#/;
    		next unless /\w/;
		if (!(/^weights/)) {
			$nspec++;
			my ($species, @w) = split;
			$nchar = $#w + 1;
			for my $i (0 .. $#w) {
				my $j = $i + 1;
				my $val = $w[$i];
				$mx{$species}{$j} = $val;
			}
		} else {
			my ($x, @wts) = split;
			for my $wi (0 .. $#wts) {
				my $wii = $wi + 1;
				$weights{$wii} = $wts[$wi];
			}
		}
    	}
    	close (M);

	return (\%mx, $nspec, $nchar, \%weights);
}

sub getCharRelDiv {
	my ($mx, $nspec, $nchar, $cut, $w, $of) = @_;
	my %a = ();
	my %c = ();
	my %flags = ();
	my $nused = 0;

	print $of "Relative characters\n";
	for my $x (1 .. $nchar) {
		my $n = 0;
		my %f = ();
		for my $sp (sort keys %{$mx}) {
			my $val = $mx->{$sp}{$x};

			if (!(defined($f{$val}))) {
				$f{$val} = 1/$nspec;
			} else {
				$f{$val} = $f{$val} + 1/$nspec;
			}

			if (!($val eq '?')) {$n++;}
		}
		$a{$x} = $n/$nspec;
		if ($a{$x} >= $cut) {
			$flags{$x} = 1;
			$nused+=$w->{$x};
		} else {
			$flags{$x} = 0;
		}
		my $cc = 0;
		for my $ft (keys %f) {
			$cc = $cc + $f{$ft}*$f{$ft}*($nspec/($nspec-1));
		}
		$c{$x} = 1 - $cc;
		print $of "$x\t$c{$x}\t$flags{$x}\n";
	}
	return (\%a, \%c, \%flags, $nused);
}

sub calcDists {
	my ($mx, $flags, $nspec, $nchar, $nused, $w, $of) = @_;
	my %dists = ();

	print $of "\nDistance matrix\n\n";

	print $of "";
	for my $sp (sort keys %{$mx}) {
		print $of "\t$sp";
	}
	print $of "\n";

	for my $sp1 (sort keys %{$mx}) {
		print $of "$sp1";
		for my $sp2 (sort keys %{$mx}) {
			my $n = 0;
			for my $k (1 .. $nchar) {
				if ($flags->{$k} == 1) {
					my $val_sp1 = $mx->{$sp1}{$k};
					my $val_sp2 = $mx->{$sp2}{$k};
					$val_sp1 =~ s/[{}]//g;
					$val_sp2 =~ s/[{}]//g;
					my @v1 = split('',$val_sp1);
					my @v2 = split('',$val_sp2);
					if (&check(\@v1, \@v2, $#v1, $#v2) == 1) {
						$n += $w->{$k};
						#print "$sp1\t$sp2\t$k\t$val_sp1\t$val_sp2\n";
					}
				}
			}
			$dists{$sp1}{$sp2} = 1 - $n/$nused;
			print $of "\t$dists{$sp1}{$sp2}";
		}
		print $of "\n";
	}

	return \%dists;
}

sub check {
	my ($v1, $v2, $n1, $n2) = @_;
	my $ok = 0;

	for my $i (0 .. $n1) {
		for my $j (0 .. $n2) {
			if ($v1->[$i] eq $v2->[$j]) {$ok = 1;}
		}
	}

	return $ok;
}
