require 'test_helper'

describe "GestionVins" do
  describe "trier" do
    it_ "trie un fichier vide en ne produisant rien" do
      avec_fichier $DEPOT_DEFAUT do
        execute_sans_sortie_ou_erreur do
          run_gv( 'trier' )
        end
      end
    end

    context "fichier de vins avec plusieurs vins" do
      let(:lignes) { IO.readlines("test_acceptation/4vins.txt") }

      it_ "trie, par defaut, selon le numero" do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                   '5:03/07/18:rose:Cotes de Provence:2017:Roseline:18.50:3:Frais, leger.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'trier' )
          end
        end
      end

      it_ "trie en ordre inverse selon le numero si seul --reverse est specifie" do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                   '5:03/07/18:rose:Cotes de Provence:2017:Roseline:18.50:3:Frais, leger.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu.reverse, :strict do
            run_gv( 'trier --reverse' )
          end
        end
      end

      it_ "trie en ordre de millesime si seul --millesime est specifie" do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                   '5:03/07/18:rose:Cotes de Provence:2017:Roseline:18.50:3:Frais, leger.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'trier --millesime' )
          end
        end
      end

      it_ "genere une erreur si argument en trop", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /Argument.*en trop/i do
            run_gv( 'trier foo' )
          end
        end
      end

      it_ "trie selon le millesime pour la cle specifiee par l'item de format M", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '2 [26.65$]: Chianti Classico 2014, Volpaia',
                   '1 [26.65$]: Chianti Classico 2015, Volpaia',
                   '4 [16.50$]: Alsace 2016, Pfaff',
                   '5 [18.50$]: Cotes de Provence 2017, Roseline',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'trier --cle=M', '-- lister --court' )
          end
        end
      end

      it_ "trie selon le nom pour la cle specifiee par l'item de format N", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '4 [16.50$]: Alsace 2016, Pfaff',
                   '5 [18.50$]: Cotes de Provence 2017, Roseline',
                   '1 [26.65$]: Chianti Classico 2015, Volpaia',
                   '2 [26.65$]: Chianti Classico 2014, Volpaia',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'trier --cle=N', '-- lister --court' )
          end
        end
      end

      it_ "trie selon le commentaire pour la cle specifiee par l'item de format c", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '5 [18.50$]: Cotes de Provence 2017, Roseline',
                   '1 [26.65$]: Chianti Classico 2015, Volpaia',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'selectionner --bus', '-- trier --cle=c --reverse', '-- lister --court' )
          end
        end
      end

      it_ "trie en ne tenant pas compte de l'ordre des options", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'selectionner --non-bus', '-- trier --reverse --cle=M' )
          end
        end
      end
    end

    it_ "genere une erreur si depot inexistant", :intermediaire do
      FileUtils.rm_f $DEPOT_DEFAUT
      genere_erreur /fichier.*#{$DEPOT_DEFAUT}.*existe pas/i do
        run_gv( 'trier' )
      end
    end

    it_ "trie selon le prix puis le millesime en ordre normal", :avance do
      lignes = IO.readlines("test_acceptation/4vins.txt")

      attendu = [
                 '4 [16.50$]: Alsace 2016, Pfaff',
                 '5 [18.50$]: Cotes de Provence 2017, Roseline',
                 '2 [26.65$]: Chianti Classico 2014, Volpaia',
                 '1 [26.65$]: Chianti Classico 2015, Volpaia',
                ]

      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_sortie attendu do
          run_gv( 'trier --cle=PM', '-- lister --court' )
        end
      end
    end

    it_ "trie selon le prix puis le numero en ordre inverse", :avance do
      lignes = IO.readlines("test_acceptation/4vins.txt")

      attendu = [
                 '2 [26.65$]: Chianti Classico 2014, Volpaia',
                 '1 [26.65$]: Chianti Classico 2015, Volpaia',
                 '5 [18.50$]: Cotes de Provence 2017, Roseline',
                 '4 [16.50$]: Alsace 2016, Pfaff',
                ]

      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_sortie attendu do
          run_gv( 'trier --cle=PI --reverse', '-- lister --court' )
        end
      end
    end

    it_ "signale une erreur si un des caracteres pour les cles n'est pas correcte", :avance do
      lignes = IO.readlines("test_acceptation/4vins.txt")

      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_erreur /argument.*invalide/ do
          run_gv( 'trier --cle=PXI --reverse' )
        end
      end
    end

    describe "utilisation de stdin dans pipeline avec option -" do
      it_ "selectionne les vins non-bus, les trie selon le prix puis liste dans la forme courte", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                 '4 [16.50$]: Alsace 2016, Pfaff',
                 '2 [26.65$]: Chianti Classico 2014, Volpaia',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'selectionner --non-bus', '-- trier --prix', '-- lister --court' )
          end
        end
      end
    end
  end
end
