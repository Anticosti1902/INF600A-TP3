module GestionEquipements

  # Objet singleton (on dit aussi une 'machine') qui encapsule
  # l'entrepot de donnees pour les vins. Ne definit donc que des
  # methodes 'de classe', sans methode d'instances, puisqu'on aura
  # toujours un seul entrepot actif a un instant donne -- pas
  # d'execution concurrente.
  #
  # Plus specifiquement, cet objet sert de "repository" (traduit par
  # 'entrepot') au sens defini par l'approche DDD d'Eric Evans:
  # 'Domain-Driven Design---Tackling Complexity in the Heart of
  # Software', Addison-Wesley, 2004.
  #
  class EntrepotEquipements

    # Initialise l'entrepot, i.e., charge en memoire la collection de
    # vins specifiee par le depot, et ce a l'aide de la bd indiquee.
    #
    # @param [String] depot le nom de la base de donnees
    # @param [<#charger, #sauver>] bd la base de donnees a utiliser
    #
    # @return [void]
    #
    # @ensure les_vins contient les vins du fichier
    #
    def self.ouvrir( depot, bd )
      @depot = depot
      @bd = bd
      @les_equipements = @bd.charger( depot )
    end

    # Ferme l'entrepot, ce qui a pour effet de le sauvegarder dans le
    # fichier associe.
    #
    # @return [void]
    #
    # @require Un appel prealable a ouvrir a ete effectue
    # @ensure Les vins ont ete sauvegardes dans le depot
    #
    def self.fermer
      DBC.require( @depot && @bd, "Aucun appel prealable a ouvrir ne semble avoir ete effectue" )

      @bd.sauver( @depot, @les_equipements )
    end

    def self.jouer
      goblin_vie = 50
      goblin_attaque = calculer_attaque_max() * 0.5
      goblin_defense = calculer_defense_max() * 0.1
      goblin_choix = :attaquer

      heros = l_equipement(0)
      heros_vie = heros.vie
      heros_choix = :attaquer
      tour = 1

      goblin_vrai_attaque = goblin_attaque - heros.defense >= 5 ? goblin_attaque - heros.defense : 5
      heros_vrai_attaque = heros.attaque - goblin_defense >= 5 ? heros.attaque - goblin_defense : 5

      puts("Un goblin approche!\n")
      puts("Vie: #{goblin_vie}\n")
      puts("Attaque: #{goblin_attaque.to_i}\n")
      puts("Defense: #{goblin_defense.to_i}\n")
      while heros_vie > 0 && goblin_vie > 0 do
        puts("----------------------------------------------------------Tour #{tour}-----------------------------------------------------------")
        tour = tour + 1
        if(goblin_choix == :attaquer && heros_choix == :attaquer) then
          heros_vie = heros_vie.to_i - goblin_vrai_attaque.to_i
          goblin_vie = goblin_vie.to_i - heros_vrai_attaque.to_i
          puts("Le goblin attaque et effectue #{goblin_vrai_attaque.to_i} de dommage au heros. Vie restante au heros: #{heros_vie.to_i}")
          puts("Le heros attaque et effectue #{heros_vrai_attaque.to_i} de dommage au goblin. Vie restante au goblin: #{goblin_vie.to_i}")
        end
        if(goblin_choix == :attaquer && heros_choix == :defendre) then
          heros_vie = heros_vie.to_i - goblin_vrai_attaque.to_i / 2
          puts("Le goblin attaque, mais le valeureux heros se defend, ne subissant que #{goblin_vrai_attaque.to_i / 2} de dommages. Vie restante au heros: #{heros_vie.to_i}")
        end
        if(goblin_choix == :defendre && heros_choix == :attaquer) then
          goblin_vie = goblin_vie.to_i - heros_vrai_attaque.to_i / 2
          puts("Le heros attaque, mais le goblin voit venir le coup et ne subit que #{heros_vrai_attaque.to_i / 2} de dommages. Vie restante au goblin: #{goblin_vie.to_i}")
        end
        if(goblin_choix == :defendre && heros_choix == :defendre) then
          puts("Les deux ennemis se regardent et s'etudient, mais personne n'ose bouger")
        end
        puts("")
        goblin_choix = action()
        heros_choix = action()
      end
    end

    def self.action()
        action = rand(1..2) == 1 ? :attaquer : :defendre
    end

    #nom + puissance
    def self.remplacer_equipement_specifique( numero )
      equipement = l_equipement(numero)
      nouvel_equip = equiper(equipement)

      @les_equipements.map{ |equipement|
        equipement.tete = nouvel_equip.tete
        equipement.tetedefense = nouvel_equip.tetedefense
        equipement.torse = nouvel_equip.torse
        equipement.torsedefense = nouvel_equip.torsedefense
        equipement.mains = nouvel_equip.mains
        equipement.mainsdefense = nouvel_equip.mainsdefense
        equipement.pantalons = nouvel_equip.pantalons
        equipement.pantalonsdefense = nouvel_equip.pantalonsdefense
        equipement.bottes = nouvel_equip.bottes
        equipement.bottesdefense = nouvel_equip.bottesdefense
        equipement.arme = nouvel_equip.arme
        equipement.armeattaque = nouvel_equip.armeattaque
       }
    end

    def self.remplacer_tous_equipements()
      max_tete = @les_equipements.select{|equipment| equipment.type == :Tete}.reduce{|prev, current| prev.puissance > current.puissance  ? prev : current}
      max_plaston = @les_equipements.select{|equipment| equipment.type == :Plastron}.reduce{|prev, current| prev.puissance > current.puissance  ? prev : current}
      max_mains = @les_equipements.select{|equipment| equipment.type == :Mains}.reduce{|prev, current| prev.puissance > current.puissance  ? prev : current}
      max_pantalons = @les_equipements.select{|equipment| equipment.type == :Pantalons}.reduce{|prev, current| prev.puissance > current.puissance  ? prev : current}
      max_bottes = @les_equipements.select{|equipment| equipment.type == :Bottes}.reduce{|prev, current| prev.puissance > current.puissance  ? prev : current}
      max_arme = @les_equipements.select{|equipment| equipment.type == :Arme}.reduce{|prev, current| prev.puissance > current.puissance  ? prev : current}
      remplacer_equipement_specifique(max_tete.numero) unless max_tete.nil?
      remplacer_equipement_specifique(max_plaston.numero) unless max_plaston.nil?
      remplacer_equipement_specifique(max_mains.numero) unless max_mains.nil?
      remplacer_equipement_specifique(max_pantalons.numero) unless max_pantalons.nil?
      remplacer_equipement_specifique(max_bottes.numero) unless max_bottes.nil?
      remplacer_equipement_specifique(max_arme.numero) unless max_arme.nil?
    end

    def self.equiper(equipement)
      numero = equipement.numero
      puissance = equipement.puissance
      type = equipement.type.to_s.downcase
      nom = equipement.nom

      if type == "arme"
        equipement.send("#{type}=",  nom)
        equipement.send("#{type}attaque=",  puissance)
      else
        equipement.send("#{type}=",  nom)
        equipement.send("#{type}defense=",  puissance)
      end
      return equipement
    end

    # Message à afficher contenant les informations du héros
    #
    # @return [String]
    #
    def self.creer_status()
      attaque_max = calculer_attaque_max()
      defense_max = calculer_defense_max()
      attaque_equip = attaque_max - 10
      defense_equip = defense_max - 10
      status = "----------Informations générales---------\n"
      status << "Héros: Olaf Odinkarsson\n"
      status << "Vie max: %V\n"
      status << "Attaque: #{attaque_max} (Base: 10 - Arme: #{attaque_equip})\n"
      status << "Défense: #{defense_max} (Base: 10 - Armure: #{defense_equip})\n"
      status << "----------Équipements utilisés----------\n"
      status << "Tête      : %-20H (%1 défense)\n"
      status << "Torse     : %-20T (%2 défense)\n"
      status << "Mains     : %-20M (%3 défense)\n"
      status << "Pantalons : %-20P (%4 défense)\n"
      status << "Bottes    : %-20B (%5 défense)\n"
      status << "Arme      : %-20W (%6 attaque)"
    end

    # Calcule l'attaque totale du personnage
    #
    # @return [Integer]
    #
    # @raise [::GestionEquipements::Exception] si le fichier d'entree est vide
    #
    def self.calculer_attaque_max()
      joueur = GV::EntrepotEquipements.l_equipement(0)
      fail ::GestionEquipements::Exception, "#{self}.calculer_attaque_max: le fichier d'entree est vide" unless joueur
      attaque = joueur.armeattaque >=1 ? joueur.attaque + joueur.armeattaque : joueur.attaque
    end

    # Calcule l'armure totale du personnage
    #
    # @return [Integer]
    #
    # @raise [::GestionEquipements::Exception] si le fichier d'entree est vide
    #
    def self.calculer_defense_max()
      joueur = GV::EntrepotEquipements.l_equipement(0)
      fail ::GestionEquipements::Exception, "#{self}.calculer_attaque_max: le fichier d'entree est vide" unless joueur
      defense = joueur.defense + joueur.tetedefense + joueur.torsedefense + joueur.mainsdefense + joueur.pantalonsdefense + joueur.bottesdefense
    end

    # Supprime un vin de la collection de vins.
    #
    # @param [Vin] vin le vin a supprimer
    # @param [Integer] numero le numero du vin a supprimer
    #
    # @return [void]
    #
    # @require Exactement un parmi vin: ou numero: est specifie, pas les deux
    #
    # @ensure Le vin specifie n'est plus present dans le depot
    #
    # @raise [::GestionEquipements::Exception] si le vin indique n'existe pas
    #
    def self.supprimer( vin: nil, numero: nil )
      DBC.require( vin || numero && vin.nil? || numero.nil?,
                   "#{self}.supprimer: il faut indiquer un (1) argument" )

      if numero
        vin = GV::EntrepotEquipements.l_equipement(numero)

        fail ::GestionEquipements::Exception, "#{self}.supprimer: le vin numero #{numero} n'existe pas" unless vin
      end

      fail ::GestionEquipements::Exception, "#{self}.supprimer: le vin numero #{numero} est deja note" if vin.note?

      supprime = @les_equipements.delete(vin)

      DBC.assert supprime, "#{self}.supprimer: le vin #{vin} n'existait pas dans #{self}"
    end

    # Note un vin de la collection de vins.
    #
    # @param [Integer] numero
    # @param [Integer] note
    # @param [String] commentaire
    #
    # @return [Vin] le vin avec sa nouvelle note et son commentaire
    #
    # @ensure Le vin est maintenant note avec le commentaire indique
    #
    # @raise [::GestionEquipements::Exception] si le vin indique n'existe pas ou s'il est deja note
    #
    def self.noter( numero, note, commentaire )
      vin = GV::EntrepotEquipements.l_equipement(numero)

      fail ::GestionEquipements::Exception, "#{self}.noter: le vin numero #{numero} n'existe pas" unless vin
      fail ::GestionEquipements::Exception, "#{self}.noter: le vin numero #{numero} est deja note: #{vin.note} - #{vin.commentaire}" if vin.note?

      vin.noter(note, commentaire)
    end

    # Trie les vins de la collection de vins.
    #
    # @param [Array<Symbol>] cles les champs a utiliser pour le tri
    # @param [Bool] reverse en ordre renverse (true) ou normal (false)
    #
    # @return [Array<Vin>] la liste des vins tries selon les criteres specifies
    #
    def self.trier( cles, reverse )
      GV::Vin.comparateurs = cles.include?(:numero) ? cles : (cles << :numero)

      @les_equipements
        .sort { |v1, v2| (reverse ? -1 : 1) * (v1 <=> v2) }
    end


    # Selectionne les vins de la collection qui satisfont divers
    # criteres.
    #
    # @param [Regexp] motif un motif qui doit apparaitre
    #                 dans la representation textuelle (to_s) du vin
    #
    # @yieldparam [Vin] vin le vin qui est analyse par le bloc
    # @yieldreturn [Bool] si le vin satisfait ou pas le critere specifie par le bloc
    #
    # @return [Array<Vin>] la liste des vins qui satisfont les
    #        criteres specifies. Si bus et non_bus sont true , alors tous les vins
    #
    def self.les_vins( motif: nil )
      @les_equipements
        .select do |v|
            # Selon le motif.
            (motif.nil? || /#{motif}/i =~ v.to_s) &&
            # Puis en fonction du bloc, si present.
            (block_given? ? yield(v) : v)
      end
    end


    # Retourne le vin avec le numero indique.
    #
    # @param [Integer] numero
    #
    # @return [Vin] le vin avec le numero indique
    #
    def self.l_equipement( numero )
      @les_equipements.find { |v| v.numero == numero }
    end

  end
end
