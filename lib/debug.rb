# -*- coding: utf-8 -*-
#
# Classe simple pour un log de déboggage.
#
class Debug

  FICH_DEBUG = 'debug-log.txt'

  # Ajoute le message dans le log, SI la variable d'environnement DEBUG est true/TRUE.
  #
  # Plus spécifiquement, le message va dans le fichier #{FICH_DEBUG},
  # à moins que la variable d'environnement FICH_DEBUG ne soit définie.
  #
  def self.log( msg )
    if  ENV['DEBUG'] =~ /^(true|TRUE)/
      fich = ENV['FICH_DEBUG'] || FICH_DEBUG
      File.open( fich, File::WRONLY | File::APPEND | File::CREAT ) do |f|
        f.puts( msg )
      end
    end
  end

end

