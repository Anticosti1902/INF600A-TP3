require 'test_helper'

# Methodes auxiliaires pour alleger les tests ci-bas.
def motif_mot_complet( regex )
  /\b#{GV::Motifs.const_get(regex)}\b/
end

def motif_ligne_complete( regex )
  /^#{GV::Motifs.const_get(regex)}$/
end

describe GV::Motifs do
  describe GV::Motifs::NUM_VIN do
    it_ "matche des nombres complets et valides", :intermediaire do
      "1".must_match motif_mot_complet( :NUM_VIN )
      "901".must_match motif_mot_complet( :NUM_VIN )
    end

    it_ "ne matche pas des nombres avec autres caracteres", :intermediaire do
      "999X".wont_match motif_mot_complet( :NUM_VIN )
      "X999".wont_match motif_mot_complet( :NUM_VIN )
      " 999 ".must_match motif_mot_complet( :NUM_VIN )
    end
  end

  describe GV::Motifs::DATE do
    it_ "matche des date completes et valides dans le format JJ/MM/AA", :intermediaire do
      "10/10/10".must_match motif_mot_complet( :DATE )
      "01/01/01".must_match motif_mot_complet( :DATE )
      "29/02/01".must_match motif_mot_complet( :DATE )
      "30/02/01".must_match motif_mot_complet( :DATE ) # Validation lexicale seulement!
    end

    it_ "ne matche pas des dates assurement impossibles", :intermediaire do
      "10/13/10".wont_match motif_mot_complet( :DATE )
      "32/11/11".wont_match motif_mot_complet( :DATE )
      "12/13/12".wont_match motif_mot_complet( :DATE )
      "12/33/12".wont_match motif_mot_complet( :DATE )
    end

    it_ "ne matche pas des dates avec d'autres formats", :intermediaire do
      "10/10/2010".wont_match motif_mot_complet( :DATE )
      "1/1/1".wont_match motif_mot_complet( :DATE )
      "12-12-12".wont_match motif_mot_complet( :DATE )
    end

    it_ "ne matche pas des caracteres autress", :intermediaire do
      "1x 10 10".wont_match motif_mot_complet( :DATE )
    end
  end

  describe GV::Motifs::MILLESIME do
    it_ "matche des annees completes", :intermediaire do
      "2010".must_match motif_mot_complet( :MILLESIME )
      "1990".must_match motif_mot_complet( :MILLESIME )
    end

    it_ "ne matche pas des annees incomplets ou autres", :intermediaire do
      "00".wont_match motif_mot_complet( :MILLESIME )
      "22.0".wont_match motif_mot_complet( :MILLESIME )
      "deux mille".wont_match motif_mot_complet( :MILLESIME )
    end
  end

  describe GV::Motifs::PRIX do
    it_ "matche des prix complets avec deux decimales", :intermediaire do
      "0.99".must_match motif_mot_complet( :PRIX )
      "9.99".must_match motif_mot_complet( :PRIX )
      "22.90".must_match motif_mot_complet( :PRIX )
      "122.00".must_match motif_mot_complet( :PRIX )
    end

    it_ "ne matche pas des prix sans deux decimales ou autres", :intermediaire do
      "22".wont_match motif_mot_complet( :PRIX )
      "22.0".wont_match motif_mot_complet( :PRIX )
      "vingt-deux".wont_match motif_mot_complet( :PRIX )
      "122.000".wont_match motif_mot_complet( :PRIX )
    end
  end

  describe GV::Motifs::CHAINE do
    it_ "matche une appellation avec apostrophes", :intermediaire do
      "\"Pays D'Oc\"".must_match motif_ligne_complete( :APPELLATION )
    end

    it_ "matche une appellation entre apostrophes", :intermediaire do
      "'Beaujolais Villages'".must_match motif_ligne_complete( :APPELLATION )
    end

    it_ "matche un commentaire avec des guillemets", :intermediaire do
      '\'Tres bon, de style "Pinot"\''.must_match motif_ligne_complete( :COMMENTAIRE )
    end

    it_ "matche un commentaire entre guillemets", :intermediaire do
      '"Tres bon, de style Pinot"'.must_match motif_ligne_complete( :COMMENTAIRE )
    end

    it_ "matche un nom avec divers caracteres", :intermediaire do
      "Cotes-du-Rhone-Rasteau".must_match motif_ligne_complete( :NOM )
    end
  end

  describe GV::Motifs::NOTE do
    it_ "matche un nombre compris entre NOTE_MIN et NOTE_MAX", :intermediaire do
      (GV::Motifs::NOTE_MIN..GV::Motifs::NOTE_MAX).each do |i|
        i.to_s.must_match motif_mot_complet( :NOTE )
      end
    end

    it_ "ne matche rien d'autre", :intermediaire do
      "-1".wont_match( /^#{:NOTE}$/ )
      " 4 ".must_match motif_mot_complet( :NOTE )
      "#{GV::Motifs::NOTE_MAX+1}".wont_match motif_mot_complet( :NOTE )
      "abc".wont_match motif_mot_complet( :NOTE )
    end
  end
end
