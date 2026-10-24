"""Genera assets/esercizi.json: selezione in italiano di free-exercise-db.

Uso:  python tool/genera_esercizi.py percorso/exercises.json
Il file exercises.json si scarica da
https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json
(free-exercise-db, licenza Unlicense).

Attrezzi: "" = corpo libero; "a+b" = servono entrambi; "a|b" = basta uno dei due gruppi.
"""
import json
import sys

# Muscoli di free-exercise-db -> muscoli della mappa (lib/muscoli_dati.dart).
MUSCOLI = {
    'abdominals': ['abs', 'obliques'], 'abductors': ['gluteal'], 'adductors': ['adductors'],
    'biceps': ['biceps'], 'calves': ['calves'], 'chest': ['chest'], 'forearms': ['forearm'],
    'glutes': ['gluteal'], 'hamstrings': ['hamstring'], 'lats': ['upper-back'],
    'lower back': ['lower-back'], 'middle back': ['upper-back'], 'neck': ['neck'],
    'quadriceps': ['quadriceps'], 'shoulders': ['deltoids'], 'traps': ['trapezius'],
    'triceps': ['triceps'],
}
LIVELLI = {'beginner': 'principiante', 'intermediate': 'intermedio', 'expert': 'avanzato'}
MOBILITA = {'mobilita', 'rullo'}

# (id, nome, attrezzi, schema, istruzioni)
E = [
    # --- Corpo libero
    ('Pushups', 'Piegamenti sulle braccia', '', 'spinta_orizzontale', [
        'Mani a terra poco più larghe delle spalle, corpo dritto dalla testa ai talloni.',
        'Scendi piegando i gomiti a circa 45° finché il petto sfiora il pavimento.',
        'Spingi per tornare su, senza far cedere il bacino.']),
    ('Incline_Push-Up', 'Piegamenti con mani rialzate', '', 'spinta_orizzontale', [
        'Appoggia le mani su un rialzo stabile (panca, sedia, gradino), alla larghezza delle spalle.',
        'Con il corpo dritto, scendi fino a sfiorare il bordo con il petto.',
        'Spingi per tornare su. Più il rialzo è alto, più l\'esercizio è facile.']),
    ('Push-Ups_With_Feet_Elevated', 'Piegamenti con piedi rialzati', '', 'spinta_orizzontale', [
        'Piedi su un rialzo, mani a terra poco più larghe delle spalle.',
        'Mantieni il corpo dritto e scendi fino a sfiorare il pavimento con il petto.',
        'Spingi per tornare su: lavorano di più la parte alta del petto e le spalle.']),
    ('Push-Ups_-_Close_Triceps_Position', 'Piegamenti a presa stretta', '', 'spinta_orizzontale', [
        'Mani sotto il petto, vicine tra loro.',
        'Scendi tenendo i gomiti stretti lungo il corpo.',
        'Spingi per tornare su: lavorano soprattutto i tricipiti.']),
    ('Push-Up_Wide', 'Piegamenti a presa larga', '', 'spinta_orizzontale', [
        'Mani molto più larghe delle spalle, corpo dritto.',
        'Scendi finché il petto sfiora il pavimento.',
        'Spingi per tornare su: lavora di più il petto.']),
    ('Push_Up_to_Side_Plank', 'Piegamento con plank laterale', '', 'spinta_orizzontale', [
        'Esegui un piegamento.',
        'Risalendo, ruota su un fianco e porta il braccio libero verso il soffitto.',
        'Torna in posizione di piegamento e ripeti ruotando dall\'altro lato.']),
    ('Bench_Dips', 'Dip su panca', '', 'braccia', [
        'Mani sul bordo di una panca o di una sedia stabile alle tue spalle, gambe distese davanti.',
        'Scendi piegando i gomiti fino a circa 90°, con la schiena vicina alla panca.',
        'Spingi con i tricipiti per tornare su. Piega le ginocchia per renderlo più facile.']),
    ('Dips_-_Triceps_Version', 'Dip alle parallele', 'parallele', 'spinta_verticale', [
        'Sostieniti sulle parallele a braccia tese, busto dritto.',
        'Scendi piegando i gomiti fino a circa 90°, tenendoli vicini al corpo.',
        'Spingi per tornare su a braccia tese.']),
    ('Pullups', 'Trazioni alla sbarra', 'sbarra', 'trazione_verticale', [
        'Afferra la sbarra con i palmi in avanti, poco più larghi delle spalle, e resta appeso a braccia tese.',
        'Tira portando il petto verso la sbarra finché il mento la supera.',
        'Scendi lentamente fino a braccia tese.']),
    ('Chin-Up', 'Trazioni a presa supina', 'sbarra', 'trazione_verticale', [
        'Afferra la sbarra con i palmi verso di te, alla larghezza delle spalle.',
        'Tira finché il mento supera la sbarra, gomiti vicini al corpo.',
        'Scendi lentamente: lavorano di più i bicipiti.']),
    ('Band_Assisted_Pull-Up', 'Trazioni assistite con elastico', 'sbarra+elastici', 'trazione_verticale', [
        'Aggancia un elastico alla sbarra e appoggia un piede o un ginocchio nell\'anello.',
        'Afferra la sbarra e tira finché il mento la supera: l\'elastico ti aiuta nella parte bassa.',
        'Scendi lentamente. Usa elastici più leggeri man mano che migliori.']),
    ('Scapular_Pull-Up', 'Trazioni scapolari', 'sbarra', 'trazione_verticale', [
        'Resta appeso alla sbarra a braccia tese, palmi in avanti.',
        'Senza piegare i gomiti, abbassa le spalle allontanandole dalle orecchie: il corpo sale di pochi centimetri.',
        'Fai una breve pausa e torna giù lentamente.']),
    ('Inverted_Row', 'Rematore inverso', 'sbarra', 'trazione_orizzontale', [
        'Posiziona una sbarra all\'altezza della vita e mettiti sotto, presa più larga delle spalle.',
        'Corpo dritto, talloni a terra, braccia tese.',
        'Tira il petto verso la sbarra stringendo le scapole, poi scendi lentamente.']),
    ('Suspended_Row', 'Rematore agli anelli o TRX', 'trx', 'trazione_orizzontale', [
        'Afferra le maniglie e inclinati all\'indietro con il corpo dritto e le braccia tese.',
        'Tira il petto verso le mani stringendo le scapole.',
        'Torna giù lentamente. Più sei inclinato, più è difficile.']),
    ('Suspended_Push-Up', 'Piegamenti agli anelli o TRX', 'trx', 'spinta_orizzontale', [
        'Regola le maniglie a pochi centimetri da terra e mettiti in posizione di piegamento con le mani sulle maniglie.',
        'Scendi controllando le maniglie, che non devono allargarsi.',
        'Spingi per tornare su.']),
    ('Bodyweight_Squat', 'Squat a corpo libero', '', 'squat', [
        'Piedi alla larghezza delle spalle, punte leggermente in fuori.',
        'Scendi spingendo indietro il bacino e piegando le ginocchia, petto alto e talloni a terra.',
        'Arriva almeno con le cosce parallele al pavimento e risali spingendo sui talloni.']),
    ('Freehand_Jump_Squat', 'Squat jump', '', 'pliometria', [
        'Parti in posizione di squat, piedi alla larghezza delle spalle.',
        'Spingi con forza e salta più in alto che puoi.',
        'Atterra morbido sulle punte e scendi subito nello squat successivo.']),
    ('Bodyweight_Walking_Lunge', 'Affondi camminati', '', 'affondo', [
        'In piedi, fai un passo lungo in avanti.',
        'Scendi finché il ginocchio posteriore sfiora il pavimento, busto dritto.',
        'Spingi sulla gamba anteriore e porta avanti l\'altra gamba nel passo successivo.']),
    ('Step-up_with_Knee_Raise', 'Step-up con ginocchio al petto', 'rialzo|panca', 'affondo', [
        'Di fronte a un box o a una panca, sali appoggiando un piede sopra.',
        'Distendi la gamba e porta il ginocchio dell\'altra gamba verso il petto.',
        'Scendi controllando il movimento e alterna le gambe.']),
    ('Butt_Lift_Bridge', 'Ponte glutei', '', 'cerniera', [
        'Sdraiato sulla schiena, ginocchia piegate e piedi a terra vicino ai glutei.',
        'Spingi sui talloni e solleva il bacino finché il corpo forma una linea dalle spalle alle ginocchia.',
        'Stringi i glutei in alto per un secondo e scendi lentamente.']),
    ('Single_Leg_Glute_Bridge', 'Ponte glutei su una gamba', '', 'cerniera', [
        'Sdraiato sulla schiena, un piede a terra e l\'altra gamba distesa in aria.',
        'Spingi sul tallone a terra e solleva il bacino.',
        'Scendi lentamente; completa le ripetizioni e cambia gamba.']),
    ('Glute_Kickback', 'Slanci posteriori a quattro zampe', '', 'cerniera', [
        'A quattro zampe, mani sotto le spalle e ginocchia sotto le anche.',
        'Spingi una gamba indietro e in alto, ginocchio piegato a 90°, finché la coscia è in linea con il busto.',
        'Torna giù lentamente senza inarcare la schiena, poi cambia gamba.']),
    ('Superman', 'Superman', '', 'core', [
        'A pancia in giù, braccia distese in avanti.',
        'Solleva insieme braccia, petto e gambe da terra.',
        'Tieni 2 secondi stringendo glutei e lombari, poi scendi lentamente.']),
    ('Plank', 'Plank', '', 'core', [
        'Avambracci a terra con i gomiti sotto le spalle, punte dei piedi a terra.',
        'Corpo dritto dalla testa ai talloni, addome e glutei contratti.',
        'Mantieni la posizione senza far scendere o salire il bacino.']),
    ('Side_Bridge', 'Plank laterale', '', 'core', [
        'Sul fianco, appoggiato sull\'avambraccio con il gomito sotto la spalla.',
        'Solleva il bacino finché il corpo è dritto dalla testa ai piedi.',
        'Mantieni la posizione, poi cambia lato.']),
    ('Dead_Bug', 'Dead bug', '', 'core', [
        'Sdraiato sulla schiena, braccia verso il soffitto e ginocchia piegate a 90° sopra le anche.',
        'Distendi un braccio dietro la testa e la gamba opposta in avanti, senza staccare la zona lombare da terra.',
        'Torna al centro e alterna i lati.']),
    ('Crunches', 'Crunch', '', 'core', [
        'Sdraiato sulla schiena, ginocchia piegate, mani ai lati della testa.',
        'Solleva le spalle da terra contraendo l\'addome, senza tirare il collo.',
        'Torna giù lentamente.']),
    ('Reverse_Crunch', 'Crunch inverso', '', 'core', [
        'Sdraiato sulla schiena, braccia lungo i fianchi, ginocchia piegate sopra le anche.',
        'Contrai l\'addome e porta le ginocchia verso il petto staccando il bacino da terra.',
        'Torna giù lentamente senza far cadere le gambe.']),
    ('Russian_Twist', 'Russian twist', '', 'core', [
        'Seduto con le ginocchia piegate, busto inclinato indietro e piedi sollevati (a terra per renderlo più facile).',
        'Ruota il busto da un lato portando le mani verso il pavimento.',
        'Ruota dall\'altro lato. Per aumentare la difficoltà tieni un disco o una palla medica.']),
    ('Air_Bike', 'Bicycle crunch', '', 'core', [
        'Sdraiato sulla schiena, mani ai lati della testa, spalle sollevate da terra.',
        'Porta un ginocchio verso il petto e avvicina il gomito opposto, distendendo l\'altra gamba.',
        'Alterna i lati con un movimento continuo, come pedalando.']),
    ('Flutter_Kicks', 'Sforbiciate', '', 'core', [
        'Sdraiato sulla schiena, mani sotto i glutei, gambe distese e sollevate di pochi centimetri.',
        'Muovi le gambe su e giù alternandole, con movimenti piccoli e rapidi.',
        'Tieni la zona lombare a contatto con il pavimento.']),
    ('Mountain_Climbers', 'Mountain climber', '', 'pliometria', [
        'Mettiti in posizione di piegamento a braccia tese.',
        'Porta un ginocchio verso il petto e riportalo indietro mentre porti avanti l\'altro.',
        'Alterna le gambe velocemente, senza alzare troppo il bacino.']),
    ('Star_Jump', 'Star jump', '', 'pliometria', [
        'Parti accosciato con le mani vicino alle ginocchia.',
        'Salta in alto aprendo braccia e gambe a stella.',
        'Atterra morbido richiudendo braccia e gambe e torna accosciato.']),
    ('Split_Jump', 'Affondi saltati', '', 'pliometria', [
        'Parti in posizione di affondo.',
        'Salta in alto e scambia le gambe in aria.',
        'Atterra morbido nell\'affondo opposto e ripeti.']),
    ('Knee_Tuck_Jump', 'Salti con ginocchia al petto', '', 'pliometria', [
        'In piedi, piedi alla larghezza delle spalle.',
        'Salta portando le ginocchia verso il petto.',
        'Atterra morbido sulle punte e ripeti subito.']),
    ('Front_Box_Jump', 'Box jump', 'rialzo', 'pliometria', [
        'Di fronte a un box stabile, piedi alla larghezza delle spalle.',
        'Piegati leggermente e salta sul box, atterrando con entrambi i piedi e le ginocchia morbide.',
        'Scendi con un passo, senza saltare all\'indietro.']),
    # --- Manubri
    ('Dumbbell_Bench_Press', 'Distensioni con manubri su panca', 'manubri+panca', 'spinta_orizzontale', [
        'Sdraiato sulla panca, manubri all\'altezza del petto, palmi in avanti.',
        'Spingi i manubri verso l\'alto fino a braccia tese.',
        'Scendi lentamente fino a sentire un leggero allungamento del petto.']),
    ('Dumbbell_Flyes', 'Croci con manubri', 'manubri+panca', 'spinta_orizzontale', [
        'Sdraiato sulla panca, manubri sopra il petto con i palmi uno di fronte all\'altro e i gomiti appena piegati.',
        'Apri le braccia ad arco finché senti allungare il petto.',
        'Richiudi lo stesso arco fino a sopra il petto.']),
    ('Dumbbell_Shoulder_Press', 'Lento avanti con manubri', 'manubri', 'spinta_verticale', [
        'In piedi o seduto, manubri all\'altezza delle spalle, palmi in avanti.',
        'Spingi i manubri sopra la testa fino a braccia tese.',
        'Scendi lentamente all\'altezza delle spalle.']),
    ('Arnold_Dumbbell_Press', 'Arnold press', 'manubri', 'spinta_verticale', [
        'In piedi o seduto, manubri davanti al petto con i palmi verso di te.',
        'Spingi verso l\'alto ruotando i polsi, finché i palmi guardano in avanti a braccia tese.',
        'Torna giù invertendo la rotazione.']),
    ('Side_Lateral_Raise', 'Alzate laterali', 'manubri', 'spalle', [
        'In piedi, manubri lungo i fianchi, gomiti leggermente piegati.',
        'Solleva le braccia di lato fino all\'altezza delle spalle.',
        'Scendi lentamente senza dondolare con il busto.']),
    ('Front_Dumbbell_Raise', 'Alzate frontali', 'manubri', 'spalle', [
        'In piedi, manubri davanti alle cosce, palmi verso il corpo.',
        'Solleva un braccio davanti a te fino all\'altezza delle spalle.',
        'Scendi lentamente e alterna le braccia.']),
    ('Reverse_Flyes', 'Alzate posteriori a busto flesso', 'manubri', 'spalle', [
        'Busto inclinato in avanti con la schiena dritta, manubri sotto il petto.',
        'Apri le braccia di lato fino all\'altezza delle spalle, stringendo le scapole.',
        'Scendi lentamente.']),
    ('One-Arm_Dumbbell_Row', 'Rematore con manubrio a un braccio', 'manubri', 'trazione_orizzontale', [
        'Una mano e un ginocchio su una panca o una sedia, schiena parallela al pavimento.',
        'Con l\'altra mano tira il manubrio verso il fianco, gomito vicino al corpo.',
        'Scendi lentamente a braccio teso, poi cambia lato.']),
    ('Bent_Over_Two-Dumbbell_Row', 'Rematore con due manubri', 'manubri', 'trazione_orizzontale', [
        'Ginocchia leggermente piegate, busto inclinato in avanti con la schiena dritta.',
        'Tira i manubri verso i fianchi stringendo le scapole.',
        'Scendi lentamente a braccia tese.']),
    ('Dumbbell_Bicep_Curl', 'Curl con manubri', 'manubri', 'braccia', [
        'In piedi, manubri lungo i fianchi con i palmi in avanti.',
        'Piega i gomiti portando i manubri verso le spalle, gomiti fermi lungo il corpo.',
        'Scendi lentamente.']),
    ('Hammer_Curls', 'Curl a martello', 'manubri', 'braccia', [
        'In piedi, manubri lungo i fianchi con i palmi rivolti verso il corpo.',
        'Piega i gomiti mantenendo i palmi uno di fronte all\'altro.',
        'Scendi lentamente.']),
    ('Tricep_Dumbbell_Kickback', 'Kickback per tricipiti', 'manubri', 'braccia', [
        'Busto inclinato in avanti, gomito piegato a 90° e braccio parallelo al busto.',
        'Distendi il gomito portando il manubrio indietro, senza muovere il braccio.',
        'Torna lentamente a 90°.']),
    ('Standing_Dumbbell_Triceps_Extension', 'French press in piedi con manubrio', 'manubri', 'braccia', [
        'In piedi, tieni un manubrio con due mani sopra la testa, braccia tese.',
        'Piega i gomiti portando il manubrio dietro la testa, gomiti verso l\'alto.',
        'Distendi le braccia per tornare su.']),
    ('Goblet_Squat', 'Goblet squat', 'kettlebell|manubri|dischi', 'squat', [
        'Tieni un kettlebell, un manubrio o un disco davanti al petto con due mani.',
        'Scendi nello squat con il petto alto e i gomiti tra le ginocchia.',
        'Risali spingendo sui talloni.']),
    ('Dumbbell_Squat', 'Squat con manubri', 'manubri', 'squat', [
        'In piedi, un manubrio per mano lungo i fianchi.',
        'Scendi nello squat con la schiena dritta, fino alle cosce parallele al pavimento.',
        'Risali spingendo sui talloni.']),
    ('Dumbbell_Lunges', 'Affondi con manubri', 'manubri', 'affondo', [
        'In piedi, un manubrio per mano lungo i fianchi.',
        'Fai un passo in avanti e scendi finché il ginocchio posteriore sfiora il pavimento.',
        'Spingi sulla gamba anteriore per tornare in piedi e alterna.']),
    ('Dumbbell_Rear_Lunge', 'Affondi indietro con manubri', 'manubri', 'affondo', [
        'In piedi, un manubrio per mano.',
        'Fai un passo indietro e scendi finché il ginocchio posteriore sfiora il pavimento.',
        'Torna in piedi spingendo sulla gamba anteriore e alterna.']),
    ('Split_Squat_with_Dumbbells', 'Split squat con manubri', 'manubri', 'affondo', [
        'Un piede avanti e uno indietro, un manubrio per mano.',
        'Scendi in verticale finché il ginocchio posteriore sfiora il pavimento.',
        'Risali e completa le ripetizioni prima di cambiare gamba.']),
    ('Dumbbell_Step_Ups', 'Step-up con manubri', 'manubri+rialzo|manubri+panca', 'affondo', [
        'Un manubrio per mano, di fronte a un box o a una panca.',
        'Sali appoggiando un piede sopra e distendi la gamba fino a stare in piedi sul rialzo.',
        'Scendi controllando il movimento e alterna le gambe.']),
    ('Stiff-Legged_Dumbbell_Deadlift', 'Stacco a gambe tese con manubri', 'manubri', 'cerniera', [
        'In piedi, manubri davanti alle cosce, ginocchia appena piegate.',
        'Spingi indietro il bacino e scendi con la schiena dritta finché senti allungare i femorali.',
        'Risali spingendo il bacino in avanti e stringendo i glutei.']),
    ('Dumbbell_Shrug', 'Scrollate con manubri', 'manubri', 'spalle', [
        'In piedi, manubri lungo i fianchi.',
        'Solleva le spalle verso le orecchie senza piegare i gomiti.',
        'Tieni un secondo e scendi lentamente.']),
    ('Standing_Dumbbell_Calf_Raise', 'Calf raise con manubri', 'manubri', 'polpacci', [
        'In piedi, un manubrio per mano; meglio con le punte su un gradino.',
        'Sali sulle punte il più in alto possibile.',
        'Scendi lentamente fino a sentire allungare i polpacci.']),
    ('Dumbbell_Side_Bend', 'Flessioni laterali con manubrio', 'manubri', 'core', [
        'In piedi, un manubrio in una mano lungo il fianco.',
        'Piegati di lato verso il manubrio, poi risali contraendo il fianco opposto.',
        'Completa le ripetizioni e cambia lato.']),
    # --- Kettlebell
    ('One-Arm_Kettlebell_Swings', 'Swing con kettlebell a un braccio', 'kettlebell', 'cerniera', [
        'Kettlebell tra i piedi, piedi poco più larghi delle spalle.',
        'Spingi indietro il bacino, porta il kettlebell tra le gambe, poi distendi le anche con forza.',
        'Il kettlebell sale fino al petto grazie alla spinta delle anche, non delle braccia.']),
    ('Kettlebell_One-Legged_Deadlift', 'Stacco su una gamba con kettlebell', 'kettlebell|manubri', 'cerniera', [
        'In piedi su una gamba, kettlebell nella mano opposta.',
        'Inclinati in avanti con la schiena dritta mentre l\'altra gamba si alza dietro di te.',
        'Torna in piedi stringendo il gluteo, poi cambia gamba.']),
    ('Kettlebell_Turkish_Get-Up_Squat_style', 'Turkish get-up', 'kettlebell|manubri', 'total_body', [
        'Sdraiato, kettlebell a braccio teso sopra di te, ginocchio dello stesso lato piegato.',
        'Senza mai piegare il braccio, sollevati sul gomito, poi sulla mano, porta la gamba sotto e alzati in piedi.',
        'Ripercorri i passaggi al contrario per tornare a terra. Inizia con un peso leggero.']),
    ('One-Arm_Kettlebell_Row', 'Rematore con kettlebell', 'kettlebell', 'trazione_orizzontale', [
        'Busto inclinato in avanti con la schiena dritta, kettlebell in una mano.',
        'Tira il kettlebell verso il fianco, gomito vicino al corpo.',
        'Scendi lentamente, poi cambia lato.']),
    ('One-Arm_Kettlebell_Military_Press_To_The_Side', 'Lento con kettlebell a un braccio', 'kettlebell', 'spinta_verticale', [
        'Porta il kettlebell alla spalla con un clean, palmo verso l\'interno.',
        'Spingilo sopra la testa fino a braccio teso, seguendolo con lo sguardo.',
        'Riportalo lentamente alla spalla, poi cambia lato.']),
    ('One-Arm_Kettlebell_Clean', 'Clean con kettlebell a un braccio', 'kettlebell', 'total_body', [
        'Kettlebell tra i piedi: piegati spingendo indietro il bacino e afferralo con una mano.',
        'Distendi gambe e anche con forza e porta il kettlebell alla spalla ruotando il polso.',
        'Riportalo a terra controllando, poi cambia lato.']),
    ('Kettlebell_Windmill', 'Windmill con kettlebell', 'kettlebell', 'core', [
        'Kettlebell sopra la testa a braccio teso, piedi più larghi delle spalle.',
        'Guardando il kettlebell, spingi il bacino di lato e scendi con la mano libera verso il piede opposto.',
        'Risali con il braccio sempre teso, poi cambia lato.']),
    ('Kettlebell_Thruster', 'Thruster con kettlebell', 'kettlebell', 'total_body', [
        'Kettlebell all\'altezza delle spalle (uno o due).',
        'Scendi nello squat con il petto alto.',
        'Risalendo con forza, spingi il kettlebell sopra la testa nello stesso movimento.']),
    ('Kettlebell_Sumo_High_Pull', 'Tirata alta sumo con kettlebell', 'kettlebell', 'total_body', [
        'Piedi molto larghi, kettlebell a terra tra i piedi, afferrato con due mani.',
        'Distendi gambe e anche e tira il kettlebell fino al petto, gomiti alti.',
        'Riabbassalo controllando.']),
    ('Kettlebell_Figure_8', 'Otto con kettlebell', 'kettlebell', 'core', [
        'Piedi larghi, busto inclinato con la schiena dritta, kettlebell in una mano.',
        'Passa il kettlebell all\'altra mano tra le gambe: la mano lo riceve da dietro.',
        'Continua disegnando un otto attorno alle gambe.']),
    # --- Bilanciere
    ('Barbell_Squat', 'Squat con bilanciere', 'bilanciere', 'squat', [
        'Bilanciere sulla parte alta della schiena (meglio partendo da un rack), piedi alla larghezza delle spalle.',
        'Scendi spingendo indietro il bacino, petto alto, fino alle cosce parallele al pavimento.',
        'Risali spingendo sui talloni.']),
    ('Barbell_Deadlift', 'Stacco da terra', 'bilanciere', 'cerniera', [
        'Bilanciere a terra sopra la metà del piede: afferralo appena fuori dalle gambe.',
        'Schiena dritta e petto alto, solleva distendendo insieme gambe e anche, con il bilanciere vicino alle gambe.',
        'Riportalo a terra con lo stesso percorso.']),
    ('Romanian_Deadlift', 'Stacco rumeno', 'bilanciere', 'cerniera', [
        'In piedi con il bilanciere davanti alle cosce, ginocchia appena piegate.',
        'Spingi indietro il bacino e scendi con la schiena dritta fino a metà tibia.',
        'Risali stringendo i glutei.']),
    ('Barbell_Bench_Press_-_Medium_Grip', 'Panca piana con bilanciere', 'bilanciere+panca', 'spinta_orizzontale', [
        'Sdraiato sulla panca, presa poco più larga delle spalle.',
        'Scendi con il bilanciere fino a sfiorare il petto, gomiti a circa 45°.',
        'Spingi fino a braccia tese. Con carichi alti fatti assistere.']),
    ('Bent_Over_Barbell_Row', 'Rematore con bilanciere', 'bilanciere', 'trazione_orizzontale', [
        'Ginocchia leggermente piegate, busto inclinato in avanti con la schiena dritta.',
        'Tira il bilanciere verso l\'addome stringendo le scapole.',
        'Scendi lentamente a braccia tese.']),
    ('Standing_Military_Press', 'Lento in piedi con bilanciere', 'bilanciere', 'spinta_verticale', [
        'In piedi, bilanciere all\'altezza delle spalle, presa poco più larga delle spalle.',
        'Spingi il bilanciere sopra la testa fino a braccia tese, addome contratto.',
        'Scendi lentamente alle spalle.']),
    ('Barbell_Curl', 'Curl con bilanciere', 'bilanciere', 'braccia', [
        'In piedi, bilanciere davanti alle cosce con i palmi in avanti.',
        'Piega i gomiti portando il bilanciere verso le spalle, gomiti fermi.',
        'Scendi lentamente.']),
    ('Barbell_Lunge', 'Affondi con bilanciere', 'bilanciere', 'affondo', [
        'Bilanciere sulla parte alta della schiena.',
        'Fai un passo in avanti e scendi finché il ginocchio posteriore sfiora il pavimento.',
        'Torna in piedi e alterna le gambe.']),
    # --- Dischi (anche senza bilanciere)
    ('Front_Plate_Raise', 'Alzata frontale con disco', 'dischi', 'spalle', [
        'In piedi, tieni un disco con due mani davanti alle cosce, braccia quasi tese.',
        'Solleva il disco davanti a te fino all\'altezza degli occhi.',
        'Scendi lentamente.']),
    ('Plate_Twist', 'Rotazioni del busto con disco', 'dischi', 'core', [
        'Seduto, busto inclinato indietro, gambe sollevate e leggermente piegate, disco davanti all\'addome.',
        'Ruota il busto portando il disco da un lato.',
        'Ruota dall\'altro lato con un movimento controllato.']),
    ('Weighted_Crunches', 'Crunch con sovraccarico', 'palla_medica|dischi|manubri', 'core', [
        'Sdraiato sulla schiena, ginocchia piegate, tieni un peso sul petto.',
        'Solleva le spalle da terra contraendo l\'addome.',
        'Torna giù lentamente.']),
    # --- Elastici
    ('Band_Pull_Apart', 'Pull apart con elastico', 'elastici', 'spalle', [
        'In piedi, tieni l\'elastico davanti a te a braccia tese, all\'altezza delle spalle.',
        'Apri le braccia tirando l\'elastico fino al petto, stringendo le scapole.',
        'Torna lentamente alla posizione iniziale.']),
    ('External_Rotation_with_Band', 'Extrarotazione con elastico', 'elastici', 'spalle', [
        'Fissa l\'elastico all\'altezza del gomito e mettiti di fianco.',
        'Con il gomito piegato a 90° e fermo contro il fianco, ruota l\'avambraccio verso l\'esterno.',
        'Torna lentamente, poi cambia lato. Utile per proteggere le spalle, anche nel nuoto.']),
    ('Lateral_Raise_-_With_Bands', 'Alzate laterali con elastico', 'elastici', 'spalle', [
        'In piedi sull\'elastico, impugnature ai lati delle cosce.',
        'Solleva le braccia di lato fino all\'altezza delle spalle, gomiti leggermente piegati.',
        'Scendi lentamente.']),
    ('Shoulder_Press_-_With_Bands', 'Lento avanti con elastico', 'elastici', 'spinta_verticale', [
        'In piedi sull\'elastico, impugnature all\'altezza delle spalle, palmi in avanti.',
        'Spingi sopra la testa fino a braccia tese.',
        'Scendi lentamente.']),
    ('Back_Flyes_-_With_Bands', 'Alzate posteriori con elastico', 'elastici', 'spalle', [
        'Fissa l\'elastico davanti a te all\'altezza delle spalle e afferralo a braccia tese.',
        'Apri le braccia di lato tenendole tese, stringendo le scapole.',
        'Torna lentamente.']),
    # --- Palla medica e fitball
    ('Overhead_Slam', 'Slam con palla medica', 'palla_medica', 'total_body', [
        'In piedi, palla medica tenuta con due mani.',
        'Portala sopra la testa distendendo tutto il corpo.',
        'Lanciala con forza a terra davanti a te e riprendila. Usa una palla che non rimbalza.']),
    ('Ball_Leg_Curl', 'Leg curl su fitball', 'fitball', 'cerniera', [
        'Sdraiato sulla schiena, talloni sulla fitball.',
        'Solleva il bacino e tira la palla verso i glutei piegando le ginocchia.',
        'Distendi lentamente le gambe tenendo il bacino sollevato.']),
    ('Exercise_Ball_Pull-In', 'Ginocchia al petto su fitball', 'fitball', 'core', [
        'In posizione di piegamento con le tibie appoggiate sulla fitball.',
        'Porta le ginocchia verso il petto facendo rotolare la palla.',
        'Distendi le gambe per tornare alla posizione iniziale.']),
    # --- Mobilità
    ('Worlds_Greatest_Stretch', 'World\'s greatest stretch', '', 'mobilita', [
        'Fai un affondo in avanti con il ginocchio posteriore vicino a terra e resta 10-20 secondi.',
        'Appoggia a terra la mano dal lato della gamba anteriore e ruota il busto portando l\'altro braccio verso il soffitto.',
        'Infine distendi la gamba anteriore portando il bacino indietro per allungare i femorali, poi cambia lato.']),
    ('Cat_Stretch', 'Allungamento del gatto', '', 'mobilita', [
        'A quattro zampe, mani sotto le spalle e ginocchia sotto le anche.',
        'Porta dentro l\'addome e incurva la schiena verso l\'alto, lasciando cadere la testa.',
        'Tieni 15 secondi, poi rilassa.']),
    ('Childs_Pose', 'Posizione del bambino', '', 'mobilita', [
        'In ginocchio, siediti sui talloni.',
        'Piegati in avanti allungando le braccia a terra davanti a te, fronte verso il pavimento.',
        'Respira lentamente e resta 20-30 secondi.']),
    ('Kneeling_Hip_Flexor', 'Allungamento dei flessori dell\'anca', '', 'mobilita', [
        'In ginocchio su un tappetino, porta un piede avanti con il ginocchio a 90°.',
        'Sposta il peso in avanti finché senti allungare la parte anteriore dell\'anca della gamba dietro.',
        'Tieni 15-30 secondi, poi cambia lato.']),
    ('Seated_Floor_Hamstring_Stretch', 'Allungamento dei femorali da seduto', '', 'mobilita', [
        'Seduto, una gamba distesa e il piede dell\'altra contro l\'interno coscia.',
        'Piegati in avanti dalle anche verso la caviglia finché senti allungare il retro della coscia.',
        'Tieni 15-30 secondi, poi cambia lato.']),
    ('Calf_Stretch_Hands_Against_Wall', 'Allungamento dei polpacci al muro', '', 'mobilita', [
        'Mani al muro, un piede avanti e uno indietro.',
        'Tieni il tallone posteriore a terra e la gamba tesa, spingendo il bacino verso il muro.',
        'Tieni 15-30 secondi, poi cambia lato.']),
    ('Standing_Soleus_And_Achilles_Stretch', 'Allungamento di soleo e tendine d\'Achille', '', 'mobilita', [
        'In piedi, un piede avanti e uno indietro, entrambi i talloni a terra.',
        'Piega entrambe le ginocchia spostando il peso sulla gamba posteriore.',
        'Senti allungare la parte bassa del polpaccio: tieni 15-30 secondi e cambia lato.']),
    ('On_Your_Side_Quad_Stretch', 'Allungamento dei quadricipiti sul fianco', '', 'mobilita', [
        'Sdraiato sul fianco, con la gamba di sotto piegata davanti a te per stabilità.',
        'Piega la gamba di sopra e afferra il piede con la mano.',
        'Spingi l\'anca in avanti e il piede contro la mano: tieni 15-30 secondi e cambia lato.']),
    ('Runners_Stretch', 'Allungamento del corridore', '', 'mobilita', [
        'Da in piedi porta una gamba indietro e scendi con le mani a terra ai lati del piede anteriore.',
        'Tieni il tallone anteriore a terra.',
        'Per aumentare l\'allungamento solleva il bacino distendendo la gamba anteriore.']),
    ('Hip_Circles_prone', 'Circonduzioni dell\'anca a quattro zampe', '', 'mobilita', [
        'A quattro zampe, solleva da terra un ginocchio piegato.',
        'Disegna con il ginocchio un cerchio ampio e lento.',
        'Fai le ripetizioni in entrambe le direzioni, poi cambia gamba.']),
    ('Pelvic_Tilt_Into_Bridge', 'Retroversione del bacino e ponte', '', 'mobilita', [
        'Sdraiato sulla schiena, piedi a terra con i talloni sotto le ginocchia.',
        'Solleva solo il coccige portando dentro l\'addome, per allungare la zona lombare.',
        'Poi solleva tutta la colonna, vertebra per vertebra, tranne il collo, e scendi lentamente.']),
    ('Spinal_Stretch', 'Torsione della colonna da seduto', '', 'mobilita', [
        'Seduto su una sedia con la schiena dritta, mani intrecciate dietro la testa.',
        'Ruota il busto da un lato il più possibile, poi dall\'altro.',
        'Ripeti 3 volte per lato con movimenti lenti.']),
    ('Upper_Back_Stretch', 'Allungamento della parte alta della schiena', '', 'mobilita', [
        'Intreccia le dita con i pollici verso il basso.',
        'Spingi le mani in avanti arrotondando le spalle.',
        'Tieni 15-20 secondi.']),
    ('Shoulder_Stretch', 'Allungamento della spalla', '', 'mobilita', [
        'Porta un braccio teso davanti al corpo, verso la spalla opposta.',
        'Con l\'altra mano tienilo vicino al petto.',
        'Tieni 15-20 secondi, poi cambia braccio.']),
    ('Triceps_Stretch', 'Allungamento dei tricipiti', '', 'mobilita', [
        'Porta una mano dietro la testa.',
        'Con l\'altra mano afferra il gomito e tiralo delicatamente.',
        'Tieni 10-20 secondi, poi cambia lato.']),
    ('Dynamic_Chest_Stretch', 'Apertura dinamica del petto', '', 'mobilita', [
        'In piedi, braccia tese davanti a te con le mani unite.',
        'Apri le braccia indietro più che puoi, tenendole tese, e richiudile.',
        'Ripeti 5-10 volte aumentando gradualmente la velocità.']),
    ('Arm_Circles', 'Circonduzioni delle braccia', '', 'mobilita', [
        'In piedi, braccia aperte di lato all\'altezza delle spalle.',
        'Disegna piccoli cerchi, allargandoli man mano.',
        'Ripeti nell\'altra direzione.']),
    ('Ankle_Circles', 'Circonduzioni delle caviglie', '', 'mobilita', [
        'Seduto o in piedi, solleva un piede da terra.',
        'Ruota lentamente la caviglia disegnando ampi cerchi.',
        'Ripeti nell\'altra direzione e cambia piede.']),
    # --- Rullo (automassaggio)
    ('Quadriceps-SMR', 'Rullo sui quadricipiti', 'rullo', 'rullo', [
        'A pancia in giù, appoggiato sugli avambracci, con il rullo sotto le cosce.',
        'Fai scorrere il rullo dall\'anca al ginocchio.',
        'Fermati 10-20 secondi sui punti più tesi.']),
    ('Calves-SMR', 'Rullo sui polpacci', 'rullo', 'rullo', [
        'Seduto, rullo sotto i polpacci e mani a terra dietro di te.',
        'Solleva il bacino e fai scorrere il rullo dalla caviglia al ginocchio.',
        'Per aumentare la pressione accavalla una gamba sull\'altra.']),
    ('Iliotibial_Tract-SMR', 'Rullo sulla bandelletta ileotibiale', 'rullo', 'rullo', [
        'Sul fianco, rullo sotto la parte esterna della coscia, appoggiato sull\'avambraccio.',
        'Fai scorrere il rullo dall\'anca al ginocchio.',
        'Usa l\'altra gamba a terra per regolare la pressione, poi cambia lato.']),
    ('Hamstring-SMR', 'Rullo sui femorali', 'rullo', 'rullo', [
        'Seduto, rullo sotto il retro delle cosce, mani a terra dietro di te.',
        'Solleva il bacino e fai scorrere il rullo dal gluteo al ginocchio.',
        'Fermati sui punti più tesi.']),
    ('Piriformis-SMR', 'Rullo sui glutei', 'rullo', 'rullo', [
        'Seduto sul rullo, accavalla una caviglia sul ginocchio opposto.',
        'Inclinati verso il lato della gamba accavallata e fai scorrere il rullo sul gluteo.',
        'Poi cambia lato.']),
    ('Rhomboids-SMR', 'Rullo sulla parte alta della schiena', 'rullo', 'rullo', [
        'Sdraiato sulla schiena, rullo sotto la parte alta della schiena e braccia incrociate davanti.',
        'Solleva il bacino e fai scorrere il rullo tra le scapole.',
        'Sposta il peso un po\' a destra e un po\' a sinistra.']),
]


def muscoli(lista):
    out = []
    for m in lista:
        for s in MUSCOLI[m]:
            if s not in out:
                out.append(s)
    return out


def main():
    db = {e['id']: e for e in json.load(open(sys.argv[1], encoding='utf-8'))}
    out = []
    visti = set()
    for id_, nome, attrezzi, schema, istruzioni in E:
        if id_ in visti:
            sys.exit('doppione: ' + id_)
        visti.add(id_)
        e = db[id_]
        primari = muscoli(e['primaryMuscles'])
        out.append({
            'id': id_,
            'nome': nome,
            'nome_en': e['name'],
            'tipo': 'mobilita' if schema in MOBILITA else 'forza',
            'schema': schema,
            'livello': LIVELLI[e['level']],
            'attrezzi': [g.split('+') for g in attrezzi.split('|')] if attrezzi else [],
            'muscoli': primari,
            'muscoli_secondari': [m for m in muscoli(e['secondaryMuscles']) if m not in primari],
            'istruzioni': istruzioni,
            'immagini': e['images'],
        })
    json.dump(out, open('assets/esercizi.json', 'w', encoding='utf-8'),
              ensure_ascii=False, indent=1)
    print(len(out), 'esercizi:', sum(e['tipo'] == 'forza' for e in out), 'forza,',
          sum(e['tipo'] == 'mobilita' for e in out), 'mobilità')


main()
