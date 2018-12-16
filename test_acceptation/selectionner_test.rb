require 'test_helper'

describe "GestionVins" do
  describe "selectionner" do
    it_ "selectionne un fichier vide en ne produisant rien" do
      avec_fichier $DEPOT_DEFAUT do
        execute_sans_sortie_ou_erreur do
          run_gv( 'selectionner' )
        end
      end
    end

    context "cave avec plusieurs vins" do
      let(:lignes) { IO.readlines("test_acceptation/4vins.txt") }

      it_ "produit tous les vins si aucune option ou motif n'est specifie" do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                   '5:03/07/18:rose:Cotes de Provence:2017:Roseline:18.50:3:Frais, leger.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner' )
          end
        end
      end

      it_ "produit les vins bus si seule l'option --bus est specifie" do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '5:03/07/18:rose:Cotes de Provence:2017:Roseline:18.50:3:Frais, leger.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'selectionner --bus' )
          end
        end
      end

      it_ "produit tous les vins si aucune option ou motif n'est specifie" do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                   '5:03/07/18:rose:Cotes de Provence:2017:Roseline:18.50:3:Frais, leger.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner' )
          end
        end
      end

      it_ "genere une erreur si argument en trop", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /Argument.*en trop/i do
            run_gv( 'selectionner Chianti foo' )
          end
        end
      end
    end

    it_ "genere une erreur si depot inexistant", :intermediaire do
      FileUtils.rm_f $DEPOT_DEFAUT
      genere_erreur /fichier.*#{$DEPOT_DEFAUT}.*existe pas/i do
        run_gv( 'selectionner' )
      end
    end

    it_ "selectionne les vins qui satisfont un motif specifie par une chaine simple", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner rouge' )
          end
        end
    end

    it_ "selectionne les vins qui satisfont un motif specifie par une expression reguliere simple", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner "rou.*"' )
          end
        end
    end

    it_ "selectionne les vins non-bus qui satisfont un motif specifie par une expression reguliere simple", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner --non-bus "rou.*"' )
          end
        end
    end

    it_ "selectionne les vins qui satisfont un motif specifie par une expression reguliere plus complexe", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                   '2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::',
                   '4:03/07/18:blanc:Alsace:2016:Pfaff:16.50::',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner "rou.+e|blanc"' )
          end
      end
    end

    it_ "selectionne les vins bus qui satisfont un motif specifie par une expression reguliere complexe", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1:10/06/18:rouge:Chianti Classico:2015:Volpaia:26.65:4:Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu, :strict do
            run_gv( 'selectionner --bus "char.*|blanc"' )
          end
        end
    end

    describe "utilisation de stdin dans pipeline avec option -" do
      it_ "selectionne les vins bus puis liste tous les vins bus, dans la forme longue", :intermediaire do
        lignes = IO.readlines("test_acceptation/4vins.txt")

        attendu = [
                   '1 [rouge - 26.65$]: Chianti Classico 2015, Volpaia (10/06/18) => 4 {Fonce, dense, opaque. Aromes fruits noirs. Tannins charnus.}',
                   '5 [rose  - 18.50$]: Cotes de Provence 2017, Roseline (03/07/18) => 3 {Frais, leger.}',
                  ]

        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_sortie attendu do
            run_gv( 'selectionner --bus',  '-- lister' )
          end
        end
      end
    end
  end
end
