package HackaMol::Roles::ReadPdbRole;

# ABSTRACT: Read files with molecular information
use Moose::Role;
use HackaMol::PeriodicTable qw(_element_name _trim _qstring_num);
use Math::Vector::Real;
use Carp;

sub read_pdb_atoms {

    #read pdb file and generate list of Atom objects
    my $self = shift;
    my $fh   = shift;
    #my $file = shift;
    #my $fh   = FileHandle->new("<$file") or croak "unable to open $file";

    my @atoms;
    my ( $n, $t ) = ( 0, 0 );
    my $q_tbad          = 0;
    my $something_dirty = 0;

    while (<$fh>) {

        if (/^(?:MODEL\s+(\d+))/) {

            #$t = $1 - 1; # I don't like this!!  set increment t instead.. below
            $n      = 0;
            $q_tbad = 0;    # flag a bad model and never read again!
        }
        elsif (/^(?:ENDMDL)/) {
            $t++;
        }
        elsif (/^(?:HETATM|ATOM)/) {
            next if $q_tbad;
            my (
                $record_name, $serial,  $name,    $altloc,
                $resName,     $chainID, $resSeq,  $icod,
                $x,           $y,       $z,       $occ,
                $B,           $segID,   $element, $charge
            ) = unpack "A6A5x1A4A1A3x1A1A4A1x3A8A8A8A6A6x6A4A2A2", $_ . (" " x 12); # padded out to accommodate truncated pdbs

            if   ( $charge =~ m/\d/ ) { $charge = _qstring_num($charge) }
            else                      { $charge = 0 }

            if   ( $chainID =~ m/\w/ ) { $chainID = uc( _trim($chainID) ) }
            else                       { $chainID = ' ' }

            $name    = _trim($name);
            $resName = _trim($resName);
            $resSeq  = _trim($resSeq);

            #$resSeq  = 0 if ( $resSeq < 0 );
            $serial = _trim($serial);
            $segID  = _trim($segID);

            $element = ucfirst( lc( _trim($element) ) );
            my $qdirt = 0;
            ( $element, $qdirt ) = _element_name($name)
              unless ( $element =~ /\w+/ );
            $something_dirty++ if ($qdirt);
            my $xyz = V( $x, $y, $z );

            if ( $t == 0 ) {
                $atoms[$n] = HackaMol::Atom->new(
                    name        => $name,
                    record_name => $record_name,
                    serial      => $serial,
                    chain       => $chainID,
                    symbol      => $element,
                    charges     => [$charge],
                    coords      => [$xyz],
                    occ         => $occ * 1,
                    bfact       => $B * 1,
                    resname     => $resName,
                    resid       => $resSeq,
                    icode       => $icod,
                    segid       => $segID,
                    altloc      => $altloc,
                );
                $atoms[$n]->is_dirty($qdirt) unless $atoms[$n]->is_dirty;
            }
            else {
                #croak condition if atom changes between models
                if ( $n > $#atoms or  $name ne $atoms[$n]->name
                    or $element ne $atoms[$n]->symbol )
                {
                    my $carp_message =
                        "BAD t->$t PDB Atom $n "
                      . "serial $serial resname $resName "
                      . "has changed";
                    carp $carp_message;
                    $q_tbad = $t;    # this is a bad model!
                                     #wipe out all the coords prior
                    $atoms[$_]->delete_coords($t) foreach 0 .. $n - 1;
                    $t--;
                    next;
                }
                $atoms[$n]->set_coords( $t, $xyz );
            }
            $n++;
        }
    }

    # set iatom to track the array.  diff from serial which refers to pdb
    $atoms[$_]->iatom($_) foreach ( 0 .. $#atoms );
    if ($something_dirty) {
        if ( $self->hush_read <= 0 ) {
            my $message = "MolReadRole> found $something_dirty dirty atoms. ";
            $message .= "Check symbols and lookup names PeriodicTable.pm:";
            my @sprintf;
            foreach my $atom (grep {$_->is_dirty} @atoms){
              push @sprintf, sprintf(" DIRTY: index %s name %s element %s %10.3f %10.3f %10.3f;", $atom->iatom, $atom->name, $atom->symbol, @{$atom->xyz});
            }
            $message .= $_ foreach @sprintf;
            carp $message;
        }
    }
    return (@atoms);
}

no Moose::Role;

1;

__END__

=head1 SYNOPSIS

   my @atoms = HackaMol->new
                       ->read_pdb_atoms("some.pdb");

=head1 DESCRIPTION

The HackaMol::Roles::ReadPdbRole provides read_pdb_atoms reading protein database files.

=method read_pdb_atoms

One argument: the filename
Returns a list of HackaMol::Atom objects.

=head1 Additional information

According to the PDB specification, the element symbol should be present in columns 
77-78.  The element is often ommitted by programs, such as charmm, that can write 
pdbs because it makes the file larger, and the information is accessible somewhere 
else (protein structure file). Unfortunately, other programs require the information.  
HackaMol::MolReadRole, uses HackaMol::PeriodicTable to map common names to the element 
(e.g. POT => 'K'). read_pdb_atoms will carp if the name is not in the hash, and then 
set the element to the first letter of the name. If you see one of these messages for 
a common atom, please submit an issue or pull request so the atom can be added!

=head1 SEE ALSO

=for :list
* L<HackaMol>
* L<HackaMol::Atom>
* L<HackaMol::Roles::MolReadRole>
* L<Protein Data Bank|http://pdb.org>

