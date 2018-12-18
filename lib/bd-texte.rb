# Classe qui encapsule les details lies a une base de donnees
# textuelle.
#
# Ne definit que des methodes 'de classe', sans methodes d'instance
# -- donc on suppose qu'on aura toujours une seule utilisation
# active a un instant donne -- => pas d'execution concurrente.
#
# Composant completement independant des equipements, donc n'a pas ete mis
# dans le module GestionEquipements.
#

class BDTexte

  # Methode pour injection des dependances.
  #
  # C'est par l'intermediaire de cette methode que les attributs
  # pour la representation textuelle choisie sont specifies.
  #
  # @param [Symbol] format le format 'textuel' a utiliser
  # @param [Class] klass la classe qui represente les elements de la BD
  # @param [Exception] exception_a_signaler en cas de probleme
  # @param [String] separateur le separateur a utiliser si en format :csv
  #
  # @return [void]
  #
  # @require la classe klass repond au message "new_from_<<format>>"
  #          && les instances repondent au message "to_<<format>>"
  # @require separateur <=> format == :csv
  # @author: Guy Tremblay
  #
  def self.config( format,
                   klass,
                   exception_a_signaler: RuntimeError,
                   separateur: nil )
    DBC.require(klass.instance_methods.include?("to_#{format}".to_sym) &&
                klass.respond_to?("new_from_#{format}".to_sym),
                "#{self}.config: classe inappropriee: #{klass}: #{klass.methods + klass.instance_methods}" )
    DBC.require( separateur.nil? || format == :csv,
                 "#{self}.config: le separateur ne doit etre specifie que pour le format :csv" )
    DBC.require( separateur.nil? || separateur.size == 1,
                 "#{self}.config: le separateur doit etre un unique caractere: #{separateur}" )

    @klass = klass
    @format = format
    @exception = exception_a_signaler
    @separateur = separateur
  end

  # Initialise un depot de donnees.
  #
  # @param [String] depot nom du fichier pour le depot
  # @param [Bool] detruire si le fichier existe deja, on le detruit si detruire = true, sinon erreur
  #
  # @return [void]
  #
  # @ensure (le fichier n'existe pas || detruire) => le fichier existe et est vide
  #
  # @raise [::GestionEquipements::Exception] si le fichier existe sans qu'on specifie l'option --detruire
  #
  def self.init( depot, detruire: false )
    if File.exist? depot
      if detruire
        FileUtils.rm_f depot # On detruit le depot existant si --detruire est specifie.
      else
        fail @exception, "#{self}.init: le fichier '#{depot}' existe.
               Si vous voulez le detruire, utilisez 'init --detruire'."
      end
    end
    FileUtils.touch depot
    f = File.open(depot, 'w')
    f << "0:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:1:Pantalons de cuir:1:Bottes de cuir:1:Epee longue:1:Tete:Casque de cuir:1\n"
    f << "1:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:1:Pantalons de cuir:1:Bottes de cuir:1:Epee longue:1:Torse:Plastron de cuir:1\n"
    f << "2:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:2:Pantalons de cuir:5:Bottes de cuir:3:Epee longue:2:Mains:Gants de cuir:1\n"
    f << "3:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:3:Pantalons de cuir:6:Bottes de cuir:4:Epee longue:3:Pantalons:Pantalons de cuir:1\n"
    f << "4:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Bottes:Bottes de cuir:1\n"
    f << "5:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Tete:Casque de fer:5\n"
    f << "6:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Torse:Plastron de fer:5\n"
    f << "7:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Mains:Gant de fer:5\n"
    f << "8:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Pantalons:Pantalons de fer:5\n"
    f << "9:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Bottes:Bottes de fer:5\n"
    f << "10:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Tete:Casque legendaire:20\n"
    f << "11:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Torse:Plastron legendaire:20\n"
    f << "12:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Mains:Gants legendaires:20\n"
    f << "13:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Pantalons:Pantalons legendaires:20\n"
    f << "14:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Bottes:Bottes legendaires:20\n"
    f << "15:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Arme:Epee longue:1\n"
    f << "16:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Arme:Epee courte:5\n"
    f << "17:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Arme:Hache de fer:25\n"
    f << "18:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Arme:Dague en or:50\n"
    f << "19:100:10:10:Casque de cuir:1:Plastron de cuir:1:Gants de cuir:4:Pantalons de cuir:7:Bottes de cuir:6:Epee longue:5:Arme:Arc legendaire:100\n"
    f.close
  end

  # Obtient le contenu d'une base de donnees textuelle contenant une
  # collection d'elements.
  #
  # @param [String] depot nom du fichier
  #
  # @return [Array<klass>] la collection des elements lus
  #
  # @raise [::GestionEquipements::Exception] si le fichier n'existe pas
  # @author: Guy Tremblay
  #
  def self.charger( depot )
    fail @exception, "#{self}.charger: le fichier '#{depot}' n'existe pas!" unless depot == '-' || File.exist?(depot)

    new_from_format = "new_from_#{@format}".to_sym

    (depot == '-' ? STDIN.readlines : IO.readlines(depot))
      .map do |ligne|
      if @separateur
        @klass.send( new_from_format, ligne, @separateur )
      else
        @klass.send( new_from_format, ligne )
      end
    end
  end

  # Sauve sur disque, dans le depot indique, la collection de elements
  # specifiee.
  #
  # @param [String] depot nom du fichier ou effectuer la sauvegarde
  # @param [Array<#to_un_format>] les_elements a sauvegader dans la BD textuelle
  #
  # @return [void]
  #
  # @ensure Un fichier existe contenant la collection de elements et une
  #         copie de sauvegarde du fichier a ete faite.
  #
  # @author: Guy Tremblay
  #
  def self.sauver( depot, les_elements )
    FileUtils.cp depot, "#{depot}.bak" # Copie de sauvegarde.

    to_format = "to_#{@format}".to_sym
    arguments = @separateur ? [@separateur] : []

    File.open( depot, "w" ) do |fich|
      les_elements.each do |v|
        fich.puts v.send( to_format, *arguments )
      end
    end
  end
end
