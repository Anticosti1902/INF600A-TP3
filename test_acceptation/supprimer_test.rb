require 'test_helper'

describe "GestionVins" do
  describe "supprimer" do
    context "cave avec plusieurs vins" do
      let(:lignes) { IO.readlines("test_acceptation/4vins.txt") }

      it_ "supprime le vin si le numero specifie existe" do
        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "supprimer 4" )
          end
        end

        nouveau_contenu.find { |l| l =~ /^4/ }.must_be_nil
        nouveau_contenu.size.must_equal 3

        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "genere une erreur si le numero de vin n'existe pas", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /supprimer.*6.*existe pas/i do
            run_gv( "supprimer 6" )
          end
        end
      end

      it_ "genere une erreur si le vin a deja ete note", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /1.*deja note/i do
            run_gv( "supprimer 1" )
          end
        end
      end

      it_ "genere une erreur si argument en trop", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /Nombre incorrect.*arguments?|Argument.*trop.*foo/i do
            run_gv( 'supprimer 4 foo' )
          end
        end
      end
    end

    it_ "genere une erreur si depot inexistant", :intermediaire do
      fichier = $DEPOT_DEFAUT
      FileUtils.rm_f fichier
      genere_erreur /fichier.*#{fichier}.*existe pas/i do
        run_gv( 'supprimer 2' )
      end
    end

    it_ "genere une erreur si on utilise stdin avec supprimer", :intermediaire do
      lignes = IO.readlines("test_acceptation/4vins.txt")
      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_erreur /stdin.*ne peut pas etre utilise/i do
          run_gv( 'selectionner --non-bus', '-- supprimer' )
        end
      end
    end

    it_ "supprime les vins dont les numeros sont specifies sur une seule ligne stdin", :intermediaire do
      avec_fichier 'data.txt', [" 2 4  "] do
        lignes = IO.readlines("test_acceptation/4vins.txt")
        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "supprimer < data.txt" )
          end
        end

        nouveau_contenu.find { |l| l =~ /^2:/ }.must_be_nil
        nouveau_contenu.find { |l| l =~ /^4:/ }.must_be_nil
        nouveau_contenu.size.must_equal 2

        FileUtils.rm_f $DEPOT_DEFAUT
      end
    end

    it_ "supprime les vins dont les numeros sont specifies sur plusieurs lignes de stdin", :intermediaire do
      avec_fichier 'data.txt', [" 2 ",  "   " " 4  "] do
        lignes = IO.readlines("test_acceptation/4vins.txt")
        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "supprimer < data.txt" )
          end
        end

        nouveau_contenu.find { |l| l =~ /^2:/ }.must_be_nil
        nouveau_contenu.find { |l| l =~ /^4:/ }.must_be_nil
        nouveau_contenu.size.must_equal 2

        FileUtils.rm_f $DEPOT_DEFAUT
      end
    end

    it_ "ne supprime aucun des vins dont les numeros sont specifies via stdin si format errone", :avance do
      lignes = IO.readlines("test_acceptation/4vins.txt")
      avec_fichier 'data.txt', ["  2 4 ", "  xx  "] do
        avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          FileUtils.cp $DEPOT_DEFAUT, "#{$DEPOT_DEFAUT}.avant"
          genere_erreur( /Format.*incorrect.*numero.*xx/i ) do
            run_gv( "supprimer < data.txt" )
          end
        end
      end

      %x{cmp #{$DEPOT_DEFAUT} #{$DEPOT_DEFAUT}.avant; echo $?}.must_equal "0\n"

      FileUtils.rm_f $DEPOT_DEFAUT
      FileUtils.rm_f "#{$DEPOT_DEFAUT}.avant"
    end

    it_ "ne supprime aucun des vins dont les numeros sont specifies via stdin si numero inexistant", :avance do
      lignes = IO.readlines("test_acceptation/4vins.txt")
      avec_fichier 'data.txt', ["  2 4 ", "  22  "] do
        avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          FileUtils.cp $DEPOT_DEFAUT, "#{$DEPOT_DEFAUT}.avant"
          genere_erreur( /vin.*numero.*22.*existe pas/i ) do
            run_gv( "supprimer < data.txt" )
          end
        end
      end

      %x{cmp #{$DEPOT_DEFAUT} #{$DEPOT_DEFAUT}.avant; echo $?}.must_equal "0\n"

      FileUtils.rm_f $DEPOT_DEFAUT
      FileUtils.rm_f "#{$DEPOT_DEFAUT}.avant"
    end

    it_ "ne supprime aucun des vins dont les numeros sont specifies via stdin si vin deja note", :avance do
      lignes = IO.readlines("test_acceptation/4vins.txt")
      avec_fichier 'data.txt', ["  2 4 ", "  1 "] do
        avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          FileUtils.cp $DEPOT_DEFAUT, "#{$DEPOT_DEFAUT}.avant"
          genere_erreur( /vin.*numero.*1.*deja.*note/i ) do
            run_gv( "supprimer < data.txt" )
          end
        end
      end

      %x{cmp #{$DEPOT_DEFAUT} #{$DEPOT_DEFAUT}.avant; echo $?}.must_equal "0\n"

      FileUtils.rm_f $DEPOT_DEFAUT
      FileUtils.rm_f "#{$DEPOT_DEFAUT}.avant"
    end
  end
end
