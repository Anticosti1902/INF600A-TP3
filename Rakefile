#-*- ruby -*- # Pour etre en mode Ruby dans emacs

require 'rake/clean'
require 'rubygems'
require 'rake/testtask'

# Methodes auxilaires pour generer un nom de cible: cf. plus bas.
class Symbol
  def exemples; "#{self.to_s}_exemples".to_sym end
end

# Pour lancer l'execution d'un exemple.
GV = "bundle exec bin/gv"

COMMANDES = [:init, :lister, :equiper, :trier, :jouer]


#############################################################################
# Divers exemples d'execution.
#############################################################################

task :exemples => COMMANDES.map { |cmd| "#{cmd}_exemples".to_sym }

def gv( cmd, lister_apres: nil )
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
  gv "lister --status"
  gv "lister --inventaire"
  gv "lister --format='%N (%L) - puissance: %O'"
end

task :equiper_exemples do
  gv "equiper", lister_apres: true
  gv "equiper --numero=4", lister_apres: true
  gv "equiper --meilleur", lister_apres: true
end

task :trier_exemples do
  gv "trier"
  gv "trier --reverse"
  gv "trier --type"
  gv "trier --cle=I"
  gv "trier --cle=L --reverse"
end

task :jouer_exemples do
  gv "jouer"
end
