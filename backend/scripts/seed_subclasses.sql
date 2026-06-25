-- Missing subclasses seed (28 new subclasses)
-- Existing class IDs: Barbarian=1,Bard=2,Cleric=3,Druid=4,Fighter=5,Monk=6,Paladin=7,Ranger=8,Rogue=9,Sorcerer=10,Warlock=11,Wizard=12
-- (verify with: SELECT id,name FROM classes ORDER BY id)
SET NAMES utf8mb4;

-- Barbarian
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(1,'path-of-the-totem-warrior','Path of the Totem Warrior',
 'The Path of the Totem Warrior is a spiritual journey, as the barbarian accepts a spirit animal as guide, protector, and inspiration. In battle, your totem spirit fills you with supernatural might, adding magical fuel to your barbarian rage.',
 'Primal Path');

-- Bard
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(2,'college-of-valor','College of Valor',
 'Bards of the College of Valor are daring skalds whose tales keep alive the memory of the great heroes of the past and inspire a new generation of heroes. These bards gather in mead halls or around great bonfires to sing the deeds of the mighty.',
 'Bard College');

-- Cleric subclasses (6 new; Life already exists)
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(3,'knowledge-domain','Knowledge Domain',
 'The gods of knowledge value learning and understanding above all. Some teach that knowledge is to be gathered and shared in libraries and universities, or promote the practical knowledge of craft and magic. Deities of knowledge include Oghma and Ioun.',
 'Divine Domain');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(3,'light-domain','Light Domain',
 'Gods of light promote the ideals of rebirth and renewal, truth, vigilance, and beauty, often using the symbol of the sun. Deities include Pelor, Lathander, Pholtus, Branchala, and the Silver Flame.',
 'Divine Domain');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(3,'nature-domain','Nature Domain',
 'Gods of nature are as varied as the natural world itself, from deities of the sea and storm to those of the harvest, healing, and the wilds. Deities include Silvanus, Obad-Hai, Chauntea, and Uller.',
 'Divine Domain');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(3,'tempest-domain','Tempest Domain',
 'Gods whose portfolios include the Tempest domain govern storms, sea, and sky. They include Talos, Umberlee, Kord, Zeboim, and Riswynn.',
 'Divine Domain');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(3,'trickery-domain','Trickery Domain',
 'Gods of trickery are mischief-makers and instigators who stand as a constant challenge to the accepted order among both gods and mortals. Deities include Tymora, Beshaba, Olidammara, the Traveler, and Garl Glittergold.',
 'Divine Domain');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(3,'war-domain','War Domain',
 'War has many manifestations. It can make heroes of ordinary people. Gods of war watch over warriors and reward great deeds. Deities include Tempus, Hextor, Erythnul, the Halfling pantheon, and Tyr.',
 'Divine Domain');

-- Druid
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(4,'circle-of-the-moon','Circle of the Moon',
 'Druids of the Circle of the Moon are fierce guardians of the wilds. Their order gathers under the full moon to share news and trade warnings. They master ferocious shapes that can strike terror into the most powerful foes.',
 'Druid Circle');

-- Fighter
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(5,'battle-master','Battle Master',
 'Those who emulate the archetypal Battle Master employ martial techniques passed down through generations. A Battle Master might be a noted warrior-teacher who has taught kings and knights, or a knight who has spent years studying anatomy and sword technique.',
 'Martial Archetype');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(5,'eldritch-knight','Eldritch Knight',
 'The archetypal Eldritch Knight combines the martial mastery common to all fighters with a careful study of magic. Eldritch Knights use magical techniques similar to those practiced by wizards. They focus their study on two schools: abjuration and evocation.',
 'Martial Archetype');

-- Monk
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(6,'way-of-shadow','Way of Shadow',
 'Monks of the Way of Shadow follow a tradition that values stealth and subterfuge. These monks might be called ninjas or shadowdancers, and they serve as spies and assassins.',
 'Monastic Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(6,'way-of-the-four-elements','Way of the Four Elements',
 'You follow a monastic tradition that teaches you to harness the elements. When you focus your ki, you can align yourself with the forces of creation and bend the four elements to your will.',
 'Monastic Tradition');

-- Paladin
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(7,'oath-of-the-ancients','Oath of the Ancients',
 'The Oath of the Ancients is as old as the race of elves and the rituals of the druids. Sometimes called fey knights, green knights, or horned knights, paladins who swear this oath cast their lot with the side of the light in the cosmic struggle against darkness.',
 'Sacred Oath');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(7,'oath-of-vengeance','Oath of Vengeance',
 'The Oath of Vengeance is a solemn commitment to punish those who have committed a grievous sin. When evil forces slaughter helpless villagers, when an entire people turns against the will of the gods, the paladins who swear this oath thrust themselves into the harshest conditions.',
 'Sacred Oath');

-- Ranger
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(8,'beast-master','Beast Master',
 'The Beast Master archetype embodies a friendship between the civilized races and the beasts of the world. United in focus, beast and ranger work as one to fight the monstrous foes that threaten civilization and the wilderness alike.',
 'Ranger Archetype');

-- Rogue
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(9,'assassin','Assassin',
 'You focus your training on the grim art of death. Those who adhere to this archetype are diverse: hired killers, spies, bounty hunters, and even specially anointed priests trained to exterminate the enemies of their deity.',
 'Roguish Archetype');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(9,'arcane-trickster','Arcane Trickster',
 'Some rogues enhance their fine-honed skills of stealth and agility with magic, learning tricks of enchantment and illusion. These rogues include pickpockets and burglars, but also pranksters, mischief-makers, and a significant number of adventurers.',
 'Roguish Archetype');

-- Sorcerer
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(10,'wild-magic','Wild Magic',
 'Your innate magic comes from the wild forces of chaos that underlie the order of creation. You might have endured exposure to some form of raw magic, perhaps through a planar portal leading to Limbo or the Elemental Planes.',
 'Sorcerous Origin');

-- Warlock
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(11,'the-archfey','The Archfey',
 'Your patron is a lord or lady of the fey, a creature of legend who holds secrets that were forgotten before the mortal races were born. This being''s motives are often inscrutable, and sometimes whimsical, and might involve the gathering of mortal allies and pawns.',
 'Otherworldly Patron');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(11,'the-great-old-one','The Great Old One',
 'Your patron is a mysterious entity whose nature is utterly foreign to the fabric of reality. It might come from the Far Realm, or it could be one of the elder gods known only in legends. Its desires are unknowable.',
 'Otherworldly Patron');

-- Wizard (7 new; Evocation already exists)
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-abjuration','School of Abjuration',
 'The School of Abjuration emphasizes magic that blocks, banishes, or protects. Detractors of this school call it the best school for cowards. Supporters say that without the abjurers, civilizations would long ago have fallen to ruin.',
 'Arcane Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-conjuration','School of Conjuration',
 'As a conjurer, you favor spells that produce objects and creatures out of thin air. You can conjure billowing clouds of killing fog or summon creatures from elsewhere to fight on your behalf.',
 'Arcane Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-divination','School of Divination',
 'The counsel of a diviner is sought by royalty and commoners alike, for all seek a clearer understanding of the past, present, and future. As a diviner, you strive to part the veils of space, time, and consciousness so that you can see clearly.',
 'Arcane Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-enchantment','School of Enchantment',
 'As a member of the School of Enchantment, you have honed your ability to magically entrance and beguile other people and monsters. Some enchanters are peacemakers who bewitch the violent to lay down their arms and treat others with respect.',
 'Arcane Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-illusion','School of Illusion',
 'You focus your studies on magic that dazzles the senses, befuddles the mind, and tricks even the wisest folk. Your magic is subtle, but the illusions crafted by your keen mind make the impossible seem real.',
 'Arcane Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-necromancy','School of Necromancy',
 'The School of Necromancy explores the cosmic forces of life, death, and undeath. As you focus your studies in this tradition, you learn to manipulate the energy that animates all living things.',
 'Arcane Tradition');
INSERT INTO subclasses (class_id, index_name, name, description, subclass_flavor) VALUES
(12,'school-of-transmutation','School of Transmutation',
 'You are a student of spells that modify energy and matter. To you, the world is not a fixed thing, but eminently mutable, and you delight in being an agent of change. You wield the raw stuff of creation and learn to alter both physical forms and mental qualities.',
 'Arcane Tradition');
