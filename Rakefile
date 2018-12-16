#-*- ruby -*- # Pour etre en mode Ruby dans emacs

require 'rake/clean'
require 'rubygems'
require 'rake/testtask'

# Methodes auxilaires pour generer un nom de cible: cf. plus bas.
class Symbol
  def exemples; "#{self.to_s}_exemples".to_sym end
  def acceptation; "#{self.to_s}_test_acceptation".to_sym end
  def unitaire; "#{self.to_s}_test".to_sym end
end

# Pour lancer l'execution d'un exemple.
GV = "bundle exec bin/gv"

# Unite a executer ou a tester par defaut.
unit = :vin
commande = :lister

task :default => :"#{commande}".exemples

#task :default => :exemples
task :default => :all

# Les differentes classes et commandes pour lesquelles on a des tests:
# classes => tests unitaires, commandes => tests d'acceptation.

CLASSES   = [:vin, :motifs,:'bd-texte']
COMMANDES = [:init, :lister, :ajouter, :supprimer, :noter, :selectionner, :trier]


#############################################################################
# Divers exemples d'execution.
#############################################################################

task :exemples => COMMANDES.map { |cmd| "#{cmd}_exemples".to_sym }

def gv( cmd, lister_apres: nil )
  system "cp -f test_acceptation/4vins.txt .vins.txt"
  puts "*** #{GV} #{cmd} ***"
  system "#{GV} #{cmd}"
  puts
  system "#{GV} lister" if lister_apres
  puts
end

task :init_exemples do
  gv "init", lister_apres: true
  gv "init --detruire", lister_apres: true
end

task :lister_exemples do
  gv "lister"
  gv "lister --court"
  gv "lister --long"
  gv "lister --format='%I => %N (%A)'"
end

task :ajouter_exemples do
  gv "ajouter 'Chianti Classico' 2015 Fontodi 22.99", lister_apres: true
  gv "ajouter --type=rose --qte=2 'Tavel' 2017 'Domaine\ du\ vieil\ Aven' 20.99", lister_apres: true
end

task :supprimer_exemples do
  gv "supprimer 2", lister_apres: true
end

task :noter_exemples do
  gv "noter 2 4 'Tres bon!'", lister_apres: true
end

task :selectionner_exemples do
  gv "selectionner"
  gv "selectionner --bus"
  gv "selectionner --non-bus"
  gv "selectionner chianti"
  gv "selectionner '[s]{2}'"
end

task :trier_exemples do
  gv "trier"
  gv "trier --reverse"
  gv "trier --millesime"
  gv "trier --cle=M"
  gv "trier --cle=PN --reverse"
end

#############################################################################
# Methode auxiliaire pour definir les taches associes aux differentes
# commandes, tant unitaires que d'acceptation.
def test_task( commande, sorte )
    fail "Sorte de test invalide: #{sorte}" unless [:unitaire, :acceptation].include?(sorte)

    suffixe = sorte == :unitaire ? '' : '_acceptation'
    repertoire = "test#{suffixe}"
    nom_tache = "#{commande}_test#{suffixe}".to_sym

    desc "Tests #{sorte == :unitaire ? 'unitaires' : 'd\'acceptation'} #{nom_tache.to_s.sub(/_.*/, '')}"
    task nom_tache do
      sh "rake #{repertoire} TEST=#{repertoire}/#{commande}_test.rb"
    end
end

#############################################################################

#task :default => [:test,:test_acceptation]
#task :default => :'vin-texte'.unitaire
#task :default => :all
#task :default => :test

task :all => [:test, :test_acceptation]

# On definit des cibles distinctes pour les tests unitaires des
# classes et les tests d'acceptation des commandes.
CLASSES.each   { |cmd| test_task cmd, :unitaire }
COMMANDES.each { |cmd| test_task cmd, :acceptation }


#############################################################################

# Cible pour l'ensemble des tests unitaires.
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end

# Cible pour l'ensemble des tests d'acceptation.
Rake::TestTask.new(:test_acceptation) do |t|
  t.libs << "test_acceptation"
  t.test_files = FileList['test_acceptation/*_test.rb']
  t.warning = false
end

task :doc do
  sh 'yard --no-private --tag require:"Requires" --tag ensure:"Ensures" doc lib'
end

#############################################################################

