require 'openbabel'
require 'rubabel'

module Rubabel
  class Molecule
    include Enumerable
    attr_accessor :obmol

    class << self
      def from_file(file, type=nil)
        Rubabel.read_file(file, type)
      end

      def from_string(string, type=:smi)
        Rubabel.read_string(string, type)
      end
    end


    def initialize(obmol, obconv=nil)
      @obconv = obconv
      @obmol = obmol
    end

    def charge
      @obmol.get_total_charge
    end

    def charge=(v)
      @obmol.set_total_charge(v)
    end

    def exact_mass
      @obmol.get_exact_mass
    end

    def mol_wt
      @obmol.get_mol_wt
    end

    alias_method :avg_mass, :mol_wt

    def exact_mass
      @obmol.get_exact_mass
    end

    # Not yet properly implemented.  Currently returns an object of type
    # SWIG::TYPE_p_std__vectorT_double_p_std__allocatorT_double_p_t_t
    def conformers
      vec = @obmol.get_conformers
      vec.methods - Object.new.methods
      abort 'here'
    end

    def add_h!
      @obmol.add_hydrogens
    end
    #alias_method :add_h!, :add_hydrogens!

    def remove_h!
      @obmol.delete_hydrogens
    end

    def separate!
      @obmol.separate
    end

    # returns a string representation of the molecular formula
    def formula
      @obmol.get_formula
    end

    # equal if their canonical SMILES strings (including ID) are equal.  This
    # may become more rigorous in the future
    def ==(other)
      self.write_string(:can) == other.write_string(:can)
    end

    def each_atom(&block)
      # could use the native iterator in the future
      block or return enum_for(__method__)
      (1..@obmol.num_atoms).each do |n|
        block.call( @obmol.get_atom(n) )
      end
    end
    alias_method :each, :each_atom

    # returns the array of atoms. Consider using #each
    def atoms
      each_atom.map.to_a
    end

    def dim
      @obmol.get_dimension
    end

    #def each_bond(&block)

    # TODO: implement
    #def calc_desc(descnames=[])
    #end

    # TODO: implement
    # list of supported descriptors. (Not Yet Implemented!)
    #def descs
    #end

    def fingerprint(type='FP2')
    end

    alias_method :calc_fp, :fingerprint

    # emits smiles without the trailing tab, newline, or id.  Use write_string
    # to get the default OpenBabel behavior (ie., tabs and newlines).
    def to_s(type=:can)
      string = write_string(type)
      case type
      when :smi, :smiles, :can
        # remove name with openbabel options in the future
        string.split(/\s+/).first
      else
        string
      end
    end

    def num_atoms() @obmol.num_atoms  end
    def num_bonds() @obmol.num_bonds  end
    def num_hvy_atoms() @obmol.num_hvy_atoms  end
    def num_residues() @obmol.num_residues  end
    def num_rotors() @obmol.num_rotors  end

    def write_string(type=:can)
      @obconv ||= OpenBabel::OBConversion.new
      @obconv.set_out_format(type.to_s)
      @obconv.write_string(@obmol)
    end

  end
end

# NOTES TO SELF:
=begin
~/tools/openbabel-rvmruby1.9.3/bin/babel -L descriptors
abonds    Number of aromatic bonds
atoms    Number of atoms
bonds    Number of bonds
cansmi    Canonical SMILES
cansmiNS    Canonical SMILES without isotopes or stereo
dbonds    Number of double bonds
formula    Chemical formula
HBA1    Number of Hydrogen Bond Acceptors 1 (JoelLib)
HBA2    Number of Hydrogen Bond Acceptors 2 (JoelLib)
HBD    Number of Hydrogen Bond Donors (JoelLib)
InChI    IUPAC InChI identifier
InChIKey    InChIKey
L5    Lipinski Rule of Five
logP    octanol/water partition coefficient
MR    molar refractivity
MW    Molecular Weight filter
nF    Number of Fluorine Atoms
s    SMARTS filter
sbonds    Number of single bonds
smarts    SMARTS filter
tbonds    Number of triple bonds
title    For comparing a molecule's title
TPSA    topological polar surface area

# why can't I find any descriptors????
>> require 'openbabel'
=> true
>> OpenBabel::OBDescriptor.find_type("logP")
=> nil
>> OpenBabel::OBDescriptor.find_type("MR")
=> nil

=end
