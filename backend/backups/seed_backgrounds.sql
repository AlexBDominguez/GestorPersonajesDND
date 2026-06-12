-- PHB Backgrounds seed (excludes Acolyte which already exists)
-- Run: docker exec -i dnd-mysql mysql -udnd_user -pdnd_password dnd_character_manager < seed_backgrounds.sql

SET NAMES utf8mb4;

-- ── Charlatan ─────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('charlatan','Charlatan',0,'False Identity',
 'You have created a second identity that includes documentation, established acquaintances, and disguises that allow you to assume that persona. Additionally, you can forge documents including official papers and personal letters, as long as you have seen an example of the kind of document or the handwriting you are trying to copy.',
 'You have always had a way with people. You know what makes them tick, you can tease out their conceits and worries within minutes of meeting them, and you know how to use them. It did not take you long to adopt this facilitation as a more profitable way of life. You know what people want and you deliver, or rather, you promise to deliver. Common sense should steer people away from things that seem too good to be true, but common sense seems to be a commodity you have never lacked — while your marks seemed to have lost it entirely.');

SET @charlatan_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@charlatan_id,'skill-deception'),(@charlatan_id,'skill-sleight-of-hand');
INSERT INTO background_tool_proficiencies VALUES (@charlatan_id,'Disguise kit'),(@charlatan_id,'Forgery kit');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@charlatan_id,'I fall in and out of love easily, and am always pursuing someone.'),
(@charlatan_id,'I have a joke for every occasion, especially occasions where humor is inappropriate.'),
(@charlatan_id,'Flattery is my preferred trick for getting what I want.'),
(@charlatan_id,'I''m a born gambler who can''t resist taking a risk for a potential payoff.'),
(@charlatan_id,'I lie about almost everything, even when there''s no good reason to.'),
(@charlatan_id,'Sarcasm and insults are my weapons of choice.'),
(@charlatan_id,'I keep multiple holy symbols on me and invoke whatever deity seems most useful at any given moment.'),
(@charlatan_id,'I pocket anything I see that might have some value.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@charlatan_id,'Independence. I am a free spirit — no one tells me what to do.'),
(@charlatan_id,'Fairness. I never target people who can''t afford to lose a few coins.'),
(@charlatan_id,'Creativity. I never run the same con twice.'),
(@charlatan_id,'Friendship. Material goods come and go. Bonds of friendship last forever.'),
(@charlatan_id,'Aspiration. I''m determined to make something of myself.'),
(@charlatan_id,'Redemption. I''m trying to pay off an old debt I owe to a generous benefactor.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@charlatan_id,'I fleeced the wrong person and must work to ensure that this individual never crosses paths with me or those I care about.'),
(@charlatan_id,'I owe everything to my mentor — a horrible person who''s probably rotting in jail somewhere.'),
(@charlatan_id,'Somewhere out there, I have a child who doesn''t know me. I''m making the world better for him or her.'),
(@charlatan_id,'I come from a noble family, and one day I''ll reclaim my lands and title from those who stole them from me.'),
(@charlatan_id,'A powerful person killed someone I love. Some day soon, I''ll have my revenge.'),
(@charlatan_id,'I swindled and ruined a person who didn''t deserve it. I seek to atone for my misdeeds but might never be able to forgive myself.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@charlatan_id,'I can''t resist a pretty face.'),
(@charlatan_id,'I''m always in debt. I spend my ill-gotten gains on decadent luxuries faster than I bring them in.'),
(@charlatan_id,'I''m convinced that no one could ever fool me the way I fool others.'),
(@charlatan_id,'I''m too greedy for my own good. I can''t resist taking a risk if there''s money involved.'),
(@charlatan_id,'I can''t resist swindling people who are more powerful than me.'),
(@charlatan_id,'I hate to admit it and will hate myself for it, but I''ll run and preserve my own hide if the going gets tough.');

-- ── Criminal ──────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('criminal','Criminal',0,'Criminal Contact',
 'You have a reliable and trustworthy contact who acts as your liaison to a network of other criminals. You know how to get messages to and from your contact, even over great distances; specifically, you know the local messengers, corrupt caravan masters, and seedy sailors who can deliver messages for you.',
 'You are an experienced criminal with a history of breaking the law. You have spent a lot of time among other criminals and still have contacts within the criminal underworld. You''re far closer than most people to the world of murder, theft, and violence that pervades the underbelly of civilization, and you have survived up to this point by flouting the rules and regulations of society.');

SET @criminal_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@criminal_id,'skill-deception'),(@criminal_id,'skill-stealth');
INSERT INTO background_tool_proficiencies VALUES (@criminal_id,'Thieves'' tools'),(@criminal_id,'One type of gaming set');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@criminal_id,'I always have a plan for what to do when things go wrong.'),
(@criminal_id,'I am always calm, no matter what the situation. I never raise my voice or let my emotions control me.'),
(@criminal_id,'The first thing I do in a new place is note the locations of everything valuable — or where such things could be hidden.'),
(@criminal_id,'I would rather make a new friend than a new enemy.'),
(@criminal_id,'I am incredibly slow to trust. Those who seem the fairest often have the most to hide.'),
(@criminal_id,'I don''t pay attention to the risks in a situation. Never tell me the odds.'),
(@criminal_id,'The best way to get me to do something is to tell me I can''t do it.'),
(@criminal_id,'I blow up at the slightest insult.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@criminal_id,'Honor. I don''t steal from others in the trade.'),
(@criminal_id,'Freedom. Chains are meant to be broken, as are those who would forge them.'),
(@criminal_id,'Charity. I steal from the wealthy so that I can help people in need.'),
(@criminal_id,'Greed. I will do whatever it takes to become wealthy.'),
(@criminal_id,'People. I''m loyal to my friends, not to any ideals, and everyone else can take a trip down the Styx for all I care.'),
(@criminal_id,'Redemption. There''s a spark of good in everyone.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@criminal_id,'I''m trying to pay off an old debt I owe to a generous benefactor.'),
(@criminal_id,'My ill-gotten gains go to support my family.'),
(@criminal_id,'Something important was taken from me, and I aim to steal it back.'),
(@criminal_id,'I will become the greatest thief that ever lived.'),
(@criminal_id,'I''m guilty of a terrible crime. I hope I can redeem myself for it.'),
(@criminal_id,'Someone I loved died because of a mistake I made. That will never happen again.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@criminal_id,'When I see something valuable, I can''t think about anything but how to steal it.'),
(@criminal_id,'When faced with a choice between money and my friends, I usually choose the money.'),
(@criminal_id,'If there''s a plan, I''ll forget it. If I don''t forget it, I''ll ignore it.'),
(@criminal_id,'I have a "tell" that reveals when I''m lying.'),
(@criminal_id,'I turn tail and run when things look bad.'),
(@criminal_id,'An innocent person is in prison for a crime that I committed. I''m okay with that.');

-- ── Entertainer ───────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('entertainer','Entertainer',0,'By Popular Demand',
 'You can always find a place to perform, usually in an inn or tavern but possibly with a circus, at a theater, or even in a noble''s court. At such a place, you receive free lodging and food of a modest or comfortable standard (depending on the quality of the establishment), as long as you perform each night. In addition, your performance makes you something of a local figure. When strangers recognize you in a town where you have performed, they typically take a liking to you.',
 'You thrive in front of an audience. You know how to entrance them, entertain them, and even inspire them. Your poetics can stir the hearts of those who hear you, awakening grief or joy, laughter or anger. Your music raises their spirits or captures their sorrow. Your dance steps captivate, your humor cuts to the quick. Whatever techniques you use, your art is your life.');

SET @entertainer_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@entertainer_id,'skill-acrobatics'),(@entertainer_id,'skill-performance');
INSERT INTO background_tool_proficiencies VALUES (@entertainer_id,'Disguise kit'),(@entertainer_id,'One type of musical instrument');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@entertainer_id,'I know a story relevant to almost every situation.'),
(@entertainer_id,'Whenever I come to a new place, I collect local rumors and spread gossip.'),
(@entertainer_id,'I''m a hopeless romantic, always searching for that "special someone."'),
(@entertainer_id,'Nobody stays angry at me or around me for long, since I can defuse any amount of tension.'),
(@entertainer_id,'I love a good insult, even one directed at me.'),
(@entertainer_id,'I get bitter if I''m not the center of attention.'),
(@entertainer_id,'I''ll settle for nothing less than perfection.'),
(@entertainer_id,'I change my mood or my mind as quickly as I change key in a song.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@entertainer_id,'Beauty. When I perform, I make the world better than it was.'),
(@entertainer_id,'Tradition. The stories, legends, and songs of the past must never be forgotten.'),
(@entertainer_id,'Creativity. The world is in need of new ideas and bold action.'),
(@entertainer_id,'Greed. I''m only in it for the money and fame.'),
(@entertainer_id,'People. I like seeing the smiles on people''s faces when I perform.'),
(@entertainer_id,'Honesty. Art should reflect the soul; it should come from within and reveal who we really are.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@entertainer_id,'My instrument is my most treasured possession, and it reminds me of someone I love.'),
(@entertainer_id,'Someone stole my precious instrument, and someday I''ll get it back.'),
(@entertainer_id,'I want to be famous, whatever it takes.'),
(@entertainer_id,'I idolize a hero of the old tales and measure my deeds against that person''s.'),
(@entertainer_id,'I will do anything to prove myself superior to my hated rival.'),
(@entertainer_id,'I would do anything for the other members of my old troupe.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@entertainer_id,'I''ll do anything to win fame and renown.'),
(@entertainer_id,'I''m a sucker for a pretty face.'),
(@entertainer_id,'A scandal prevents me from ever going home again. That kind of trouble seems to follow me around.'),
(@entertainer_id,'I once satirized a noble who still wants my head. It was a mistake that I will likely repeat.'),
(@entertainer_id,'I have trouble keeping my true feelings hidden. My sharp tongue lands me in trouble.'),
(@entertainer_id,'Despite my best efforts, I am unreliable to my friends.');

-- ── Folk Hero ─────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('folk-hero','Folk Hero',0,'Rustic Hospitality',
 'Since you come from the ranks of the common folk, you fit in among them with ease. You can find a place to hide, rest, or recuperate among other commoners, unless you have shown yourself to be a danger to them. They will shield you from the law or anyone else searching for you, though they will not risk their lives for you.',
 'You come from a humble social rank, but you are destined for so much more. Already the people of your home village regard you as their champion, and your destiny calls you to stand against the tyrants and monsters that threaten the common folk everywhere.');

SET @folkhero_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@folkhero_id,'skill-animal-handling'),(@folkhero_id,'skill-survival');
INSERT INTO background_tool_proficiencies VALUES (@folkhero_id,'One type of artisan''s tools'),(@folkhero_id,'Vehicles (land)');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@folkhero_id,'I judge people by their actions, not their words.'),
(@folkhero_id,'If someone is in trouble, I''m always ready to lend help.'),
(@folkhero_id,'When I set my mind to something, I follow through no matter what gets in my way.'),
(@folkhero_id,'I have a strong sense of fair play and always try to find the most equitable solution to arguments.'),
(@folkhero_id,'I''m confident in my own abilities and do what I can to instill that same confidence in others.'),
(@folkhero_id,'Thinking is for other people. I prefer action.'),
(@folkhero_id,'I misuse long words in an attempt to sound smarter.'),
(@folkhero_id,'I get bored easily. When am I going to get on with my destiny?');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@folkhero_id,'Respect. People deserve to be treated with dignity and respect.'),
(@folkhero_id,'Fairness. No one should get preferential treatment before the law, and no one is above the law.'),
(@folkhero_id,'Freedom. Tyrants must not be allowed to oppress the people.'),
(@folkhero_id,'Might. If I become strong, I can take what I want — what I deserve.'),
(@folkhero_id,'Sincerity. There''s no good in pretending to be something I''m not.'),
(@folkhero_id,'Destiny. Nothing and no one can steer me away from my higher calling.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@folkhero_id,'I have a family, but I have no idea where they are. One day, I hope to see them again.'),
(@folkhero_id,'I worked the land, I love the land, and I will protect the land.'),
(@folkhero_id,'A proud noble once gave me a horrible beating, and I will take my revenge on any bully I encounter.'),
(@folkhero_id,'My tools are symbols of my past life, and I carry them so that I will never forget my roots.'),
(@folkhero_id,'I protect those who cannot protect themselves.'),
(@folkhero_id,'I wish my childhood sweetheart had come with me to pursue my destiny.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@folkhero_id,'The tyrant who rules my land will stop at nothing to see me killed.'),
(@folkhero_id,'I''m convinced of the significance of my destiny, and blind to my own limitations and the risk of failure.'),
(@folkhero_id,'The people who knew me when I was young know my shameful secret, so I can never go home again.'),
(@folkhero_id,'I have a weakness for the vices of the city, especially hard drink.'),
(@folkhero_id,'Secretly, I believe that things would be better if I were a tyrant lording over the land.'),
(@folkhero_id,'I have trouble trusting in my allies.');

-- ── Guild Artisan ─────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('guild-artisan','Guild Artisan',1,'Guild Membership',
 'As an established and respected member of a guild, you can rely on certain benefits that membership provides. Your fellow guild members will provide you with lodging and food if necessary, and pay for your funeral if needed. In some cities and towns, a guildhall offers a central place to meet other members of your profession, which can be a good place to meet potential patrons, allies, or hirelings. Guilds often wield tremendous political power. If you are accused of a crime, your guild will support you if a good case can be made for your innocence or the crime is justifiable. You can also gain access to powerful political figures through the guild, if you are a member in good standing.',
 'You are a member of an artisan''s guild, skilled in a particular field and closely associated with other artisans. You are a well-established part of the mercantile world, freed by talent and wealth from the constraints of a feudal social order. You learned your skills as an apprentice to a master artisan, under the sponsorship of your guild, until you became a master in your own right.');

SET @guildartisan_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@guildartisan_id,'skill-insight'),(@guildartisan_id,'skill-persuasion');
INSERT INTO background_tool_proficiencies VALUES (@guildartisan_id,'One type of artisan''s tools');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@guildartisan_id,'I believe that anything worth doing is worth doing right. I can''t help it — I''m a perfectionist.'),
(@guildartisan_id,'I''m a snob who looks down on those who can''t appreciate fine art.'),
(@guildartisan_id,'I always want to know how things work and what makes people tick.'),
(@guildartisan_id,'I''m full of witty aphorisms and have a proverb for every occasion.'),
(@guildartisan_id,'I''m rude to people who lack my commitment to hard work and fair play.'),
(@guildartisan_id,'I like to talk at length about my profession.'),
(@guildartisan_id,'I don''t part with my money easily and will haggle tirelessly to get the best deal possible.'),
(@guildartisan_id,'I''m well known for my work, and I want to make sure everyone appreciates it.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@guildartisan_id,'Community. It is the duty of all civilized people to strengthen the bonds of community and the security of civilization.'),
(@guildartisan_id,'Generosity. My talents were given to me so that I could use them to benefit the world.'),
(@guildartisan_id,'Freedom. Everyone should be free to pursue his or her own livelihood.'),
(@guildartisan_id,'Greed. I''m only in it for the money.'),
(@guildartisan_id,'People. I''m committed to the people I care about, not to ideals.'),
(@guildartisan_id,'Aspiration. I work hard to be the best there is at my craft.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@guildartisan_id,'The workshop where I learned my trade is the most important place in the world to me.'),
(@guildartisan_id,'I created a great work for someone, and then found them unworthy to receive it. I''m still looking for someone worthy.'),
(@guildartisan_id,'I owe my guild a great debt for forging me into the person I am today.'),
(@guildartisan_id,'I pursue wealth to secure someone''s love.'),
(@guildartisan_id,'One day I will return to my guild and prove that I am the greatest artisan of them all.'),
(@guildartisan_id,'I will get revenge on the evil forces that destroyed my place of business and ruined my livelihood.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@guildartisan_id,'I''ll do anything to get my hands on something rare or priceless.'),
(@guildartisan_id,'I''m quick to assume that someone is trying to cheat me.'),
(@guildartisan_id,'No one must ever learn that I once stole money from guild coffers.'),
(@guildartisan_id,'I''m never satisfied with what I have — I always want more.'),
(@guildartisan_id,'I would kill to acquire a signature piece from a famous artist.'),
(@guildartisan_id,'I''m horribly jealous of anyone who can outshine my handiwork.');

-- ── Hermit ────────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('hermit','Hermit',1,'Discovery',
 'The quiet seclusion of your extended hermitage gave you access to a unique and powerful discovery. The exact nature of this revelation depends on the nature of your seclusion. It might be a great truth about the cosmos, the deities, the powerful beings of the outer planes, or the forces of nature. It could be a site that no one else has ever seen. You might have uncovered a fact that has long been forgotten, or unearthed some relic of the past that could rewrite history. It might be information that would be damaging to the people who or consigned you to exile, and hence the reason for your return to society.',
 'You lived in seclusion — either in a sheltered community such as a monastery, or entirely alone — for a formative part of your life. In your time apart from the clamor of society, you found quiet, solitude, and perhaps some of the answers you were looking for.');

SET @hermit_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@hermit_id,'skill-medicine'),(@hermit_id,'skill-religion');
INSERT INTO background_tool_proficiencies VALUES (@hermit_id,'Herbalism kit');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@hermit_id,'I''ve been isolated for so long that I rarely speak, preferring gestures and the occasional grunt.'),
(@hermit_id,'I am utterly serene, even in the face of disaster.'),
(@hermit_id,'The leader of my community had something wise to say on every topic, and I am eager to share that wisdom.'),
(@hermit_id,'I feel tremendous empathy for all who suffer.'),
(@hermit_id,'I''m oblivious to etiquette and social expectations.'),
(@hermit_id,'I connect everything that happens to me to a grand, cosmic plan.'),
(@hermit_id,'I often get lost in my own thoughts and contemplation, becoming oblivious to my surroundings.'),
(@hermit_id,'I am working on a grand philosophical theory and love sharing my ideas.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@hermit_id,'Greater Good. My gifts are meant to be shared with all, not used for my own benefit.'),
(@hermit_id,'Logic. Emotions must not cloud our sense of what is right and true.'),
(@hermit_id,'Free Thinking. Inquiry and curiosity are the pillars of progress.'),
(@hermit_id,'Power. Solitude and contemplation are paths toward mystical or magical power.'),
(@hermit_id,'Live and Let Live. Meddling in the affairs of others only causes trouble.'),
(@hermit_id,'Self-Knowledge. If you know yourself, there''s nothing left to know.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@hermit_id,'Nothing is more important than the other members of my hermitage, order, or association.'),
(@hermit_id,'I entered seclusion to hide from the ones who might still be hunting me. I must someday confront them.'),
(@hermit_id,'I''m still seeking the enlightenment I pursued in my seclusion, and it still eludes me.'),
(@hermit_id,'I entered seclusion because I loved someone I could not have.'),
(@hermit_id,'Should my discovery come to light, it could bring ruin to the world.'),
(@hermit_id,'My isolation gave me great insight into a great evil that only I can destroy.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@hermit_id,'Now that I''ve returned to the world, I enjoy its delights a little too much.'),
(@hermit_id,'I harbor dark, bloodthirsty thoughts that my isolation and meditation failed to quell.'),
(@hermit_id,'I am dogmatic in my thoughts and philosophy.'),
(@hermit_id,'I let my need to win arguments overshadow friendships and harmony.'),
(@hermit_id,'I''d risk too much to uncover a lost bit of knowledge.'),
(@hermit_id,'I like keeping secrets and won''t share them with anyone.');

-- ── Noble ─────────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('noble','Noble',1,'Position of Privilege',
 'Thanks to your noble birth, people are inclined to think the best of you. You are welcome in high society, and people assume you have the right to be wherever you are. The common folk make every effort to accommodate you and avoid your displeasure, and other people of high birth treat you as a member of the same social sphere. You can secure an audience with a local noble if you need to.',
 'You understand wealth, power, and privilege. You carry a noble title, and your family owns land, collects taxes, and wields significant political influence. You might be a pampered aristocrat unfamiliar with work or discomfort, a former merchant just elevated to the nobility, or a disinherited scoundrel with a disproportionate sense of entitlement. Or you could be an honest, hard-working landowner who cares deeply about the people who live and work on your land, keenly aware of your responsibility to them.');

SET @noble_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@noble_id,'skill-history'),(@noble_id,'skill-persuasion');
INSERT INTO background_tool_proficiencies VALUES (@noble_id,'One type of gaming set');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@noble_id,'My eloquent flattery makes everyone I talk to feel like the most wonderful and important person in the world.'),
(@noble_id,'The common folk love me for my kindness and generosity.'),
(@noble_id,'No one could doubt by looking at my regal bearing that I am a cut above the unwashed masses.'),
(@noble_id,'I take great pains to always look my best and follow the latest fashions.'),
(@noble_id,'I don''t like to get dirty, and I won''t be caught dead in unsuitable accommodations.'),
(@noble_id,'Despite my noble birth, I do not place myself above other folk. We all have the same blood.'),
(@noble_id,'My favor, once lost, is lost forever.'),
(@noble_id,'If you do me an injury, I will crush you, ruin your name, and salt your fields.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@noble_id,'Respect. Respect is due to me because of my position, but all people regardless of station deserve to be treated with dignity.'),
(@noble_id,'Responsibility. It is my duty to respect the authority of those above me, just as those below me must respect mine.'),
(@noble_id,'Independence. I must prove that I can handle myself without the coddling of my family.'),
(@noble_id,'Power. If I can attain more power, no one will tell me what to do.'),
(@noble_id,'Family. Blood runs thicker than water.'),
(@noble_id,'Noble Obligation. It is my duty to protect and care for the people beneath me.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@noble_id,'I will face any challenge to win the approval of my family.'),
(@noble_id,'My house''s alliance with another noble family must be sustained at all costs.'),
(@noble_id,'Nothing is more important than the other members of my family.'),
(@noble_id,'I am in love with the heir of a family that my family despises.'),
(@noble_id,'My loyalty to my sovereign is unwavering.'),
(@noble_id,'The common folk must see me as a hero of the people.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@noble_id,'I secretly believe that everyone is beneath me.'),
(@noble_id,'I hide a truly scandalous secret that could ruin my family forever.'),
(@noble_id,'I too often hear veiled insults and threats in every word addressed to me, and I''m quick to anger.'),
(@noble_id,'I have an insatiable desire for carnal pleasures.'),
(@noble_id,'In fact, the world does revolve around me.'),
(@noble_id,'By my words and actions, I often bring shame to my family.');

-- ── Outlander ─────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('outlander','Outlander',1,'Wanderer',
 'You have an excellent memory for maps and geography, and you can always recall the general layout of terrain, settlements, and other features around you. In addition, you can find food and fresh water for yourself and up to five other people each day, provided that the land offers berries, small game, water, and so forth.',
 'You grew up in the wilds, far from civilization and the comforts of town and technology. You''ve witnessed the migration of herds larger than forests, survived weather more extreme than any city-dweller could comprehend, and enjoyed the solitude of being the only thinking creature for miles in any direction. The wilds are in your blood, whether you were a nomad, an explorer, a recluse, a hunter-gatherer, or even a marauder. Even in places where you don''t know the specific features of the terrain, you know the ways of the wild.');

SET @outlander_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@outlander_id,'skill-athletics'),(@outlander_id,'skill-survival');
INSERT INTO background_tool_proficiencies VALUES (@outlander_id,'One type of musical instrument');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@outlander_id,'I''m driven by a wanderlust that led me away from home.'),
(@outlander_id,'I watch over my friends as if they were a litter of newborn pups.'),
(@outlander_id,'I once ran twenty-five miles without stopping to warn my clan of an approaching orc horde.'),
(@outlander_id,'I have a lesson for every situation, drawn from observing nature.'),
(@outlander_id,'I place no stock in wealthy or well-mannered folk. Money and manners won''t save you from a hungry owlbear.'),
(@outlander_id,'I''m always picking things up, absently fiddling with them, and sometimes accidentally breaking them.'),
(@outlander_id,'I feel far more comfortable around animals than people.'),
(@outlander_id,'I was, in fact, raised by wolves.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@outlander_id,'Change. Life is like the seasons, in constant change, and we must change with it.'),
(@outlander_id,'Greater Good. It is each person''s responsibility to make the most happiness for the whole tribe.'),
(@outlander_id,'Honor. If I dishonor myself, I dishonor my whole clan.'),
(@outlander_id,'Might. The strongest are meant to rule.'),
(@outlander_id,'Nature. The natural world is more important than all the constructs of civilization.'),
(@outlander_id,'Glory. I must earn glory in battle, for myself and my clan.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@outlander_id,'My family, clan, or tribe is the most important thing in my life, even when they are far from me.'),
(@outlander_id,'An injury to the unspoiled wilderness of my home is an injury to me.'),
(@outlander_id,'I will bring terrible wrath down on the evildoers who destroyed my homeland.'),
(@outlander_id,'I am the last of my tribe, and it is up to me to ensure their names enter legend.'),
(@outlander_id,'I suffer awful visions of a coming disaster and will do anything to prevent it.'),
(@outlander_id,'It is my duty to provide children to sustain my tribe.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@outlander_id,'I am too enamored of ale, wine, and other intoxicants.'),
(@outlander_id,'There''s no room for caution in a life lived to the fullest.'),
(@outlander_id,'I remember every insult I''ve received and nurse a silent resentment toward anyone who''s ever wronged me.'),
(@outlander_id,'I am slow to trust members of other races, tribes, and societies.'),
(@outlander_id,'Violence is my answer to almost any challenge.'),
(@outlander_id,'Don''t expect me to save those who can''t save themselves. It is nature''s way that the strong thrive and the weak perish.');

-- ── Sage ──────────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('sage','Sage',2,'Researcher',
 'When you attempt to learn or recall a piece of lore, if you do not know that information, you often know where and from whom you can obtain it. Usually, this information comes from a library, scriptorium, university, or a sage or other learned person or creature. Your DM might rule that the knowledge you seek is secreted away in an almost inaccessible place, or that it simply cannot be found. Unearthing the deepest secrets of the multiverse can require an adventure or even a whole campaign.',
 'You spent years learning the lore of the multiverse. You scoured manuscripts, studied scrolls, and listened to the greatest experts on the subjects that interest you. Your efforts have made you a master of your chosen fields of study.');

SET @sage_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@sage_id,'skill-arcana'),(@sage_id,'skill-history');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@sage_id,'I use polysyllabic words that convey the impression of great erudition.'),
(@sage_id,'I''ve read every book in the world''s greatest libraries — or I like to boast that I have.'),
(@sage_id,'I''m used to helping out those who aren''t as smart as I am, and I patiently explain anything and everything to others.'),
(@sage_id,'There''s nothing I like more than a good mystery.'),
(@sage_id,'I''m willing to listen to every side of an argument before I make my own judgment.'),
(@sage_id,'I... speak... slowly... when talking to idiots, which almost everyone is compared to me.'),
(@sage_id,'I am horribly, horribly awkward in social situations.'),
(@sage_id,'I''m convinced that people are always trying to steal my secrets.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@sage_id,'Knowledge. The path to power and self-improvement is through knowledge.'),
(@sage_id,'Beauty. What is beautiful points us beyond itself toward what is true.'),
(@sage_id,'Logic. Emotions must not cloud our logical thinking.'),
(@sage_id,'No Limits. Nothing should fetter the infinite possibility inherent in all existence.'),
(@sage_id,'Power. Knowledge is the path to power and domination.'),
(@sage_id,'Self-Improvement. The goal of a life of study is the betterment of oneself.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@sage_id,'It is my duty to protect my students.'),
(@sage_id,'I have an ancient text that holds terrible secrets that must not fall into the wrong hands.'),
(@sage_id,'I work to preserve a library, university, scriptorium, or monastery.'),
(@sage_id,'My life''s work is a series of tomes related to a specific field of lore.'),
(@sage_id,'I''ve been searching my whole life for the answer to a certain question.'),
(@sage_id,'I sold my soul for knowledge. I hope to do great deeds and win it back.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@sage_id,'I am easily distracted by the promise of information.'),
(@sage_id,'Most people scream and run when they see a demon. I stop and take notes on its anatomy.'),
(@sage_id,'Unlocking an ancient mystery is worth the price of a civilization.'),
(@sage_id,'I overlook obvious solutions in favor of complicated ones.'),
(@sage_id,'I speak without really thinking through my words, invariably insulting others.'),
(@sage_id,'I can''t keep a secret to save my life, or anyone else''s.');

-- ── Sailor ────────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('sailor','Sailor',0,'Ship''s Passage',
 'When you need to, you can secure free passage on a sailing ship for yourself and your adventuring companions. You might sail on the ship you served on, or another ship you have good relations with (perhaps one captained by a former crewmate). Because you''re calling in a favor, you can''t be certain of a schedule or route that will meet your every need. Your Dungeon Master will determine how long it takes to get where you need to go. In return for your free passage, you and your companions are expected to assist the crew during the voyage.',
 'You sailed on a seagoing vessel for years. In that time, you faced down mighty storms, monsters of the deep, and those who wanted to sink your craft to the bottomless depths. Your first love is the distant line of the horizon, but the time has come to try your hand at something new. Discuss the details of your career with your Dungeon Master. Were you a merchant sailor, a naval officer, a product of a nautical family tradition, or a pirate?');

SET @sailor_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@sailor_id,'skill-athletics'),(@sailor_id,'skill-perception');
INSERT INTO background_tool_proficiencies VALUES (@sailor_id,'Navigator''s tools'),(@sailor_id,'Vehicles (water)');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@sailor_id,'My friends know they can rely on me, no matter what.'),
(@sailor_id,'I work hard so that I can play hard when the work is done.'),
(@sailor_id,'I enjoy sailing into new ports and making new friends over a flagon of ale.'),
(@sailor_id,'I stretch the truth for the sake of a good story.'),
(@sailor_id,'To me, a tavern brawl is a nice way to get to know a new city.'),
(@sailor_id,'I never pass up a friendly wager.'),
(@sailor_id,'My language is as foul as an otyugh nest.'),
(@sailor_id,'I like a job well done, especially if I can convince someone else to do it.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@sailor_id,'Respect. The thing that keeps a ship together is mutual respect between captain and crew.'),
(@sailor_id,'Fairness. We all do the work, so we all share in the rewards.'),
(@sailor_id,'Freedom. The sea is freedom — the freedom to go anywhere and do anything.'),
(@sailor_id,'Mastery. I''m a predator, and the other ships on the sea are my prey.'),
(@sailor_id,'People. I''m committed to my crewmates, not to ideals.'),
(@sailor_id,'Aspiration. Someday I''ll own my own ship and chart my own destiny.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@sailor_id,'I''m loyal to my captain first, everything else second.'),
(@sailor_id,'The ship is most important — crewmates and captains come and go.'),
(@sailor_id,'I''ll always remember my first ship.'),
(@sailor_id,'In a harbor town, I have a paramour whose eyes nearly stole me from the sea.'),
(@sailor_id,'I was cheated out of my fair share of the profits, and I want to get my due.'),
(@sailor_id,'Ruthless pirates murdered my captain and crewmates, plundered our ship, and left me to die. Vengeance will be mine.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@sailor_id,'I follow orders, even if I think they''re wrong.'),
(@sailor_id,'I''ll say anything to avoid having to do extra work.'),
(@sailor_id,'Once someone questions my courage, I never back down no matter how dangerous the situation.'),
(@sailor_id,'Once I start drinking, it''s hard for me to stop.'),
(@sailor_id,'I can''t help but pocket loose coins and other trinkets I come across.'),
(@sailor_id,'My pride will probably lead to my destruction.');

-- ── Soldier ───────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('soldier','Soldier',0,'Military Rank',
 'You have a military rank from your career as a soldier. Soldiers loyal to your former military organization still recognize your authority and influence, and they defer to you if they are of a lower rank. You can invoke your rank to exert influence over other soldiers and requisition simple equipment or horses for temporary use. You can also usually gain access to friendly military encampments and fortresses where your rank is recognized.',
 'War has been your life for as long as you care to remember. You trained as a youth, studied the use of weapons and armor, learned basic survival techniques, including how to stay alive on the battlefield. You might have been part of a standing national army or a mercenary company, or perhaps a member of a local militia who rose to prominence during a recent war. When the fighting is over, soldiers typically find it difficult to leave the life of combat behind.');

SET @soldier_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@soldier_id,'skill-athletics'),(@soldier_id,'skill-intimidation');
INSERT INTO background_tool_proficiencies VALUES (@soldier_id,'One type of gaming set'),(@soldier_id,'Vehicles (land)');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@soldier_id,'I''m always polite and respectful.'),
(@soldier_id,'I''m haunted by memories of war. I wake up screaming at the terrors of my past.'),
(@soldier_id,'I''ve lost too many friends, and I''m slow to make new ones.'),
(@soldier_id,'I''m full of inspiring and cautionary tales from my military experience relevant to almost every combat situation.'),
(@soldier_id,'I can stare down a hell hound without flinching.'),
(@soldier_id,'I enjoy being strong and like breaking things.'),
(@soldier_id,'I have a crude sense of humor.'),
(@soldier_id,'I face problems head-on. A simple, direct solution is the best path to success.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@soldier_id,'Greater Good. Our lot is to lay down our lives in defense of others.'),
(@soldier_id,'Responsibility. I do what I must and obey just authority.'),
(@soldier_id,'Independence. When people follow orders blindly, they embrace a kind of tyranny.'),
(@soldier_id,'Might. In life as in war, the stronger force wins.'),
(@soldier_id,'Live and Let Live. Ideals aren''t worth killing over or going to war for.'),
(@soldier_id,'Nation. My city, nation, or people are all that matter.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@soldier_id,'I would still lay down my life for the people I served with.'),
(@soldier_id,'Someone saved my life on the battlefield. To this day, I will never leave a friend behind.'),
(@soldier_id,'My honor is my life.'),
(@soldier_id,'I''ll never forget the crushing defeat my company suffered or the enemies who dealt it.'),
(@soldier_id,'Those who fight beside me are those worth dying for.'),
(@soldier_id,'I fight for those who cannot fight for themselves.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@soldier_id,'The monstrous enemy we faced in battle still leaves me quivering with fear.'),
(@soldier_id,'I have little respect for anyone who is not a proven warrior.'),
(@soldier_id,'I made a terrible mistake in battle that cost many lives, and I would do anything to keep that mistake secret.'),
(@soldier_id,'My hatred of my enemies is blinding and unreasoning.'),
(@soldier_id,'I obey the law, even if the law causes misery.'),
(@soldier_id,'I''d rather eat my armor than admit when I''m wrong.');

-- ── Urchin ────────────────────────────────────────────────────────────────────
INSERT INTO backgrounds (index_name, name, language_options, feature, feature_description, description) VALUES
('urchin','Urchin',0,'City Secrets',
 'You know the secret patterns and flow to cities and can find passages through the urban sprawl that others would miss. When you are not in combat, you (and companions you lead) can travel between any two locations in the city twice as fast as your speed would normally allow.',
 'You grew up on the streets alone, orphaned, and poor. You had no one to watch over you or to provide for you, so you learned to provide for yourself. You fought fiercely over food and kept a constant watch out for other desperate souls who might take what you had. You slept on rooftops and in alleyways, exposed to the elements, and endured sickness without the advantage of medicine or a place to recuperate. You''ve survived despite all odds, and did so through cunning, strength, or speed. You begin your adventuring career with enough money to live modestly but securely for at least ten days. How did you come by that money? What allowed you to break free of your desperate circumstances and embark on a better life?');

SET @urchin_id = LAST_INSERT_ID();
INSERT INTO background_skill_proficiencies VALUES (@urchin_id,'skill-sleight-of-hand'),(@urchin_id,'skill-stealth');
INSERT INTO background_tool_proficiencies VALUES (@urchin_id,'Disguise kit'),(@urchin_id,'Thieves'' tools');

INSERT INTO background_personality_traits (background_id,trait) VALUES
(@urchin_id,'I hide scraps of food and trinkets away in my pockets.'),
(@urchin_id,'I ask a lot of questions.'),
(@urchin_id,'I like to squeeze into small places where no one else can get to me.'),
(@urchin_id,'I sleep with my back to a wall or tree, with everything I own wrapped in a bundle in my arms.'),
(@urchin_id,'I eat like a pig and have bad manners.'),
(@urchin_id,'I think anyone who''s nice to me is hiding evil intent.'),
(@urchin_id,'I don''t like to bathe.'),
(@urchin_id,'I bluntly say what other people are hinting at or dancing around.');
INSERT INTO background_ideals (background_id,ideal) VALUES
(@urchin_id,'Respect. All people, rich or poor, deserve respect.'),
(@urchin_id,'Community. We have to take care of each other, because no one else is going to do it.'),
(@urchin_id,'Change. The low are lifted up, and the high and mighty are brought down. Change is the nature of things.'),
(@urchin_id,'Retribution. The rich need to be shown what life and death are like in the gutters.'),
(@urchin_id,'People. I help the people who help me — that''s what keeps us alive.'),
(@urchin_id,'Aspiration. I''m going to prove that I''m worthy of a better life.');
INSERT INTO background_bonds (background_id,bond) VALUES
(@urchin_id,'My town or city is my home, and I''ll fight to defend it.'),
(@urchin_id,'I sponsor an orphanage to keep others from enduring what I was forced to endure.'),
(@urchin_id,'I owe my survival to another urchin who taught me to live on the streets.'),
(@urchin_id,'I owe a debt I can never repay to the person who took pity on me.'),
(@urchin_id,'I escaped my life of poverty by robbing an important person, and I''m wanted for it.'),
(@urchin_id,'No one else should have to suffer the way I did.');
INSERT INTO background_flaws (background_id,flaw) VALUES
(@urchin_id,'If I''m outnumbered, I will run away from a fight.'),
(@urchin_id,'Gold seems like a lot of money to me, and I''ll do just about anything for more of it.'),
(@urchin_id,'I will never fully trust anyone other than myself.'),
(@urchin_id,'I''d rather kill someone in their sleep than fight fair.'),
(@urchin_id,'It''s not stealing if I need it more than someone else.'),
(@urchin_id,'People who can''t take care of themselves get what they deserve.');
