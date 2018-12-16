require 'test_helper'

describe "GestionVins" do
  [$DEPOT_DEFAUT, '.foo.txt'].each do |depot|
    niveau         = depot == $DEPOT_DEFAUT ? :base : :intermediaire
    argument_depot = depot == $DEPOT_DEFAUT ? ''    : "--depot=#{depot} "

    describe "init" do
      after  { FileUtils.rm_f depot }

      context "le depot #{depot} n'existe pas" do
        before { FileUtils.rm_f depot }

        it_ "cree le depot #{depot} si aucune option n'est specifiee", niveau do
          execute_sans_sortie_ou_erreur do
            run_gv( "#{argument_depot}init" )
          end
          assert File.zero? depot
        end

        it_ "cree le depot #{depot} si l'option --detruire est specifiee", niveau do
          execute_sans_sortie_ou_erreur do
            run_gv( "#{argument_depot}init --detruire" )
          end
          assert File.zero? depot
        end
      end

      context "le depot #{depot} existe" do
        before { FileUtils.touch depot }

        it_ "genere une erreur si l'option --detruire n'est pas specifiee pour le depot #{depot}", niveau do
          genere_erreur /fichier.*#{depot}.*existe.*--detruire/i do
            run_gv( "#{argument_depot}init" )
          end
          assert File.exist? depot
        end

        it_ "cree le depot #{depot} si l'option --detruire est specifiee", niveau do
          execute_sans_sortie_ou_erreur do
            run_gv( "#{argument_depot}init --detruire" )
          end
          assert File.zero? depot
        end
      end
    end
  end
end
