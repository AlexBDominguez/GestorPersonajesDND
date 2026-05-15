#!/usr/bin/env python3
"""
i18n Phase 2 — Canonical spell translations + class/race/subclass/trait descriptions.
Generates i18n_phase2.sql and executes it against the Docker MySQL container.
Run with: python3 i18n_phase2_gen.py
"""
import subprocess, sys

DB_CMD = [
    "docker", "compose", "exec", "-T", "mysql-db",
    "mysql", "-uroot", "-pdnd_root_password", "dnd_character_manager",
    "--default-character-set=utf8mb4",
]
CWD = "/home/alexandre.barbeito/GestorPersonajesDND/backend"

# ─── SPELL NAME TRANSLATIONS (ES, GL) ─────────────────────────────────────
spell_names = {
    "acid-arrow":                   ("Flecha de Ácido",                     "Frecha de Ácido"),
    "acid-splash":                  ("Salpicadura de Ácido",                "Salpicadura de Ácido"),
    "aid":                          ("Auxilio",                             "Auxilio"),
    "alarm":                        ("Alarma",                              "Alarma"),
    "alter-self":                   ("Alterar el Yo",                       "Alterar o Eu"),
    "animal-friendship":            ("Amistad con los Animales",            "Amizade cos Animais"),
    "animal-messenger":             ("Mensajero Animal",                    "Mensaxeiro Animal"),
    "animal-shapes":                ("Formas Animales",                     "Formas Animais"),
    "animate-dead":                 ("Animar Muertos",                      "Animar Mortos"),
    "animate-objects":              ("Animar Objetos",                      "Animar Obxectos"),
    "antilife-shell":               ("Escudo Antivida",                     "Escudo Antivida"),
    "antimagic-field":              ("Campo Antimagia",                     "Campo Antimaxa"),
    "antipathy-sympathy":           ("Antipatía/Simpatía",                  "Antipatía/Simpatía"),
    "arcane-eye":                   ("Ojo Arcano",                          "Ollo Arcano"),
    "arcane-hand":                  ("Mano Arcana",                         "Man Arcana"),
    "arcane-lock":                  ("Cerradura Arcana",                    "Pechadura Arcana"),
    "arcane-sword":                 ("Espada Arcana",                       "Espada Arcana"),
    "arcanists-magic-aura":         ("Aura Mágica del Arcanista",           "Aura Máxica do Arcanista"),
    "astral-projection":            ("Proyección Astral",                   "Proxección Astral"),
    "augury":                       ("Augurio",                             "Augurio"),
    "awaken":                       ("Despertar",                           "Espertar"),
    "bane":                         ("Aflicción",                           "Aflición"),
    "banishment":                   ("Destierro",                           "Desterro"),
    "barkskin":                     ("Corteza",                             "Cortiza"),
    "beacon-of-hope":               ("Faro de Esperanza",                   "Faro de Esperanza"),
    "bestow-curse":                 ("Imponer Maldición",                   "Impor Maldición"),
    "black-tentacles":              ("Tentáculos Negros de Evard",          "Tentáculos Negros de Evard"),
    "blade-barrier":                ("Barrera de Cuchillas",                "Barreira de Follas"),
    "bless":                        ("Bendición",                           "Bendición"),
    "blight":                       ("Plaga",                               "Praga"),
    "blindness-deafness":           ("Ceguera/Sordera",                     "Cegueira/Xordeira"),
    "blink":                        ("Parpadeo",                            "Parpadeo"),
    "blur":                         ("Desenfoque",                          "Desenfoque"),
    "branding-smite":               ("Castigo Marcador",                    "Castigo Marcador"),
    "burning-hands":                ("Manos Ardientes",                     "Mans Ardentes"),
    "call-lightning":               ("Invocar Relámpago",                   "Invocar Raio"),
    "calm-emotions":                ("Calmar Emociones",                    "Calmar Emocións"),
    "chain-lightning":              ("Rayo en Cadena",                      "Raio en Cadea"),
    "charm-person":                 ("Encantar Persona",                    "Encantar Persoa"),
    "chill-touch":                  ("Toque Gélido",                        "Toque Xélido"),
    "circle-of-death":              ("Círculo de Muerte",                   "Círculo de Morte"),
    "clairvoyance":                 ("Clarividencia",                       "Clarivixencia"),
    "clone":                        ("Clon",                                "Clon"),
    "cloudkill":                    ("Nube Mortal",                         "Nube Mortal"),
    "color-spray":                  ("Rociado de Color",                    "Rociado de Cor"),
    "command":                      ("Orden",                               "Orde"),
    "commune":                      ("Comunión",                            "Comunión"),
    "commune-with-nature":          ("Comunión con la Naturaleza",          "Comunión coa Natureza"),
    "comprehend-languages":         ("Comprensión de Idiomas",              "Comprensión de Idiomas"),
    "compulsion":                   ("Compulsión",                          "Compulsión"),
    "cone-of-cold":                 ("Cono de Frío",                        "Cono de Frío"),
    "confusion":                    ("Confusión",                           "Confusión"),
    "conjure-animals":              ("Convocar Animales",                   "Convocar Animais"),
    "conjure-celestial":            ("Convocar Celestial",                  "Convocar Celestial"),
    "conjure-elemental":            ("Convocar Elemental",                  "Convocar Elemental"),
    "conjure-fey":                  ("Convocar Feérico",                    "Convocar Feérico"),
    "conjure-minor-elementals":     ("Convocar Elementales Menores",        "Convocar Elementais Menores"),
    "conjure-woodland-beings":      ("Convocar Seres del Bosque",           "Convocar Seres do Bosque"),
    "contact-other-plane":          ("Contactar Otro Plano",                "Contactar Outro Plano"),
    "contagion":                    ("Contagio",                            "Contaxio"),
    "contingency":                  ("Contingencia",                        "Continxencia"),
    "continual-flame":              ("Llama Continua",                      "Chama Continua"),
    "control-water":                ("Controlar el Agua",                   "Controlar a Auga"),
    "control-weather":              ("Controlar el Clima",                  "Controlar o Clima"),
    "counterspell":                 ("Contrahechizo",                       "Contramazo"),
    "create-food-and-water":        ("Crear Comida y Agua",                 "Crear Comida e Auga"),
    "create-or-destroy-water":      ("Crear o Destruir Agua",               "Crear ou Destruír Auga"),
    "create-undead":                ("Crear No-Muerto",                     "Crear Non-Morto"),
    "creation":                     ("Creación",                            "Creación"),
    "cure-wounds":                  ("Curar Heridas",                       "Curar Feridas"),
    "dancing-lights":               ("Luces Danzantes",                     "Luces Bailantes"),
    "darkness":                     ("Oscuridad",                           "Escuridade"),
    "darkvision":                   ("Visión en la Oscuridad",              "Visión na Escuridade"),
    "daylight":                     ("Luz del Día",                         "Luz do Día"),
    "death-ward":                   ("Guarda contra la Muerte",             "Garda contra a Morte"),
    "delayed-blast-fireball":       ("Bola de Fuego Retardada",             "Bola de Lume Retardada"),
    "demiplane":                    ("Semiplano",                           "Semiplano"),
    "detect-evil-and-good":         ("Detectar el Bien y el Mal",           "Detectar o Ben e o Mal"),
    "detect-magic":                 ("Detectar Magia",                      "Detectar Maxia"),
    "detect-poison-and-disease":    ("Detectar Veneno y Enfermedad",        "Detectar Veleno e Enfermidade"),
    "detect-thoughts":              ("Detectar Pensamientos",               "Detectar Pensamentos"),
    "dimension-door":               ("Puerta Dimensional",                  "Porta Dimensional"),
    "disguise-self":                ("Disfrazarse",                         "Disfrazarse"),
    "disintegrate":                 ("Desintegrar",                         "Desintegrar"),
    "dispel-evil-and-good":         ("Disipar el Bien y el Mal",            "Disipar o Ben e o Mal"),
    "dispel-magic":                 ("Disipar Magia",                       "Disipar Maxia"),
    "divination":                   ("Adivinación",                         "Adiviñación"),
    "divine-favor":                 ("Favor Divino",                        "Favor Divino"),
    "divine-word":                  ("Palabra Divina",                      "Palabra Divina"),
    "dominate-beast":               ("Dominar Bestia",                      "Dominar Besta"),
    "dominate-monster":             ("Dominar Monstruo",                    "Dominar Monstro"),
    "dominate-person":              ("Dominar Persona",                     "Dominar Persoa"),
    "dream":                        ("Sueño",                               "Soño"),
    "druidcraft":                   ("Arte Druídica",                       "Arte Druídica"),
    "earthquake":                   ("Terremoto",                           "Terremoto"),
    "eldritch-blast":               ("Explosión Sobrenatural",              "Explosión Sobrenatural"),
    "enhance-ability":              ("Mejorar Atributo",                    "Mellorar Atributo"),
    "enlarge-reduce":               ("Agrandar/Reducir",                    "Agrandar/Reducir"),
    "entangle":                     ("Enredar",                             "Enredar"),
    "enthrall":                     ("Cautivar",                            "Cativar"),
    "etherealness":                 ("Etereidad",                           "Etereidade"),
    "expeditious-retreat":          ("Retirada Expeditiva",                 "Retirada Expeditiva"),
    "eyebite":                      ("Mordisco Ocular",                     "Mordisco Ocular"),
    "fabricate":                    ("Fabricar",                            "Fabricar"),
    "faerie-fire":                  ("Fuego Feérico",                       "Lume Feérico"),
    "faithful-hound":               ("Sabueso Fiel de Mordenkainen",        "Sabueso Fiel de Mordenkainen"),
    "false-life":                   ("Falsa Vida",                          "Falsa Vida"),
    "fear":                         ("Miedo",                               "Medo"),
    "feather-fall":                 ("Caída de Pluma",                      "Caída de Pluma"),
    "feeblemind":                   ("Mente Débil",                         "Mente Débil"),
    "find-familiar":                ("Hallar Familiar",                     "Atopar Familiar"),
    "find-steed":                   ("Hallar Corcel",                       "Atopar Corcel"),
    "find-the-path":                ("Encontrar el Camino",                 "Atopar o Camiño"),
    "find-traps":                   ("Encontrar Trampas",                   "Atopar Trampas"),
    "finger-of-death":              ("Dedo de la Muerte",                   "Dedo da Morte"),
    "fire-bolt":                    ("Rayo de Fuego",                       "Raio de Lume"),
    "fire-shield":                  ("Escudo de Fuego",                     "Escudo de Lume"),
    "fire-storm":                   ("Tormenta de Fuego",                   "Tormenta de Lume"),
    "fireball":                     ("Bola de Fuego",                       "Bola de Lume"),
    "flame-blade":                  ("Hoja de Llama",                       "Folla de Lume"),
    "flame-strike":                 ("Llamarada",                           "Chamuscada"),
    "flaming-sphere":               ("Esfera Ígnea",                        "Esfera Ígnea"),
    "flesh-to-stone":               ("Carne a Piedra",                      "Carne en Pedra"),
    "floating-disk":                ("Disco Flotante de Tenser",            "Disco Flotante de Tenser"),
    "fly":                          ("Volar",                               "Voar"),
    "fog-cloud":                    ("Nube de Niebla",                      "Nube de Néboa"),
    "forbiddance":                  ("Prohibición",                         "Prohibición"),
    "forcecage":                    ("Jaula de Fuerza",                     "Gaiola de Forza"),
    "foresight":                    ("Presciencia",                         "Presciencia"),
    "freedom-of-movement":          ("Libertad de Movimiento",              "Liberdade de Movemento"),
    "freezing-sphere":              ("Esfera Gélida de Otiluke",            "Esfera Xélida de Otiluke"),
    "gaseous-form":                 ("Forma Gaseosa",                       "Forma Gaseosa"),
    "gate":                         ("Portal",                              "Portal"),
    "geas":                         ("Geas",                                "Geas"),
    "gentle-repose":                ("Reposo Apacible",                     "Repouso Apracible"),
    "giant-insect":                 ("Insecto Gigante",                     "Insecto Xigante"),
    "glibness":                     ("Labia",                               "Labia"),
    "globe-of-invulnerability":     ("Globo de Invulnerabilidad",           "Globo de Invulnerabilidade"),
    "glyph-of-warding":             ("Glifo de Guardia",                    "Glifo de Garda"),
    "goodberry":                    ("Baya de Bondad",                      "Baga da Bondade"),
    "grease":                       ("Grasa",                               "Graxa"),
    "greater-invisibility":         ("Invisibilidad Superior",              "Invisibilidade Superior"),
    "greater-restoration":          ("Restauración Superior",               "Restauración Superior"),
    "guardian-of-faith":            ("Guardián de la Fe",                   "Gardián da Fe"),
    "guards-and-wards":             ("Guardas y Vigilancias",               "Gardas e Vixilancias"),
    "guidance":                     ("Orientación",                         "Orientación"),
    "guiding-bolt":                 ("Rayo Guía",                           "Raio Guía"),
    "gust-of-wind":                 ("Ráfaga de Viento",                    "Ráfaga de Vento"),
    "hallow":                       ("Consagrar",                           "Consagrar"),
    "hallucinatory-terrain":        ("Terreno Alucinatorio",                "Terreo Alucinatorio"),
    "harm":                         ("Dañar",                               "Danar"),
    "haste":                        ("Celeridad",                           "Celeridade"),
    "heal":                         ("Sanar",                               "Sanar"),
    "healing-word":                 ("Palabra Sanadora",                    "Palabra Sanadora"),
    "heat-metal":                   ("Calentar Metal",                      "Quentar Metal"),
    "hellish-rebuke":               ("Represalia Infernal",                 "Represalia Infernal"),
    "heroes-feast":                 ("Festín de los Héroes",                "Festín dos Heróes"),
    "heroism":                      ("Heroísmo",                            "Heroísmo"),
    "hideous-laughter":             ("Risa Horrible de Tasha",              "Risa Horrible de Tasha"),
    "hold-monster":                 ("Inmovilizar Monstruo",                "Inmovilizar Monstro"),
    "hold-person":                  ("Inmovilizar Persona",                 "Inmovilizar Persoa"),
    "holy-aura":                    ("Aura Sagrada",                        "Aura Sagrada"),
    "hunters-mark":                 ("Marca del Cazador",                   "Marca do Cazador"),
    "hypnotic-pattern":             ("Patrón Hipnótico",                    "Padrón Hipnótico"),
    "ice-storm":                    ("Tormenta de Hielo",                   "Tormenta de Xeo"),
    "identify":                     ("Identificar",                         "Identificar"),
    "illusory-script":              ("Escritura Ilusoria",                  "Escritura Ilusoria"),
    "imprisonment":                 ("Encarcelamiento",                     "Encarceramento"),
    "incendiary-cloud":             ("Nube Incendiaria",                    "Nube Incendiaria"),
    "inflict-wounds":               ("Infligir Heridas",                    "Infrinxir Feridas"),
    "insect-plague":                ("Plaga de Insectos",                   "Praga de Insectos"),
    "instant-summons":              ("Invocación Instantánea",              "Invocación Instantánea"),
    "invisibility":                 ("Invisibilidad",                       "Invisibilidade"),
    "irresistible-dance":           ("Danza Irresistible de Otto",          "Danza Irresistible de Otto"),
    "jump":                         ("Saltar",                              "Saltar"),
    "knock":                        ("Abrir",                               "Abrir"),
    "legend-lore":                  ("Conocimiento Legendario",             "Coñecemento Lendario"),
    "lesser-restoration":           ("Restauración Menor",                  "Restauración Menor"),
    "levitate":                     ("Levitar",                             "Levitar"),
    "light":                        ("Luz",                                 "Luz"),
    "lightning-bolt":               ("Rayo",                                "Raio"),
    "locate-animals-or-plants":     ("Localizar Animales o Plantas",        "Localizar Animais ou Plantas"),
    "locate-creature":              ("Localizar Criatura",                  "Localizar Criatura"),
    "locate-object":                ("Localizar Objeto",                    "Localizar Obxecto"),
    "longstrider":                  ("Zancada Larga",                       "Zancada Longa"),
    "mage-armor":                   ("Armadura de Mago",                    "Armadura de Mago"),
    "mage-hand":                    ("Mano de Mago",                        "Man de Mago"),
    "magic-circle":                 ("Círculo Mágico",                      "Círculo Máxico"),
    "magic-jar":                    ("Tarro Mágico",                        "Tarro Máxico"),
    "magic-missile":                ("Proyectil Mágico",                    "Proxectil Máxico"),
    "magic-mouth":                  ("Boca Mágica",                         "Boca Máxica"),
    "magic-weapon":                 ("Arma Mágica",                         "Arma Máxica"),
    "magnificent-mansion":          ("Mansión Magnífica de Mordenkainen",   "Mansión Magnífica de Mordenkainen"),
    "major-image":                  ("Imagen Mayor",                        "Imaxe Maior"),
    "mass-cure-wounds":             ("Curar Heridas en Masa",               "Curar Feridas en Masa"),
    "mass-heal":                    ("Sanación en Masa",                    "Sanación en Masa"),
    "mass-healing-word":            ("Palabra Sanadora en Masa",            "Palabra Sanadora en Masa"),
    "mass-suggestion":              ("Sugestión en Masa",                   "Suxestión en Masa"),
    "maze":                         ("Laberinto",                           "Labirinto"),
    "meld-into-stone":              ("Fundirse con la Piedra",              "Fundirse coa Pedra"),
    "mending":                      ("Remendar",                            "Remendar"),
    "message":                      ("Mensaje",                             "Mensaxe"),
    "meteor-swarm":                 ("Enjambre de Meteoros",                "Enxame de Meteoros"),
    "mind-blank":                   ("Mente en Blanco",                     "Mente en Branco"),
    "minor-illusion":               ("Ilusión Menor",                       "Ilusión Menor"),
    "mirage-arcane":                ("Espejismo Arcano",                    "Espellismo Arcano"),
    "mirror-image":                 ("Imagen Especular",                    "Imaxe Especular"),
    "mislead":                      ("Engañar",                             "Enganar"),
    "misty-step":                   ("Paso Brumoso",                        "Paso Brumoso"),
    "modify-memory":                ("Modificar Memoria",                   "Modificar Memoria"),
    "moonbeam":                     ("Rayo de Luna",                        "Raio de Lúa"),
    "move-earth":                   ("Mover Tierra",                        "Mover Terra"),
    "nondetection":                 ("No Detección",                        "Non Detección"),
    "pass-without-trace":           ("Pasar sin Rastro",                    "Pasar sen Rastro"),
    "passwall":                     ("Atravesar Muros",                     "Atravesar Muros"),
    "phantasmal-killer":            ("Asesino Fantasmal",                   "Asasino Fantasmal"),
    "phantom-steed":                ("Corcel Fantasmal",                    "Corcel Fantasmal"),
    "planar-ally":                  ("Aliado Planar",                       "Aliado Planar"),
    "planar-binding":               ("Vinculación Planar",                  "Vinculación Planar"),
    "plane-shift":                  ("Cambio de Plano",                     "Cambio de Plano"),
    "plant-growth":                 ("Crecimiento Vegetal",                 "Crecemento Vexetal"),
    "poison-spray":                 ("Rociado de Veneno",                   "Rociado de Veleno"),
    "polymorph":                    ("Polimorfismo",                        "Polimorfismo"),
    "power-word-kill":              ("Palabra de Poder: Matar",             "Palabra de Poder: Matar"),
    "power-word-stun":              ("Palabra de Poder: Aturdir",           "Palabra de Poder: Aturdir"),
    "prayer-of-healing":            ("Oración de Sanación",                 "Oración de Sanación"),
    "prestidigitation":             ("Prestidigitación",                    "Prestidigitación"),
    "prismatic-spray":              ("Rociado Prismático",                  "Rociado Prismático"),
    "prismatic-wall":               ("Muro Prismático",                     "Muro Prismático"),
    "private-sanctum":              ("Sanctum Privado de Mordenkainen",     "Sanctum Privado de Mordenkainen"),
    "produce-flame":                ("Producir Llama",                      "Producir Chama"),
    "programmed-illusion":          ("Ilusión Programada",                  "Ilusión Programada"),
    "project-image":                ("Proyectar Imagen",                    "Proxectar Imaxe"),
    "protection-from-energy":       ("Protección contra la Energía",        "Protección contra a Enerxía"),
    "protection-from-evil-and-good":("Protección contra el Bien y el Mal",  "Protección contra o Ben e o Mal"),
    "protection-from-poison":       ("Protección contra el Veneno",         "Protección contra o Veleno"),
    "purify-food-and-drink":        ("Purificar Comida y Bebida",           "Purificar Comida e Bebida"),
    "raise-dead":                   ("Resucitar Muertos",                   "Resucitar Mortos"),
    "ray-of-enfeeblement":          ("Rayo de Debilitamiento",              "Raio de Debilitamento"),
    "ray-of-frost":                 ("Rayo de Escarcha",                    "Raio de Xeada"),
    "regenerate":                   ("Regenerar",                           "Rexenerar"),
    "reincarnate":                  ("Reencarnar",                          "Reencarnar"),
    "remove-curse":                 ("Eliminar Maldición",                  "Eliminar Maldición"),
    "resilient-sphere":             ("Esfera Resiliente de Otiluke",        "Esfera Resiliente de Otiluke"),
    "resistance":                   ("Resistencia",                         "Resistencia"),
    "resurrection":                 ("Resurrección",                        "Resurrección"),
    "reverse-gravity":              ("Invertir Gravedad",                   "Inverter Gravidade"),
    "revivify":                     ("Revivificar",                         "Revivificar"),
    "rope-trick":                   ("Truco de la Cuerda",                  "Truco da Corda"),
    "sacred-flame":                 ("Llama Sagrada",                       "Chama Sagrada"),
    "sanctuary":                    ("Santuario",                           "Santuario"),
    "scorching-ray":                ("Rayo Abrasador",                      "Raio Abrasador"),
    "scrying":                      ("Escudriñar",                          "Escudriñar"),
    "secret-chest":                 ("Cofre Secreto de Leomund",            "Cofre Secreto de Leomund"),
    "see-invisibility":             ("Ver Invisibilidad",                   "Ver Invisibilidade"),
    "seeming":                      ("Parecer",                             "Parecer"),
    "sending":                      ("Enviar Mensaje",                      "Enviar Mensaxe"),
    "sequester":                    ("Secuestrar",                          "Secuestrar"),
    "shapechange":                  ("Cambio de Forma",                     "Cambio de Forma"),
    "shatter":                      ("Añicos",                              "Anacos"),
    "shield":                       ("Escudo",                              "Escudo"),
    "shield-of-faith":              ("Escudo de la Fe",                     "Escudo da Fe"),
    "shillelagh":                   ("Shillelagh",                          "Shillelagh"),
    "shocking-grasp":               ("Garra Eléctrica",                     "Garra Eléctrica"),
    "silence":                      ("Silencio",                            "Silencio"),
    "silent-image":                 ("Imagen Silenciosa",                   "Imaxe Silenciosa"),
    "simulacrum":                   ("Simulacro",                           "Simulacro"),
    "sleep":                        ("Dormir",                              "Durmir"),
    "sleet-storm":                  ("Tormenta de Aguanieve",               "Tormenta de Sarabia"),
    "slow":                         ("Ralentizar",                          "Ralentizar"),
    "spare-the-dying":              ("Salvar al Moribundo",                 "Salvar ao Moribundo"),
    "speak-with-animals":           ("Hablar con Animales",                 "Falar con Animais"),
    "speak-with-dead":              ("Hablar con los Muertos",              "Falar cos Mortos"),
    "speak-with-plants":            ("Hablar con Plantas",                  "Falar coas Plantas"),
    "spider-climb":                 ("Trepar como Araña",                   "Trepar coma Araña"),
    "spike-growth":                 ("Crecimiento de Pinchos",              "Crecemento de Espiñas"),
    "spirit-guardians":             ("Guardianes Espirituales",             "Gardiáns Espirituais"),
    "spiritual-weapon":             ("Arma Espiritual",                     "Arma Espiritual"),
    "stinking-cloud":               ("Nube Fétida",                         "Nube Fétida"),
    "stone-shape":                  ("Moldear la Piedra",                   "Moldear a Pedra"),
    "stoneskin":                    ("Piel Pétrea",                         "Pel Pétrea"),
    "storm-of-vengeance":           ("Tormenta de Venganza",                "Tormenta de Vinganza"),
    "suggestion":                   ("Sugestión",                           "Suxestión"),
    "sunbeam":                      ("Rayo de Sol",                         "Raio de Sol"),
    "sunburst":                     ("Explosión Solar",                     "Explosión Solar"),
    "symbol":                       ("Símbolo",                             "Símbolo"),
    "telekinesis":                  ("Telequinesis",                        "Telequinese"),
    "telepathic-bond":              ("Vínculo Telepático de Rary",          "Vínculo Telepático de Rary"),
    "teleport":                     ("Teletransporte",                      "Teletransporte"),
    "teleportation-circle":         ("Círculo de Teletransporte",           "Círculo de Teletransporte"),
    "thaumaturgy":                  ("Taumaturgia",                         "Taumaturxia"),
    "thunderwave":                  ("Ola de Trueno",                       "Onda de Trobo"),
    "time-stop":                    ("Detener el Tiempo",                   "Deter o Tempo"),
    "tiny-hut":                     ("Cabaña Diminuta de Leomund",          "Cabaña Diminuta de Leomund"),
    "tongues":                      ("Lenguas",                             "Linguas"),
    "transport-via-plants":         ("Transporte por Plantas",              "Transporte por Plantas"),
    "tree-stride":                  ("Zancada Arbórea",                     "Zancada Arbórea"),
    "true-polymorph":               ("Polimorfismo Verdadero",              "Polimorfismo Verdadeiro"),
    "true-resurrection":            ("Resurrección Verdadera",              "Resurrección Verdadeira"),
    "true-seeing":                  ("Visión Verdadera",                    "Visión Verdadeira"),
    "true-strike":                  ("Golpe Verdadero",                     "Golpe Verdadeiro"),
    "unseen-servant":               ("Sirviente Invisible",                 "Sirvente Invisible"),
    "vampiric-touch":               ("Toque Vampírico",                     "Toque Vampírico"),
    "vicious-mockery":              ("Mofa Cruel",                          "Mofa Cruel"),
    "wall-of-fire":                 ("Muro de Fuego",                       "Muro de Lume"),
    "wall-of-force":                ("Muro de Fuerza",                      "Muro de Forza"),
    "wall-of-ice":                  ("Muro de Hielo",                       "Muro de Xeo"),
    "wall-of-stone":                ("Muro de Piedra",                      "Muro de Pedra"),
    "wall-of-thorns":               ("Muro de Espinas",                     "Muro de Espiñas"),
    "warding-bond":                 ("Vínculo Protector",                   "Vínculo Protector"),
    "water-breathing":              ("Respirar Bajo el Agua",               "Respirar Baixo a Auga"),
    "water-walk":                   ("Caminar sobre el Agua",               "Camiñar sobre a Auga"),
    "web":                          ("Telaraña",                            "Tela de Araña"),
    "weird":                        ("Terror",                              "Terror"),
    "wind-walk":                    ("Caminar con el Viento",               "Camiñar co Vento"),
    "wind-wall":                    ("Muro de Viento",                      "Muro de Vento"),
    "wish":                         ("Deseo",                               "Desexo"),
    "word-of-recall":               ("Palabra de Regreso",                  "Palabra de Regreso"),
    "zone-of-truth":                ("Zona de la Verdad",                   "Zona da Verdade"),
}

# ─── CLASS DESCRIPTIONS (ES, GL) ──────────────────────────────────────────
class_descriptions = {
    "barbarian": (
        "Los bárbaros son guerreros primitivos de gran fortaleza. Su poder nace de una furia interior que les otorga resistencia sobrehumana en combate. Conocedores de tierras salvajes, su rabia los convierte en máquinas de destrucción imparables.",
        "Os bárbaros son guerreiros primitivos de gran fortaleza. O seu poder nace dunha rabia interior que lles outorga resistencia sobrehumana no combate. Coñecedores de terras salvaxes, a súa ira convérteos en máquinas de destrución imparables."
    ),
    "bard": (
        "Los bardos tejen la magia a través de palabras y música. Son artistas, narradores y maestros del conocimiento que inspiran a sus aliados y desconciertan a sus enemigos con sus proezas arcanas.",
        "Os bardos tecen a maxia a través de palabras e música. Son artistas, narradores e mestres do coñecemento que inspiran aos seus aliados e desconcertan aos seus inimigos coas súas proezas arcanas."
    ),
    "cleric": (
        "Los clérigos son intermediarios entre el mundo mortal y los planos divinos. Empuñan el poder de su deidad para curar, proteger y destruir en nombre de su fe.",
        "Os clérigos son intermediarios entre o mundo mortal e os planos divinos. Embrandan o poder da súa deidade para curar, protexer e destruír en nome da súa fe."
    ),
    "druid": (
        "Los druidas encarnan la fuerza de la naturaleza. Pueden adoptar formas animales y lanzar hechizos vinculados a los elementos. Son guardianes del equilibrio natural del mundo.",
        "Os druídas encarnan a forza da natureza. Poden adoptar formas animais e lanzar feitizos vinculados aos elementos. Son gardiáns do equilibrio natural do mundo."
    ),
    "fighter": (
        "Los guerreros son maestros del combate con armas y armaduras. Aprenden diversas técnicas de lucha y pueden adoptar especializaciones marciales que los hacen letales en el campo de batalla.",
        "Os guerreiros son mestres do combate con armas e armazóns. Aprenden diversas técnicas de loita e poden adoptar especializacións marciais que os fan letais no campo de batalla."
    ),
    "monk": (
        "Los monjes aprovechan la energía que fluye en sus cuerpos. A través del entrenamiento austero, dominan el ki —la fuerza mística— para superar los límites físicos y enfrentarse al enemigo a manos vacías.",
        "Os monxes aproveitan a enerxía que flúe nos seus corpos. A través do adestramento austero, dominan o ki —a forza mística— para superar os límites físicos e enfrontarse ao inimigo a mans baleiras."
    ),
    "paladin": (
        "Los paladines son guerreros sagrados que juran defender los ideales de justicia y bien. Combinan el poder de combate con hechizos divinos y auras que refuerzan a sus compañeros.",
        "Os paladinos son guerreiros sagrados que xuran defender os ideais de xustiza e ben. Combinan o poder de combate con feitizos divinos e auras que reforzan aos seus compañeiros."
    ),
    "ranger": (
        "Los exploradores son cazadores y rastreadores de tierras salvajes. Dominan el combate en la naturaleza, tienen aliados animales y hechizos ligados al mundo natural.",
        "Os exploradores son cazadores e rastrexadores de terras salvaxes. Dominan o combate na natureza, teñen aliados animais e feitizos ligados ao mundo natural."
    ),
    "rogue": (
        "Los pícaros confían en la astucia, el sigilo y la habilidad para vencer. Son expertos en el ataque sorpresa, con un talento especial para explorar, desactivar trampas y actuar en las sombras.",
        "Os pícaros confían na astucia, o sixilo e a habilidade para vencer. Son expertos no ataque sorpresa, cun talento especial para explorar, desactivar trampas e actuar nas sombras."
    ),
    "sorcerer": (
        "Los hechiceros poseen un poder mágico innato, fruto de su linaje o de una influencia sobrenatural. Canalizan la magia de forma instintiva sin necesidad de largos estudios.",
        "Os feiticeiros posúen un poder máxico innato, froito do seu liñaxe ou dunha influencia sobrenatural. Canalizan a maxia de forma instintiva sen necesidade de longos estudos."
    ),
    "warlock": (
        "Los brujos obtienen su poder de un pacto con un ser sobrenatural. Acceden a una magia oscura y poderosa a cambio de servir los intereses de su patrón.",
        "Os bruxos obteñen o seu poder dun pacto cun ser sobrenatural. Acceden a unha maxia escura e poderosa a cambio de servir os intereses do seu patrón."
    ),
    "wizard": (
        "Los magos son el epítome del usuario de magia, definidos por los hechizos que lanzan. Aprenden la magia a través del estudio riguroso y pueden lanzar hechizos de una variedad casi ilimitada.",
        "Os magos son o epítome do usuario de maxia, definidos polos feitizos que lanzan. Aprenden a maxia a través do estudo rigoroso e poden lanzar feitizos dunha variedade case ilimitada."
    ),
}

# ─── SUBRACE DESCRIPTIONS (ES, GL) ────────────────────────────────────────
subrace_descriptions = {
    "drow": (
        "Descendiente de una antigua subespecie de elfos de piel oscura, los drow fueron desterrados del mundo de la superficie. Viven en las profundidades del Infraoscuridad y adoran a la diosa Lolth.",
        "Descendente dunha antiga subespecies de elfos de pel escura, os drow foron desterrados do mundo da superficie. Viven nas profundidades do Infraescuridade e adoran á deusa Lolth."
    ),
    "forest-gnome": (
        "Como gnomo del bosque, posees un talento natural para la ilusión y una rapidez y sigilo inherentes. Los gnomos del bosque son raros y secretivos.",
        "Como gnomo do bosque, posúes un talento natural para a ilusión e unha rapidez e sixilo inherentes. Os gnomos do bosque son raros e secretivos."
    ),
    "high-elf": (
        "Como elfo de las alturas, posees una mente aguda y dominas al menos los conceptos básicos de la magia.",
        "Como elfo das alturas, posúes unha mente aguda e dominas polo menos os conceptos básicos da maxia."
    ),
    "hill-dwarf": (
        "Como enano de las colinas, posees sentidos agudos, una profunda intuición y una notable resistencia.",
        "Como anano das colinas, posúes sentidos agudos, unha profunda intuición e unha notable resistencia."
    ),
    "lightfoot-halfling": (
        "Como mediano a pie ligero, puedes ocultarte fácilmente de la vista, incluso usando otras personas como cobertura. Eres afable y te llevas bien con todos.",
        "Como halfling a pé lixeiro, podes ocultarte facilmente da vista, incluso usando outras persoas como cobertura. Es afable e lévaste ben con todos."
    ),
    "mountain-dwarf": (
        "Como enano de la montaña, eres fuerte y resistente, acostumbrado a una vida difícil en terreno accidentado.",
        "Como anano da montaña, es forte e resistente, afeito a unha vida difícil en terreo accidentado."
    ),
    "rock-gnome": (
        "Como gnomo de las rocas, posees una inventiva natural y una resistencia superior a la de otros gnomos.",
        "Como gnomo das rochas, posúes unha inventiva natural e unha resistencia superior á doutros gnomos."
    ),
    "stout-halfling": (
        "Como mediano robusto, eres más resistente que la media y tienes cierta resistencia al veneno.",
        "Como halfling robusto, es máis resistente que a media e tes certa resistencia ao veleno."
    ),
    "wood-elf": (
        "Como elfo del bosque, posees sentidos e intuición agudos, y tus ágiles pies te llevan rápida y sigilosamente por tus bosques natales.",
        "Como elfo do bosque, posúes sentidos e intuición agudos, e os teus ágiles pés lévante rápida e sixilosamente polos teus bosques natais."
    ),
}

# ─── RACIAL TRAIT TRANSLATIONS (ES, GL) ───────────────────────────────────
racial_trait_names = {
    "Artificer's Lore":        ("Conocimiento del Artesano",           "Coñecemento do Artesán"),
    "Brave":                   ("Valiente",                            "Valente"),
    "Breath Weapon":           ("Arma de Aliento",                     "Arma de Alento"),
    "Damage Resistance":       ("Resistencia al Daño",                 "Resistencia ao Dano"),
    "Darkvision":              ("Visión en la Oscuridad",              "Visión na Escuridade"),
    "Draconic Ancestry":       ("Ascendencia Dracónica",               "Ascendencia Dracónica"),
    "Drow Magic":              ("Magia Drow",                          "Maxia Drow"),
    "Drow Weapon Training":    ("Entrenamiento con Armas Drow",        "Adestramento con Armas Drow"),
    "Dwarven Armor Training":  ("Entrenamiento con Armadura Enana",    "Adestramento con Armadura de Anano"),
    "Dwarven Combat Training": ("Entrenamiento de Combate Enano",      "Adestramento de Combate de Anano"),
    "Dwarven Resilience":      ("Resiliencia Enana",                   "Resiliencia de Anano"),
    "Dwarven Toughness":       ("Dureza Enana",                        "Dureza de Anano"),
    "Elf Weapon Training":     ("Entrenamiento con Armas Élfico",      "Adestramento con Armas Élfico"),
    "Extra Language":          ("Idioma Adicional",                    "Idioma Adicional"),
    "Fey Ancestry":            ("Ascendencia Feérica",                 "Ascendencia Feérica"),
    "Fleet of Foot":           ("Pies Ligeros",                        "Pés Lixeiros"),
    "Gnome Cunning":           ("Astucia Gnómica",                     "Astucia Gnómica"),
    "Halfling Nimbleness":     ("Agilidad de Mediano",                 "Axilidade de Halfling"),
    "Hellish Resistance":      ("Resistencia Infernal",                "Resistencia Infernal"),
    "High Elf Cantrip":        ("Truco de Elfo de las Alturas",        "Truco de Elfo das Alturas"),
    "Infernal Legacy":         ("Legado Infernal",                     "Legado Infernal"),
    "Keen Senses":             ("Sentidos Agudos",                     "Sentidos Agudos"),
    "Lucky":                   ("Afortunado",                          "Afortunado"),
    "Mask of the Wild":        ("Máscara de lo Salvaje",               "Máscara do Salvaxe"),
    "Menacing":                ("Amenazador",                          "Ameazador"),
    "Natural Illusionist":     ("Ilusionista Natural",                 "Ilusionista Natural"),
    "Naturally Stealthy":      ("Naturalmente Sigiloso",               "Naturalmente Sixiloso"),
    "Relentless Endurance":    ("Resistencia Implacable",              "Resistencia Implacable"),
    "Savage Attacks":          ("Ataques Salvajes",                    "Ataques Salvaxes"),
    "Skill Versatility":       ("Versatilidad de Habilidades",         "Versatilidade de Habilidades"),
    "Speak with Small Beasts": ("Hablar con Bestias Pequeñas",         "Falar con Bestas Pequenas"),
    "Stonecunning":            ("Sabiduría Pétrea",                    "Sabedoría Pétrea"),
    "Stout Resilience":        ("Resiliencia Robusta",                 "Resiliencia Robusta"),
    "Sunlight Sensitivity":    ("Sensibilidad a la Luz Solar",         "Sensibilidade á Luz Solar"),
    "Superior Darkvision":     ("Visión en la Oscuridad Superior",     "Visión na Escuridade Superior"),
    "Tinker":                  ("Manitas",                             "Manitas"),
    "Tool Proficiency":        ("Competencia con Herramientas",        "Competencia con Ferramentas"),
    "Trance":                  ("Trance",                              "Trance"),
}

# ─── SUBCLASS GL-ONLY FIXES (es already set in phase 1) ───────────────────
subclass_gl = {
    "arcane-trickster":            "Tramposo Arcano",
    "assassin":                    "Asasino",
    "battle-master":               "Mestre de Batalla",
    "beast-master":                "Mestre de Bestas",
    "berserker":                   "Berserker",
    "champion":                    "Campión",
    "circle-of-the-moon":          "Círculo da Lúa",
    "college-of-valor":            "Colexio do Valor",
    "devotion":                    "Devoción",
    "draconic":                    "Liñaxe Dracónica",
    "eldritch-knight":             "Cabaleiro Arcano",
    "evocation":                   "Escola de Evocación",
    "fiend":                       "Infernal",
    "hunter":                      "Cazador",
    "knowledge-domain":            "Dominio do Coñecemento",
    "land":                        "Círculo da Terra",
    "life":                        "Dominio da Vida",
    "light-domain":                "Dominio da Luz",
    "lore":                        "Colexio do Saber",
    "nature-domain":               "Dominio da Natureza",
    "oath-of-the-ancients":        "Xuramento dos Ancestros",
    "oath-of-vengeance":           "Xuramento de Vinganza",
    "open-hand":                   "Man Aberta",
    "path-of-the-totem-warrior":   "Senda do Guerreiro Totémico",
    "school-of-abjuration":        "Escola de Abxuración",
    "school-of-conjuration":       "Escola de Conxuración",
    "school-of-divination":        "Escola de Adiviñación",
    "school-of-enchantment":       "Escola de Encantamento",
    "school-of-illusion":          "Escola de Ilusión",
    "school-of-necromancy":        "Escola de Nigromancia",
    "school-of-transmutation":     "Escola de Transmutación",
    "tempest-domain":              "Dominio da Tempestade",
    "the-archfey":                 "Archifada",
    "the-great-old-one":           "Gran Primixenio",
    "thief":                       "Ladrón",
    "trickery-domain":             "Dominio do Engano",
    "war-domain":                  "Dominio da Guerra",
    "way-of-shadow":               "Camiño da Sombra",
    "way-of-the-four-elements":    "Camiño dos Catro Elementos",
    "wild-magic":                  "Maxia Salvaxe",
}


def esc(s: str) -> str:
    """Escape single quotes for MySQL string literals."""
    return s.replace("\\", "\\\\").replace("'", "\\'")


def build_sql() -> str:
    lines = [
        "SET NAMES utf8mb4;",
        "SET character_set_client = utf8mb4;",
        "",
        "-- ═══════════════════════════════════════════════════════",
        "-- Phase 2: Canonical spell name translations",
        "-- ═══════════════════════════════════════════════════════",
    ]
    for idx, (es, gl) in spell_names.items():
        lines.append(
            f"UPDATE spells SET name_es='{esc(es)}', name_gl='{esc(gl)}' WHERE index_api='{idx}';"
        )

    lines += [
        "",
        "-- ═══════════════════════════════════════════════════════",
        "-- Phase 2: Class descriptions",
        "-- ═══════════════════════════════════════════════════════",
    ]
    for idx, (es, gl) in class_descriptions.items():
        lines.append(
            f"UPDATE classes SET description_es='{esc(es)}', description_gl='{esc(gl)}' WHERE index_name='{idx}';"
        )

    lines += [
        "",
        "-- ═══════════════════════════════════════════════════════",
        "-- Phase 2: Subrace descriptions",
        "-- ═══════════════════════════════════════════════════════",
    ]
    for idx, (es, gl) in subrace_descriptions.items():
        lines.append(
            f"UPDATE subraces SET description_es='{esc(es)}', description_gl='{esc(gl)}' WHERE index_name='{idx}';"
        )

    lines += [
        "",
        "-- ═══════════════════════════════════════════════════════",
        "-- Phase 2: Racial trait name translations",
        "-- ═══════════════════════════════════════════════════════",
    ]
    for name, (es, gl) in racial_trait_names.items():
        lines.append(
            f"UPDATE racial_traits SET name_es='{esc(es)}', name_gl='{esc(gl)}' WHERE name='{esc(name)}';"
        )

    lines += [
        "",
        "-- ═══════════════════════════════════════════════════════",
        "-- Phase 2: Subclass GL names",
        "-- ═══════════════════════════════════════════════════════",
    ]
    for idx, gl in subclass_gl.items():
        lines.append(
            f"UPDATE subclasses SET name_gl='{esc(gl)}' WHERE index_name='{idx}';"
        )

    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    sql = build_sql()

    out_path = f"{CWD}/i18n_phase2.sql"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(sql)
    print(f"Generated {sql.count(chr(10))} SQL statements → {out_path}")

    print("Executing against MySQL container…")
    result = subprocess.run(
        DB_CMD,
        input=sql.encode("utf-8"),
        capture_output=True,
        cwd=CWD,
    )
    stdout = result.stdout.decode(errors="replace")
    stderr_lines = [
        l for l in result.stderr.decode(errors="replace").splitlines()
        if "Warning: Using a password" not in l
    ]
    if stdout:
        print(stdout)
    if stderr_lines:
        print("STDERR:\n" + "\n".join(stderr_lines), file=sys.stderr)

    if result.returncode == 0:
        print("✓ Phase 2 translations applied successfully.")
    else:
        print(f"✗ Exit code: {result.returncode}", file=sys.stderr)
        sys.exit(result.returncode)
