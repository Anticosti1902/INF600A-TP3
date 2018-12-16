require 'test_helper'

describe BDTexte do

  class Foo
    def initialize( x, y )
      @x, @y = x, y
    end

    def to_bar
      "#{@x} #{@y}"
    end

    def Foo.new_from_bar( ligne )
      Foo.new( *ligne.split.map(&:to_i) )
    end

    def ==( autre )
      # Requis pour les assertions.
      @x == autre.instance_eval("@x") && @y == autre.instance_eval("@y")
    end
  end

  it "charge correctement des objets de classe simple" do
    foos = nil
    BDTexte.config( :bar, Foo )
    avec_fichier 'foo.txt', ['10 20', '30 40'] do
      foos = BDTexte.charger( 'foo.txt' )
    end

    foos.must_equal [Foo.new(10, 20), Foo.new(30, 40)]
  end

  it "sauve correctement des objets de classe simple" do
    foos = [Foo.new(10, 20), Foo.new(30, 40)]

    BDTexte.config( :bar, Foo )

    FileUtils.rm 'foo.txt' if File.exist? 'foo.txt'
    FileUtils.touch 'foo.txt'
    BDTexte.charger( 'foo.txt' ).must_be_empty

    BDTexte.sauver 'foo.txt', foos
    BDTexte.charger( 'foo.txt' ).must_equal foos

    assert File.exist? 'foo.txt.bak'

    FileUtils.rm_f 'foo.txt'
    FileUtils.rm_f 'foo.txt.bak'
  end
end
