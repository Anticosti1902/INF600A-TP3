require 'test_helper'

describe "GestionVins" do
  describe "lister" do
    it_ "liste un fichier vide" do
      avec_fichier $DEPOT_DEFAUT, [] do
        execute_sans_sortie_ou_erreur do
          run_gv( 'lister' )
        end
      end
    end

    it_ "liste, par defaut, tous les vins dans la forme longue" do
      lignes = IO.readlines("test_acceptation/4vins.txt")

      attendu = [
                 '1 [rouge - 26.65$]: Chianti Classico 2015, Volpaia (10/06/18) => 4 {Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.}',
                 '2 [rouge - 26.65$]: Chianti Classico 2014, Volpaia (10/06/18) =>  {}',
                 '4 [blanc - 16.50$]: Alsace 2016, Pfaff (03/07/18) =>  {}',
                 '5 [rose  - 18.50$]: Cotes de Provence 2017, Roseline (03/07/18) => 3 {Frais, leger.}',
                ]

      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_sortie attendu do
          run_gv( 'lister' )
        end
      end
    end

    it_ "liste tous les vins dans la forme courte avec l'option --court", :intermediaire do
      lignes = IO.readlines("test_acceptation/4vins.txt")

      attendu = [
                 '1 [26.65$]: Chianti Classico 2015, Volpaia',
                 '2 [26.65$]: Chianti Classico 2014, Volpaia',
                 '4 [16.50$]: Alsace 2016, Pfaff',
                 '5 [18.50$]: Cotes de Provence 2017, Roseline',
                ]

      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_sortie attendu do
          run_gv( 'lister --court' )
        end
      end
    end

    it_ "genere une erreur si fichier inexistant", :intermediaire do
      FileUtils.rm_f $DEPOT_DEFAUT
      genere_erreur /fichier.*#{$DEPOT_DEFAUT}.*existe pas/i do
        run_gv( 'lister' )
      end
    end

    it_ "genere une erreur si arguments en trop", :intermediaire do
      lignes = IO.readlines("test_acceptation/4vins.txt")
      attendu = [
                 '1 [rouge - 26.65$]: Chianti Classico 2015, Volpaia (10/06/18) => 4 {Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.}',
                 '2 [rouge - 26.65$]: Chianti Classico 2014, Volpaia (10/06/18) =>  {}',
                 '4 [blanc - 16.50$]: Alsace 2016, Pfaff (03/07/18) =>  {}',
                 '5 [rose  - 18.50$]: Cotes de Provence 2017, Roseline (03/07/18) => 3 {Frais, leger.}'
                ]

      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_erreur /Argument.*en trop/i do
          run_gv( 'lister foo' )
        end
      end
    end

    context "fichier des vins autre que celui par defaut" do
      let(:lignes) { IO.readlines("test_acceptation/4vins.txt") }
      let(:fichier) { '.foo.txt' }

      it_ "genere une erreur si depot inexistant", :intermediaire do
        FileUtils.rm_f fichier
        genere_erreur /fichier.*#{fichier}.*existe pas/i do
          run_gv( "--depot=#{fichier} lister" )
        end
      end

      it_ "liste les vins", :intermediaire do
        attendu = [
                   '1 [26.65$]: Chianti Classico 2015, Volpaia',
                   '2 [26.65$]: Chianti Classico 2014, Volpaia',
                   '4 [16.50$]: Alsace 2016, Pfaff',
                   '5 [18.50$]: Cotes de Provence 2017, Roseline',
                  ]

        avec_fichier fichier, lignes do
          genere_sortie attendu do
            run_gv( "--depot=#{fichier} lister --court" )
          end
        end
      end
    end

    describe "utilisation de format" do
      let(:lignes) { IO.readlines("test_acceptation/4vins.txt" ) }

      it_ "produit l'appellation correctement", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ['Chianti Classico', 'Chianti Classico', 'Alsace', 'Cotes de Provence'], :strict do
            run_gv( 'lister --format="%A"' )
          end
        end

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ['Chianti Classico', 'ch ia nti   classico', 'alsace', 'cotes   de   provence'] do
            run_gv( 'lister --format="%A"' )
          end
        end
      end

      it_ "produit le nom correctement", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ['Volpaia', 'Volpaia', 'Pfaff', 'Roseline'], :strict do
            run_gv( 'lister --format="%N"' )
          end
        end
      end

      it_ "produit le commentaire correctement", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ["Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.", "Frais, leger."], :strict do
            run_gv( 'selectionner --bus', '-- lister --format="%c"' )
          end
        end
      end

      it_ "inclut les items de la chaine", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ['Note pour 1 => 4', 'Note pour 5 => 3'], :strict do
            run_gv( 'selectionner --bus', '-- lister --format="Note pour %I => %n"' )
          end
        end
      end

      it_ "ajoute un saut de ligne additionnel si un \n est indique", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ['1', '', '5', ''], :strict do
            run_gv( 'selectionner --bus', '-- lister --format="%I\n"' )
          end
        end
      end

      it_ "permet d'avoir plusieurs fois un meme item", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie ['Note pour 1 (1) => 4 (4)', 'Note pour 5 (5) => 3 (3)'], :strict do
            run_gv( 'selectionner --bus', '-- lister --format="Note pour %I (%I) => %n (%n)"' )
          end
        end
      end
    end
  end
end
