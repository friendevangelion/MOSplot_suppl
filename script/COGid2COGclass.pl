open FIN, "listCOGs.html";
$flag = 0;
while ($str=<FIN>) {
	chomp $str;
	if ($str eq "<TR VALIGN=TOP>") {
		$flag = 1;
	} elsif ($str eq "</TR>" && $flag) {
		$flag = 0;
		foreach (@arr) {
			print $_, "\t";
		}
		print "\n";
		@arr = ();
	} elsif ($flag) {
		if ($str=~/<B>(.*)<\/B>/) {
			$marker=$1;
		} elsif ($str=~/<SMALL>&nbsp;(.*)&nbsp;<\/SMALL>/) {
			$marker=$1;
		} elsif ($str=~/<TT>&nbsp;(.*)&nbsp;<\/TT>/) {
			$marker=$1;
		} elsif ($str=~/<TT>(.*)<\/TT>/) {
            $marker=$1;
        }
		$arr[$flag-1] = $marker;
		$flag++;
	} 
}
