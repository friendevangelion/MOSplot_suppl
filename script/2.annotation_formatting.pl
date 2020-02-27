use strict;
use warnings;
use Getopt::Long;

my $codingGeneFileName = "codingGene.tab";
my $noncodingGeneFileName = "noncodingGene.tab";

my $outputHeader = "";
my $prodigalFile = "";
my $rnammerFile = "";
my $trnascanFile = "";
my $rfamRf = "";
my $rfamFile = "";
my $cogPep = "";
my $cogPepID2CogID = "";
my $cogCogID2ClassID = "";
my $cogFile = "";
my $keggFile = "";
my $str;
my $g;
my %codingGene;
my %noncodingGene;
my @ae;
my @subae;
my @subsubae;
my $tempPos;
my $flagOfCOG = 0;
my $flagOfKEGG = 0;
my $flagOfGO = 0;

GetOptions(
    'outputHeader|o=s' => \$outputHeader,
    'prodigalFile=s' => \$prodigalFile,
    'rnammerFile=s' => \$rnammerFile,
    'trnascanFile=s' => \$trnascanFile,
    'rfamRf=s' => \$rfamRf,
    'rfamFile=s' => \$rfamFile,
    'cogPep=s' => \$cogPep,
    'cogPepID2CogID=s' => \$cogPepID2CogID,
    'cogCogID2ClassID=s' => \$cogCogID2ClassID,
    'cogFile=s' => \$cogFile,
    'keggFile=s' => \$keggFile,
);

open FIN, $prodigalFile or die "No Prodigal result!\n";
while (defined($str=<FIN>)){
	chomp $str;
	if ($str=~/^>/){
        $str = substr $str, 1;
		@ae = split /\s#\s/, $str;
		$tempPos = rindex $ae[0], "_";
        $codingGene{$ae[0]}{"seqID"} = substr $ae[0], 0, $tempPos; 
        $codingGene{$ae[0]}{"source"} = "Prodigal";
        $codingGene{$ae[0]}{"start"} = $ae[1];
        $codingGene{$ae[0]}{"end"} = $ae[2];
        if ($ae[3]=="1") { $codingGene{$ae[0]}{"strand"} = "+"; }
        elsif ($ae[3]==-1) { $codingGene{$ae[0]}{"strand"} = "-"; }
        else { $codingGene{$ae[0]}{"strand"} = "?"; }
        @subae = split /;/, $ae[4];
        @subsubae = split /=/, $subae[1];
        $codingGene{$ae[0]}{"partial"} = $subsubae[1];
	}
}
close FIN;

my %cogPepAnnotation;
my %cogPepCog;
my %cogClass;
if ((-e $cogPep) && (-e $cogPepID2CogID) && (-e $cogCogID2ClassID) && (-e $cogFile)) { $flagOfCOG = 1; }
if ($flagOfCOG) {
    open FIN, $cogPep;
    while (defined($str=<FIN>)){
        if ($str=~/^>/) {
            chomp $str;
            @ae = split /\|\s/, $str;
            @subae = split /\|/, $ae[0];
            $cogPepAnnotation{$subae[1]} = $ae[1];
        }
    }
    close FIN;
    
    open FIN, $cogPepID2CogID;
    while (defined($str=<FIN>)){
        chomp $str;
        @ae = split /,/, $str;
        $cogPepCog{$ae[0]} = $ae[6];
    }
    close FIN;
    
    open FIN, $cogCogID2ClassID;
    for (1) { $str = <FIN>; }
    while (defined($str=<FIN>)){
        chomp $str;
        @ae = split /\t/, $str;
        $cogClass{$ae[2]} = $ae[3];
    }
    close FIN;
    
    open FIN, $cogFile;
    while (defined($str=<FIN>)){
        chomp $str;
        @ae = split /\t/, $str;
        @subae = split /\|/, $ae[1];
        $codingGene{$ae[0]}{"COG"} = $subae[1]." | ".$cogPepAnnotation{$subae[1]}." | ".$cogPepCog{$subae[1]}." | ".$cogClass{$cogPepCog{$subae[1]}}." | ".$ae[2];
        $codingGene{$ae[0]}{"COGcolor"} = $cogClass{$cogPepCog{$subae[1]}};
    }
}

open FOUT, ">".$outputHeader.".".$codingGeneFileName;
print FOUT "SeqID\tSource\tStart\tEnd\tStrand\tPartial";
if ($flagOfCOG) { print FOUT "\tCOG\tCOGcolor"; }
print FOUT "\n";
foreach $g (sort {$codingGene{$b}{"seqID"} cmp $codingGene{$a}{"seqID"} or $codingGene{$a}{"start"}<=>$codingGene{$b}{"start"}} keys %codingGene) {
    print FOUT $codingGene{$g}{"seqID"}, "\t";
    print FOUT $codingGene{$g}{"source"}, "\t";
    print FOUT $codingGene{$g}{"start"}, "\t";
    print FOUT $codingGene{$g}{"end"}, "\t";
    print FOUT $codingGene{$g}{"strand"}, "\t";
    print FOUT $codingGene{$g}{"partial"};
    if ($flagOfCOG) {
        if (exists($codingGene{$g}{"COG"})) {
            print FOUT "\t", $codingGene{$g}{"COG"}, "\t", $codingGene{$g}{"COGcolor"};
        } else {
            print FOUT "\t#\t#";
        }
    }
    print FOUT "\n";
}
close FOUT;

if (-e $rnammerFile) {
    open FIN, $rnammerFile;
    while (defined($str=<FIN>)){
        chomp $str;
        if ($str!~/^#/) {
            @ae = split /\t/, $str;
            $ae[8] =~ s/s_/S /;
            $g = $ae[0]."_".$ae[3]."_".$ae[4];
            $noncodingGene{$g}{"seqID"} = $ae[0];
            $noncodingGene{$g}{"source"} = "RNAmmer";
            $noncodingGene{$g}{"start"} = $ae[3];
            $noncodingGene{$g}{"end"} = $ae[4];
            $noncodingGene{$g}{"strand"} = $ae[6];
            $noncodingGene{$g}{"type"} = "rRNA";
            $noncodingGene{$g}{"annotation"} = $ae[8];
        }
    }
    close FIN;
}

if (-e $trnascanFile) {
    open FIN, $trnascanFile;
    for (1..3) { $str=<FIN>; }
    while (defined($str=<FIN>)){
        chomp $str;
        @ae = split /\t/, $str;
        foreach (0..scalar(@ae)-1) {
            $ae[$_] =~ s/^\s+|\s+$//g;
        }
        if ($ae[3]>$ae[2]) {
            $g = $ae[0]."_".$ae[2]."_".$ae[3];
            $noncodingGene{$g}{"start"} = $ae[2];
            $noncodingGene{$g}{"end"} = $ae[3];
            $noncodingGene{$g}{"strand"} = "+";
        } else {
            $g = $ae[0]."_".$ae[3]."_".$ae[2];
            $noncodingGene{$g}{"start"} = $ae[3];
            $noncodingGene{$g}{"end"} = $ae[2];
            $noncodingGene{$g}{"strand"} = "-";
        }
        $noncodingGene{$g}{"seqID"} = $ae[0];
        $noncodingGene{$g}{"source"} = "tRNAscan-SE";
        $noncodingGene{$g}{"type"} = "tRNA";
        $noncodingGene{$g}{"annotation"} = $ae[4]." tRNA";
    }
    close FIN;
}

my %rfamClass;
my %rfamAnnotation;
if ((-e $rfamRf) && (-e $rfamFile)) {
    open FIN, $rfamRf;
    while (defined($str=<FIN>)){
        chomp $str;
        @ae = split /\t/, $str;
        $ae[0] =~ s/^\s+|\s+$//g;
        $ae[1] =~ s/^\s+|\s+$//g;
        $ae[-1] =~ s/^\s+|\s+$//g;
        $rfamClass{$ae[0]} = $ae[-1];
        $rfamAnnotation{$ae[0]} = $ae[1];
    }
    close FIN;
    
    open FIN, $rfamFile;
    for (1) { <FIN>; }
    while (defined($str=<FIN>)){
        chomp $str;
        if ($str!~/^#/) {
            @ae = split /\s+/, $str;
            if ($rfamClass{$ae[2]} eq "sRNA" || $rfamClass{$ae[2]} eq "CRISPR") {
                if ($ae[10]>$ae[9]) {
                    $g = $ae[3]."_".$ae[9]."_".$ae[10];
                    $noncodingGene{$g}{"start"} = $ae[9];
                    $noncodingGene{$g}{"end"} = $ae[10];
                } else {
                    $g = $ae[3]."_".$ae[10]."_".$ae[9];
                    $noncodingGene{$g}{"start"} = $ae[10];
                    $noncodingGene{$g}{"end"} = $ae[9];
                }
                $noncodingGene{$g}{"seqID"} = $ae[3];
                $noncodingGene{$g}{"source"} = "RFAM";
                $noncodingGene{$g}{"strand"} = $ae[11];
                $noncodingGene{$g}{"type"} = $rfamClass{$ae[2]};
                $noncodingGene{$g}{"annotation"} = $rfamAnnotation{$ae[2]};
            }
        }
    }
}

open FOUT, ">".$outputHeader.".".$noncodingGeneFileName;
print FOUT "SeqID\tSource\tStart\tEnd\tStrand\tType\tAnnotation";
print FOUT "\n";
foreach $g (sort {$noncodingGene{$b}{"seqID"} cmp $noncodingGene{$a}{"seqID"} or $noncodingGene{$a}{"start"}<=>$noncodingGene{$b}{"start"}} keys %noncodingGene) {
    print FOUT $noncodingGene{$g}{"seqID"}, "\t";
    print FOUT $noncodingGene{$g}{"source"}, "\t";
    print FOUT $noncodingGene{$g}{"start"}, "\t";
    print FOUT $noncodingGene{$g}{"end"}, "\t";
    print FOUT $noncodingGene{$g}{"strand"}, "\t";
    print FOUT $noncodingGene{$g}{"type"}, "\t";
    if (exists($noncodingGene{$g}{"annotation"})) { print FOUT $noncodingGene{$g}{"annotation"}, "\n"; } else { print FOUT "#\n"; }
}
close FOUT;
