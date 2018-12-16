require 'test_helper'

require 'json'

describe GV::Vin do
  let(:erreurs_possibles) { [ArgumentError, RuntimeError, StandardError] }

  let(:date_achat) { Date.new( 2014, 10, 11) }

  let(:chianti) { GV::Vin.new(10, date_achat, :rouge, "Chianti Classico", 2011, "Fontodi", 20.99) }

  let(:chianti_note) { GV::Vin.new(11, date_achat, :rouge, "Chianti Classico",  2011, "Fontodi", 20.99,
                                   4, "Tres bon!") }

  describe ".new" do
    it_ "cree un vin non note" do
      chianti.numero.must_equal 10
      chianti.date_achat.must_equal date_achat
      chianti.type.must_equal :rouge
      chianti.appellation.must_equal "Chianti Classico"
      chianti.millesime.must_equal 2011
      chianti.nom.must_equal "Fontodi"
      chianti.prix.must_equal 20.99

      refute chianti.note?
      refute chianti.bu?
      lambda { chianti.note }.must_raise RuntimeError
      lambda { chianti.commentaire }.must_raise RuntimeError
    end

    it_ "cree un vin note" do
      chianti_note.numero.must_equal 11
      chianti_note.date_achat.must_equal date_achat
      chianti_note.type.must_equal :rouge
      chianti_note.appellation.must_equal "Chianti Classico"
      chianti_note.millesime.must_equal 2011
      chianti_note.nom.must_equal "Fontodi"
      chianti_note.prix.must_equal 20.99

      assert chianti_note.note?
      assert chianti_note.bu?
      chianti_note.note.must_equal 4
      chianti_note.commentaire.must_equal "Tres bon!"
    end
  end

  describe ".creer" do
    it_ "cree un vin avec nouveau numero qui n'est pas bu" do
      GV::Vin.instance_variable_set(:@numero_max, 10) # Plus direct... meme si bizarre!
      date_achat = Time.new(2015, 10, 12).to_date

      vin = nil
      Time.stub :now, date_achat do # Pour avoir la date appropriee.
        vin = GV::Vin.creer( :rouge, "Chianti", 2012, "Fontodi", 21.99 )
      end

      vin.numero.must_equal 11
      vin.date_achat.must_equal date_achat

      vin.type.must_equal :rouge
      vin.appellation.must_equal "Chianti"
      vin.millesime.must_equal 2012
      vin.nom.must_equal "Fontodi"
      vin.prix.must_equal 21.99

      refute vin.bu?
    end
  end

  describe "#<=> --- tests de base" do
    context "compare juste les numeros (defaut)" do
      it_ "retourne 0 par rapport a lui-meme" do
        (chianti <=> chianti).must_equal 0
        (chianti_note <=> chianti_note).must_equal 0
      end

      it_ "retourne -1 par rapport a un numero plus grand" do
        (chianti <=> chianti_note).must_equal( -1 )
      end

      it_ "retourne +1 par rapport a un numero plus petit" do
        (chianti_note <=> chianti).must_equal 1
      end

      it_ "permet les comparaison avec les operateurs usuels" do
        assert chianti == chianti
        assert chianti_note == chianti_note

        assert chianti < chianti_note
        assert chianti <= chianti_note

        assert chianti_note > chianti
        assert chianti_note >= chianti
      end
    end
  end

  describe "#<=> --- tests intermediaire" do
    context "avec des comparateurs explicites et possiblement multiples" do
      let(:v1) { GV::Vin.new(10, date_achat, :rouge, "Chianti", 2011, "Fontodi", 20.99) }
      let(:v2) { GV::Vin.new(11, date_achat, :rouge, "Chianti Classico", 2012, "Fontodi", 19.99) }

      before { @comparateurs = GV::Vin.comparateurs }
      after  { GV::Vin.comparateurs = @comparateurs }

      it_ "compare selon le numero si aucun comparateur specifie", :intermediaire do
        assert v1 == v1
        assert v2 == v2
        assert v1 < v2
        assert v1 <= v2
      end

      it_ "compare selon le numero si :numero specifie explicitement", :intermediaire do
        GV::Vin.comparateurs = [:numero]
        assert v1 == v1
        assert v2 == v2
        assert v1 < v2
        assert v1 <= v2
      end

      it_ "traite un seul comparateur", :intermediaire do
        GV::Vin.comparateurs = [:millesime]
        assert v1 < v2
      end

      it_ "traite deux comparateurs", :intermediaire do
        GV::Vin.comparateurs = [:prix, :nom]
        assert v1 > v2

        GV::Vin.comparateurs = [:appellation, :millesime]
        assert v1 < v2

        GV::Vin.comparateurs = [:nom, :date_achat]
        assert v1 == v2
      end

      it_ "produit un resultat qui depend du nombre de comparateurs", :intermediaire do
        GV::Vin.comparateurs = [:nom]
        assert v1 == v2

        GV::Vin.comparateurs = [:nom, :prix]
        assert v1 > v2

        GV::Vin.comparateurs = [:nom, :millesime]
        assert v1 < v2
      end

      it_ "traite deux comparateurs et le resultat depend de l'ordre", :intermediaire do
        GV::Vin.comparateurs = [:millesime, :prix]
        assert v1 < v2

        GV::Vin.comparateurs = [:prix, :millesime]
        assert v1 > v2
      end

      it_ "traite trois comparateurs", :intermediaire do
        GV::Vin.comparateurs = [:prix, :appellation, :nom]
        assert v1 > v2

        GV::Vin.comparateurs = [:type, :nom, :date_achat]
        assert v1 == v2
      end

      it_ "traite quatre comparateurs", :intermediaire do
        GV::Vin.comparateurs = [:nom, :appellation, :date_achat, :numero]
        assert v1 < v2
      end
    end
  end

  describe "#to_s -- tests_base" do
    it_ "genere par defaut la forme longue pour un vin non note" do
      assert_match( %r{10 \[rouge - 20.99\$\]: Chianti Classico 2011, Fontodi \(11/10/14\) =>  \{\}},
                    chianti.to_s )
    end

    it_ "genere par defaut la forme longue pour un vin note" do
      assert_match( %r{11 \[rouge - 20.99\$\]: Chianti Classico 2011, Fontodi \(11/10/14\) => 4 \{Tres bon!\}},
                    chianti_note.to_s )
    end
  end

  describe "#to_s -- tests_intermediaire" do
    it_ "produit par defaut le meme resultat que '%I [%T - %P$]: %A %M, %N (%D) => %n {%c}'", :intermediaire do
      chianti.to_s
        .must_equal chianti.to_s('%I [%T - %.2P$]: %A %M, %N (%D) => %n {%c}')
    end

    it_ "traite les justifications et la largeur maximum", :intermediaire do
      chianti.to_s( "%4I:%-4I:%.4I" ).must_equal '  10:10  :0010'
    end

    it_ "traite les justifications et la largeur maximum y compris pour le prix", :intermediaire do
      chianti.to_s( "%4I:%-8.3P:%8.1P" ).must_equal '  10:20.990  :    21.0'
    end

    it_ "genere une erreur quand une specification de champ non valide est indiquee", :intermediaire do
      assert_raises( *erreurs_possibles ) { chianti.to_s( "xxx %X %s %T" ) }
      assert_raises( *erreurs_possibles ) { chianti.to_s( "xxx %d %T %T" ) }
    end
  end

  describe "#to_s" do
    it_ "assure que le format n'est pas modifie par une utilisation", :intermediaire do
      format = "%I => %N"

      chianti.to_s( format ).must_equal '10 => Fontodi'
      format.must_equal "%I => %N"
    end
  end

  describe "#noter" do
    it_ "devient bu lorsqu'on le note" do
      refute chianti.bu?

      chianti.noter( 3, "Assez bon" )

      assert chianti.bu?
      chianti.note.must_equal 3
      chianti.commentaire.must_equal "Assez bon"
    end
  end

  describe "#to_json" do
    it_ "produit un objet" do
      (GV::Vin.new_from_json chianti.to_json).must_equal chianti
    end
  end
end

