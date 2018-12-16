gem 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'
require 'open3'

#########################################################
# Methodes auxiliaires de tests.
#########################################################

$DEPOT_DEFAUT = ".vins.txt"

#
# Extensions de la classe Object pour definir des methodes auxiliaires
# de test.
#
class Object
  # Pour desactiver temporairement une suite de tests.
  def _describe( test )
    puts "--- On saute les tests pour \"#{test}\" ---"
  end

  # Pour desactiver temporairement un test.
  def _it_( test, niveau = :base )
    puts "--- On saute le test \"#{test}\" ---"
  end

  # Des alias pour style RSpec
  alias_method :context, :describe
  alias_method :_context, :_describe


  # Une methode de test auxiliaire pour tenir compte du niveau de test
  # en cours.
  def it_( test, niveau = :base, &bloc )
    if niveau_a_tester = ENV['NIVEAU']  #!!
      return unless [niveau, :tous, :all].include?( niveau_a_tester.to_sym )
    end

    it( test, &bloc )
  end
end

#########################################################
# Methodes auxiliaires specifiques pour les tests du devoir 1.
#########################################################

#
# Cree un fichier temporaire avec le contenu indique.  Execute ensuite
# le bloc recu, puis supprime le fichier temporaire.
#
# @param [String] nom_fichier
# @param [Array<String>] contenu lignes contenues dans le fichier
# @return [void]
# @yield [void]
#
def avec_fichier( nom_fichier, lignes = [], conserver = nil )
  # On cree le fichier.
  File.open( nom_fichier, "w" ) do |fich|
    lignes.each do |ligne|
      fich.puts  ligne
    end
  end

  # On execute le bloc.
  yield

  # On supprime le fichier sauf si indique autrement, auquel cas on
  # retourne son contenu.
  if conserver
    contenu_fichier( nom_fichier )
  else
    FileUtils.rm_f nom_fichier
  end
end

#
# Execute le script ./gv.rb avec les commande, options et arguments
# indiques puis retourne les lignes emises sur stdout et stderr suite
# a l'execution de cette commande, ainsi que le code de statut.
#
# @param [<String>] cmds Les commandes a executer avec leurs options et arguments  (sans './gv.rb')
# @return [Array[Array<String>, Array<String>, Fixnum] Les lignes produites sur stdout, stderr et le code de statut
#
def run_gv( *cmds )
  cmd_line = cmds
    .map{ |cmd| "bundle exec bin/gv #{cmd}" }
    .join( ' | ' )


  stdout = stderr = wt = nil
  Open3.popen3( "#{cmd_line}" ) do |i, o, e, w|
    i.close
    stdout = o.readlines.map!(&:chomp!)
    stderr = e.readlines.map!(&:chomp!)
    wt = w
  end

  [stdout, stderr, wt.value.exitstatus]
end

#
# Retourne le contenu d'un fichier sous forme d'une liste de lignes,
# sans les sauts de lignes.
p#
# @param [String] nom_fichier
# @return [Array<String>] ou les "\n" finaux ont ete supprimes
#
def contenu_fichier( nom_fichier )
  IO.readlines(nom_fichier).map(&:chomp)
end

#
# Methodes avec assertions plus complexes, pour simplifier les tests.
#

# Execute une commande specifiee par le bloc, qui doit *matcher* l'erreur indiquee.
def genere_erreur( erreur )
  out, err, statut = yield

  assert_empty out, "*** Assertion echouee: stdout devrait etre vide mais contient des elements ***"
  assert_match erreur, err.join, "*** Assertion echouee: Le message d'erreur ne semble pas etre celui attendu ***"
  refute_equal 0, statut, "*** Assertion echouee: le 'exit status' est 0 mais devrait etre different de 0 ***"
end

# Execute une commande specifiee par le bloc, qui ne doit generer ni sortie, ni erreur
def execute_sans_sortie_ou_erreur
  out, err, statut = yield
  assert_empty out, "*** Assertion echouee: stdout devrait etre vide mais contient des elements ***"
  assert_empty err, "*** Assertion echouee: stderr devrait etre vide mais contient des elements ***"
  assert_equal 0, statut, "*** Assertion echouee: le 'exit status' est different de 0 alors qu'il devrait 0 ***"
end

# Execute une commande specifiee par le bloc, qui doit generer la sortie attendu.
# Si un 2e argument est specifie, alors la comparaison se fait de facon stricte.
# Sinon, les blancs et la casse sont ignores.
def genere_sortie( attendu, strict = nil  )
  out, err, statut = yield

  if strict
    assert_equal attendu, out, "*** Assertion echouee: La sortie emise sur stdout n'est pas *exactement* celle attendue (:strict => casse et blancs significatifs) ***"
  else
    obtenu = out.map { |l| l.gsub(/\s+/, "").downcase }
    attendu = attendu.map { |l| l.gsub(/\s+/, "").downcase }
    assert_equal attendu, obtenu, "*** Assertion echouee: La sortie emise sur stdout n'est pas celle attendue (meme en ignorant la casse et les blancs) ***"
  end
  assert_empty err, "*** Assertion echouee: stderr devrait etre vide mais contient des elements ***"
  assert_equal 0, statut, "*** Assertion echouee: le 'exit status' est different de 0 alors qu'il devrait 0 ***"
end

# Execute une commande specifiee par le bloc, qui doit generer une sortie bien precise.
def genere_sortie_et_erreur( attendu, erreur, strict = nil )
  out, err, statut = yield

  if strict
    assert_equal attendu, out, "*** Assertion echouee: La sortie emise sur stdout n'est pas *exactement* celle attendue (:strict => casse et blancs significatifs) ***"
  else
    obtenu = out.map { |l| l.gsub(/\s+/, "").downcase }
    attendu = attendu.map { |l| l.gsub(/\s+/, "").downcase }
    assert_equal attendu, obtenu, "*** Assertion echouee: La sortie emise sur stdout n'est pas celle attendue (meme en ignorant la casse et les blancs) ***"
  end
  assert_match erreur, err.join, "*** Assertion echouee: Le message d'erreur ne semble pas etre celui attendu ***"
  refute_equal 0, statut, "*** Assertion echouee: le 'exit status' est 0 mais devrait etre different de 0 ***"
end
