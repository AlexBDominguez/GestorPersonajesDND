package enumeration;

public enum FeatureType {
    HP_INCREASE, // Aumentar HP al subir de nivel
    SPELL_LEARN, // Aprender un nuevo hechizo
    SPELL_PREPARE, // Preparar un hechizo conocido
    SPELL_SLOT_UPDATE, // Actualizar los espacios de hechizos disponibles
    SUBCLASS_CHOICE, // Elegir una subclase al alcanzar el nivel requerido
    ASI_OR_FEAT, // Elegir entre Aumento de Característica o una dote al alcanzar el nivel requerido
    FIGHTING_STYLE, // Elegir un estilo de lucha (para clases como el Guerrero o el Paladín)
    INVOCATION, // Elegir una invocación para el Warlock
    METAMAGIC, // Elegir una opción de Metamagia para el Hechicero
    CLASS_FEATURE, // Cualquier otra característica específica de la clase que se obtiene al subir de nivel
    FAVORED_ENEMY, // Elegir un enemigo favorecido (Ranger)
    FAVORED_TERRAIN, // Elegir un terreno favorecido (Ranger)
    DRACONIC_ANCESTRY, // Elegir una ascendencia dracónica (Dragonborn)
    EXPERTISE // Elegir habilidades para la competencia experta (Bard
}