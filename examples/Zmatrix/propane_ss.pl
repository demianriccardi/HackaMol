use Modern::Perl;
use HackaMol;

my $bldr = HackaMol->new();
open( my $fh, ">", "H14C6S2.xyz" );

foreach my $chi1 ( 0, 45, 90, 135, 180, 235, 270, 315 ) {
    foreach my $chi1p ( 0, 45, 90, 135, 180, 235, 270, 315 ) {
        foreach my $chi2 ( 0, 45, 90, 135, 180, 235, 270, 315 ) {
            foreach my $chi2p ( 0, 45, 90, 135, 180, 235, 270, 315 ) {
                foreach my $chi3 ( 0, 45, 90, 135, 180 ) {
                    my $string = "
C
S 1 1.80
S 2 2.05 1 114
C 3 1.80 2 114 1 $chi3
C 1 1.50 2 115 3 $chi2
C 4 1.50 3 115 2 $chi2p
C 5 1.50 1 115 2 $chi1
C 6 1.50 4 115 3 $chi1p
H 1 1.00 2 109 5  120 
H 1 1.00 2 109 5 -120 
H 4 1.00 3 109 6  120 
H 4 1.00 3 109 6 -120 
H 5 1.00 1 109 7  120 
H 5 1.00 1 109 7 -120 
H 6 1.00 4 109 8  120 
H 6 1.00 4 109 8 -120 
H 7 1.00 5 109 1 -120 
H 7 1.00 5 109 1  120 
H 7 1.00 5 109 1    0 
H 8 1.00 6 109 4 -120 
H 8 1.00 6 109 4  120 
H 8 1.00 6 109 4    0 
";

                    my $mol = $bldr->read_string_mol( $string, 'zmat' );
                    my $sg2 = $mol->get_atoms(1);
                    my $sg1 = $mol->get_atoms(2);
                    my $ca1 = $mol->get_atoms(4);
                    my $ca2 = $mol->get_atoms(5);
                    my $nd1 = $mol->get_atoms(6);
                    my $nd2 = $mol->get_atoms(7);

                    if (   $ca1->distance($ca2) > 3.5
                        && $sg1->distance($nd2) > 3.95 
                        && $sg2->distance($nd1) > 3.95 
                    )
                    {
                        $mol->print_xyz($fh);    # cutoffs from cys.sqlite
                    }
                }
            }
        }
    }
}

