module GestionVins

  # Motifs representant les divers attributs pour un vin.
  #
  # Utilises lors de la lecture d'une specification de vin (via la ligne
  # de commande ou via stdin) pour assurer que les champs sont du bon
  # format.
  #
  # Pour les champs nom, appellation et commentaire, on suppose que
  # n'importe quels caracteres peuvent etre utilises, a l'exception du
  # separateur.  C'est donc ce qui est formalise dans les motifs
  # indiques (CHAINE).
  #
  # Rappel: les trois facons suivantes permettent de definir un meme
  # objet Regexp:
  #
  #   /.../
  #   %r{...}
  #   Regepx.new("...")

  module Motifs
    NUM_VIN = %r{[0-9][0-9]*}

    DATE = %r{(0[1-9]|[12][0-9]|3[01])  # JOUR
            /
            (0[1-9]|1[0-2])           # MOIS
            /
            [0-9]{2}                  # ANNEE
           }x

    CHAINE = %r{"(?:[^"]+)"|'(?:[^']+)'|(?:[^\s]+)}

    APPELLATION = CHAINE
    NOM = CHAINE
    COMMENTAIRE = CHAINE

    MILLESIME = %r{[0-9]{4}}
    PRIX = %r{[0-9]+[.][0-9]{2}}

    NOTE_MIN=0
    NOTE_MAX=5
    NOTE = %r{[#{NOTE_MIN}-#{NOTE_MAX}]}
  end

end
