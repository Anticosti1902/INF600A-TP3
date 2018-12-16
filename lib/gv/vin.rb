module GestionVins
  require 'date'
  require 'json'

  #
  # Objet pour modeliser un vin.
  #
  # Tous les champs d'une instance sont immuables (non modifiables) *a
  # l'exception* des champs qui indiquent la note et le commentaire.
  #
  class Vin
    include Comparable

    READERS = [:numero, :date_achat, :type, :appellation, :millesime, :nom, :prix]
    ACCESSORS = [:note, :commentaire]

    # Attributs et methodes de classe.
    #
    # Une classe etant un objet, elle possede elle-meme des attributs
    # d'instance (!).  C'est ce qui est utilise ci-bas pour identifier
    # le plus grand numero de vin rencontre (pour assurer l'unicite) et
    # pour les methodes de comparaison de l'operateur <=> (i.e., les
    # champs a utiliser pour comparer deux vins).
    #

    @comparateurs = [:numero] # Comparateur par defaut: juste le numero.

    # Methodes de le classe Vin.
    class << self
      # @!attribute [r] comparateurs
      # @return [Array<Symbol>]
      attr_reader :comparateurs

      # @!attribute [rw] numero_max
      # @return [Integer]
      attr_accessor :numero_max

      # @!attribute [w] comparateurs
      def comparateurs=( cs )
        DBC.require( cs.all? { |c| (READERS + ACCESSORS).include?(c) },
                     "Comparateur(s) invalide(s): #{cs}" )

        @comparateurs = cs
      end
    end

    # Methodes pour acces (lecture) aux attributs (readers) d'une instance.
    # @private
    attr_reader(*READERS)


    # Methode de classe utilisee pour la construction, en cours
    # d'execution du script, de nouveaux objets. Ces objets seront
    # ulterieurement ajoutes a la BD lors de la fin de l'execution du
    # script.
    #
    # @param [Symbol] type
    # @param [String] appellation
    # @param [Integer] millesime
    # @param [String] nom
    # @param [Float] prix
    #
    # @return [Vin]
    #
    def self.creer( type, appellation, millesime, nom, prix )
      # On definit les attributs generes.
      numero = Vin.numero_max.nil? ? 0 : Vin.numero_max + 1
      date_achat = Time.now.to_date

      # On cree la nouvelle instance -- avec les bons types.
      new( numero, date_achat, type.to_sym, appellation, millesime.to_i, nom, prix.to_f )
    end

    # Methode d'initialisation d'un vin.
    #
    # Les arguments doivent tous etre du type approprie, i.e., les
    # conversions doivent avoir ete faites au prealable.
    #
    def initialize( numero, date_achat,
                    type, appellation, millesime, nom, prix,
                    note = nil, commentaire = nil )
      DBC.require( numero.kind_of?(Integer) && numero >= 0,
                   "Numero de vin incorrect -- doit etre un Integer non-negatif: #{numero}!?" )
      DBC.require( date_achat.kind_of?(Date),
                   "Date d\'achat incorrecte -- doit etre une Date: #{date_achat} (#{date_achat.class})!?" )
      DBC.require( type.kind_of?(Symbol),
                   "Type de vin incorrect -- doit etre un Symbol: #{type} (#{type.class})!?" )
      DBC.require( millesime.kind_of?(Integer) && millesime >= 0,
                   "Millesime de vin incorrect -- doit etre un Integer non-negatif: #{millesime}!?" )
      DBC.require( prix.kind_of?(Float) && prix >= 0.00,
                   "Prix de vin incorrect -- doit etre un Float non-negatif: #{prix}!?" )

      (READERS + ACCESSORS).each do |var|
        instance_variable_set "@#{var}", (binding.local_variable_get var)
      end
      Vin.numero_max = Vin.numero_max ? [Vin.numero_max, numero].max : numero
    end

    # Est-ce que le vin a ete bu?
    #
    def bu?
      !@note.nil?
    end

    alias_method :note?, :bu?

    # Retourne la note d'un vin ayant ete bu.
    #
    # @return [Integer]
    #
    # @require bu?
    #
    def note
      DBC.require( bu?, "Vin non bu: La note n'est pas definie" )

      @note
    end

    # Retourne le commentaire d'un vin ayant ete bu.
    #
    # @return [String]
    #
    # @require bu?
    #
    def commentaire
      DBC.require( bu?, "Vin non bu: Le commentaire n'est pas defini" )

      @commentaire
    end

    # Ajoute une note et un commentaire a un vin n'ayant pas encore ete
    # bu.
    #
    # @param [Integer] note
    # @param [String] commentaire
    #
    # @return [void]
    #
    # @require le vin n'a pas ete bu et la note est valide.
    #
    # @ensure bu? && self.commentaire == commentaire
    #
    def noter( note, commentaire )
      fail "*** Dans noter( #{note}, #{commentaire} ): Vin #{numero} deja note" if note?
      fail "*** Dans noter( #{note}, #{commentaire} ): Nombre invalide pour note: #{note}" if note < Motifs::NOTE_MIN || note > Motifs::NOTE_MAX

      @note = note
      @commentaire = commentaire
    end

    #
    # Formate un vin selon les indications specifiees par le_format.
    #
    # @param [String] le_format tel que decrit plus bas
    #
    # @return [String]
    #
    # Les items de specification de format sont les memes que dans le
    # devoir 1:
    #   I => numero
    #   D => date_achat
    #   T => type
    #   A => appellation
    #   M => millesime
    #   N => nom
    #   P => prix
    #   n => note
    #   c => commentaire
    #
    # Des indications de largeur, justification, etc. peuvent aussi etre
    # specifiees, par exemple, %-10T, %-.10T, etc.
    #
    # NOTE: Pour la date d'achat, voici comment convertir une Date dans
    # le format approprie: date_achat.strftime("%d/%m/%y"),
    #
    def to_s( le_format = nil )
      le_format ||= '%I [%T - %.2P$]: %A %M, %N (%D) => %n {%c}' # Format long.
      vrai_format, arguments = generer_format_et_args( le_format )

      format( vrai_format, *arguments )
    end


    #
    # Ordonne les vins selon les comparateurs (champs) specifies dans
    # Vin.comparateurs.
    #
    # @param [Vin] autre
    #
    # @return [Integer] ou [-1, 0, 1].include? result
    #
    def <=>( autre )
      Vin.comparateurs.reduce(0) do |r, champ|
        r.nonzero? ? r : send(champ) <=> autre.send(champ)
      end
    end

    #################################################################################
    # Methodes pour conversion vers/de format textuel --- :csv, :json
    #################################################################################

    #
    # Produit la representation CSV d'un vin.
    #
    # @param [String] separateur le caractere a utiliser comme separateur
    #
    # @return [String] les divers champs du vins concatenes mais avec separateur entre eux
    #
    # @require separateur.size == 1
    #
    def to_csv( separateur = ':' )
      DBC.require( separateur.size == 1, "#{self}.to_csv: separateur invalide: #{separateur}" )

      [numero.to_s,
       date_achat.strftime("%d/%m/%y"),
       type.to_s,
       appellation,
       millesime.to_s,
       nom,
       sprintf( "%.2f", prix ),
       note? ? note.to_s : '',
       note? ? commentaire : ''
      ].join(separateur)
    end

    #
    # Construit un objet Vin a partir de sa representation textuelle en format csv
    #
    # @param [String] ligne contenant les champs du vins en format CSV
    # @param [String] separateur
    # @return [Vin]
    #
    def self.new_from_csv( ligne, separateur = ':' )
      DBC.require( separateur.size == 1, "#{self}.new_from_csv: separateur invalide: #{separateur}" )

      num_vin, date_achat, type, appellation, millesime, nom, prix, note, commentaire =
        ligne.chomp.split(separateur, 9)

      j, m, a = date_achat.split("/")

      # Un appel a new doit recevoir les divers champs avec les types appropries.
      new( num_vin.to_i,
           Date.new( 2000 + a.to_i, m.to_i, j.to_i ),
           type.to_sym,
           appellation,
           millesime.to_i,
           nom,
           prix.to_f,
           note.empty? ? nil : note.to_i,
           commentaire.empty? ? nil : commentaire )
    end

    #
    # Produit la representation JSON d'un vin.
    #
    # @return [String]
    #
    def to_json
      (READERS + ACCESSORS)
        .map { |c|  [c, instance_variable_get("@#{c}")] }
        .to_h
        .to_json
    end

    #
    # Construit un objet Vin a partir de sa representation JSON.
    #
    # @param [String] json_hash une chaine representant le hash JSON pour un vin
    # @return [Vin]
    #
    def self.new_from_json( json_hash )
      hash = JSON.parse( json_hash )

      # On "corrige" le type de certains des champs.
      a, m, j = hash["date_achat"].split("-").map(&:to_i)
      hash["date_achat"] = Date.new( a.to_i, m.to_i, j.to_i )
      hash["type"] = hash["type"].to_sym

      new( *(READERS + ACCESSORS).map(&:to_s).map { |k| hash[k] } )
    end


    private

    #
    # Genere le format "standard" avec les arguments requis pour le
    # format special indique.
    #
    def generer_format_et_args( le_format )
      format_a_traiter = le_format.dup
      le_format_final = ''

      # Les formats et valeurs a utiliser pour chacun des caracteres de format.
      format_et_valeur = vrai_format_et_valeur
      indicateurs = format_et_valeur.keys.join

      # On genere le format standard et on accumule les arguments requis.
      motif = /^(?<prefixe>[^%]*)              # La partie avant %
               %                               # Le %
               (?<largeur>[-]?\d*[.]?\d*)      # La specif. de largeur
               (?<car_champ>[#{indicateurs}])  # Un car. qui indique un champ
              /x

      les_args = []
      while m = motif.match(format_a_traiter) do
        # On a trouve une specification de champ valide: on obtient la
        # (vraie) specification de format et la valeur associees.
        car_vrai_format, val = format_et_valeur[m[:car_champ]]
        le_format_final << m[:prefixe] << '%' << m[:largeur] << car_vrai_format
        les_args << val

        format_a_traiter = m.post_match
      end

      # On ajoute la partie finale sans indicateur.
      le_format_final << format_a_traiter

      # On retourne les resultats, mais en arrangeant les \\n dans le format.
      [le_format_final.gsub(/\\n/, "\n"), les_args]
    end

    def vrai_format_et_valeur
      {
        'I' => ['d', numero],
        'D' => ['s', date_achat.strftime("%d/%m/%y")],
        'T' => ['s', type],
        'A' => ['s', appellation],
        'M' => ['d', millesime],
        'N' => ['s', nom],
        'P' => ['f', prix],
        'n' => (note? ? ['d', note] : ['s', '']),
        'c' => ['s', note? ? commentaire : ''],
      }
    end
  end
end
