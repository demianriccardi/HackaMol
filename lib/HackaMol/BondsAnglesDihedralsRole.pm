package HackaMol::BondsAnglesDihedralsRole;

# ABSTRACT: Array traits for containers of HackaMol Bonds, Angles, Dihedrals.
use Moose::Role;

has $_ => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Any]',
    default => sub { [] },
    lazy    => 1,
    handles => {
        "has_$_"    => 'count',
        "push_$_"   => 'push',
        "get_$_"    => 'get',
        "set_$_"    => 'set',
        "all_$_"    => 'elements',
        "count_$_"  => 'count',
        "delete_$_" => 'delete',
        "clear_$_"  => 'clear',
    },
) foreach qw(bonds angles dihedrals);

no Moose::Role;

1;

__END__

=head1 SYNOPSIS
    use HackaMol::Atom;
    use HackaMol::Angle;
    use HackaMol::Dihedral;
    
    my $atom1 = HackaMol::Atom->new(
        name    => 'O1',
        coords  => [ V( 2.05274, 0.01959, -0.07701 ) ],
        Z       => 8,
    );
    
    my $atom2 = HackaMol::Atom->new(
        name    => 'H1',
        coords  => [ V( 1.08388, 0.02164, -0.12303 ) ],
        Z       => 1,
    );
    
    my $atom3 = HackaMol::Atom->new(
        name    => 'H2',
    coords  => [ V( 2.33092, 0.06098, -1.00332 ) ],
    Z       => 1,
    );
    
    my $atom4 = HackaMol::Atom->new(
        name    => 'Cl',
        coords  => [ V(-0.91386, 0.02587, -0.21792 ) ],
        Z       => 17,
    );
    
    my @atoms = ($atom1,$atom2,$atom3,$atom4);
    
    my $bond1 = HackaMol::Angle->new(name=> 'test', atoms[@atoms[0,1]]);
    my $bond2 = HackaMol::Angle->new(name=> 'test', atoms[@atoms[0,2]]);
    
    my @bonds = $atom1->all_bonds;

    my $angle1 = HackaMol::Angle->new(name=> 'test', atoms[@atoms[1,0,2]]);
    my $angle2 = HackaMol::Angle->new(name=> 'test', atoms[@atoms[0,1,3]]);
    
    my @angles = $atom1->all_angles;
    
    my $dihe1  = HackaMol::Dihedral->new(name=> 'test', atoms[@atoms]);
    my $dihe2  = HackaMol::Dihedral->new(name=> 'test', atoms[reverse @atoms]);
    
    my @dihes  = $atom1->all_dihedrals;
    
=head1 DESCRIPTION
 
The HackaMol BondsAnglesDihedralsRole provides ARRAY trait methods for interacting with 
arrays of bonds angles and dihedrals. The Molecule class consumes this
role. The Atom class does not. Thus, Molecules are responsible for reporting multiple bonded 
connections for any given atom.

=array_method push_bonds, get_bonds, set_bonds, all_bonds, count_bonds, delete_bonds, clear_bonds

ARRAY traits for the bonds attribute, respectively: push, get, set, elements, count, delete, clear

=array_method push_bonds

push bond on to bonds array

  $group->push_bonds($bond1, $bond2, @otherbonds);

=array_method all_bonds

returns array of all elements in bonds array

  print $_->bond_order, "\n" foreach $group->all_bonds; 

=array_method get_bonds

return element by index from bonds array

  print $group->get_bonds(1); # returns $bond2 from that pushed above

=array_method set_bonds

set bonds array by index

  $group->set_bonds(1, $bond1);

=array_method count_bonds

return number of bonds in the array  
  
  print $group->count_bonds; 

=array_method delete_bonds

deletes bond from bonds array and returns it.

=array_method clear_bonds

clears bonds array

=array_method push_angles, get_angles, set_angles, all_angles, count_angles, delete_angles, clear_angles

ARRAY traits for the bonds attribute, respectively: push, get, set, elements, count, delete, clear

Analogous to those for bonds.

=array_method push_dihedrals, get_dihedrals, set_dihedrals, all_dihedrals, count_dihedrals, delete_dihedrals, clear_dihedrals

ARRAY traits for the bonds attribute, respectively: push, get, set, elements, count, delete, clear

Analogous to those for bonds.

=head1 SEE ALSO

=for :list
* L<HackaMol::Molecule>

