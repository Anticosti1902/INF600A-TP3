require 'test_helper'

describe "GestionVins" do
  describe "noter" do
    context "fichier de vins avec plusieurs vins" do
      let(:lignes) { IO.readlines("test_acceptation/4vins.txt") }

      it_ "note le vin si le numero specifie existe et est le premier vin non note" do
        note = 5
        commentaire = "Dense. Aromatique et complexe. Charnu. Excellent."

        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "noter 2 #{note} '#{commentaire}'" )
          end
        end

        nouveau_contenu.size.must_equal 4
        vin2 = nouveau_contenu.find { |l| l =~ /^2:/ }
        vin2.must_match /#{note}:#{commentaire}/

        vin4 = nouveau_contenu.find { |l| l =~ /^4:/ }
        vin4.must_match /::$/

        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "note le vin si le numero specifie existe et n'est pas le premier vin non note" do
        note = 5
        commentaire = "Dense. Aromatique et complexe. Charnu. Excellent."

        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "noter 4 #{note} '#{commentaire}'" )
          end
        end

        nouveau_contenu.size.must_equal 4
        vin4 = nouveau_contenu.find { |l| l =~ /^4:/ }
        vin4.must_match /#{note}:#{commentaire}/

        vin2 = nouveau_contenu.find { |l| l =~ /^2:/ }
        vin2.must_match /::$/

        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "genere une erreur si le numero de vin n'existe pas", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /noter.*6.*existe pas/i do
            run_gv( 'noter 6 3 "Tres bon"' )
          end
        end
      end

      it_ "genere une erreur si argument en trop", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /Nombre incorrect.*arguments?|Argument.*trop.*foo/i do
            run_gv( 'noter 4 3 "Frais et gouleyant. Tres bon." foo' )
          end
        end
      end

      it_ "genere une erreur si note pas comprise entre 0 et 5", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /nombre invalide.*6?/i do
            run_gv( 'noter 4 6 "Frais et gouleyant. Tres bon."' )
          end
        end
      end

      it_ "genere une erreur si le vin est deja note", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /1.*deja note/i do
            run_gv( 'noter 1 4 "Frais et gouleyant. Tres bon."' )
          end
        end
      end
    end

    it_ "genere une erreur si depot inexistant", :intermediaire do
      fichier = $DEPOT_DEFAUT
      FileUtils.rm_f fichier
      genere_erreur /fichier.*#{fichier}.*existe pas/i do
        run_gv( 'noter 2' )
      end
    end

    it_ "genere une erreur si on utilise stdin avec noter", :intermediaire do
      lignes = IO.readlines("test_acceptation/4vins.txt")
      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_erreur /stdin.*ne peut pas etre utilise/i do
          run_gv( 'selectionner --non-bus', "--depot=- noter" )
        end
      end
    end
  end
end
