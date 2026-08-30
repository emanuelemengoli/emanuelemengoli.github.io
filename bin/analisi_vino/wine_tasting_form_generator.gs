/**
 * SCHEDA DI DEGUSTAZIONE DEL VINO — UX v11 (optimized)
 *
 * Questa versione evita il rallentamento della v8:
 * - l'esame olfattivo completo comune viene creato UNA SOLA VOLTA;
 * - solo le due sezioni realmente specifiche (evoluzione fruttata Rosso/Bianco)
 *   sono separate;
 * - Tipologia e Valutazione sono veri menu a tendina con navigazione;
 * - nessun ciclo crea copie complete della stessa sezione.
 *
 * Funzione da eseguire:
 *   createWineTastingFormUXv11()
 */

function createWineTastingFormUXv11() {
  console.log('1/8 — Creazione form');

  const form = FormApp.create('Scheda di degustazione del vino');
  form.setDescription(
    '🍷 Inserisci i dati del vino, scegli la tipologia e poi una valutazione corta o completa.'
  );
  form.setConfirmationMessage('Degustazione salvata. 🍷');
  form.setProgressBar(true);
  form.setShowLinkToRespondAgain(true);

  // ============================================================
  // 1. IDENTIFICAZIONE
  // ============================================================

  console.log('2/8 — Identificazione');

  form.addSectionHeaderItem()
    .setTitle('🍷 1. Identificazione del vino')
    .setHelpText('I dati principali sono obbligatori. Le coordinate sono facoltative.');

  addShort(form, 'Cantina / produttore', true);
  addShort(form, 'Nome del vino', true);
  addShort(form, 'Denominazione', true);
  addShort(form, 'Territorio di produzione', true);
  addShort(form, 'Annata', true, 'Sono ammessi anche valori come NV / s.a.');
  addShort(form, 'Vitigno/i', true);

  form.addDateItem()
    .setTitle('Data')
    .setRequired(true);

  const priceValidation = FormApp.createTextValidation()
    .setHelpText('Inserisci un valore numerico maggiore o uguale a 0.')
    .requireNumberGreaterThanOrEqualTo(0)
    .build();

  form.addTextItem()
    .setTitle('Prezzo')
    .setHelpText('Inserisci solo il valore numerico.')
    .setRequired(true)
    .setValidation(priceValidation);

  addShort(form, 'Regione', true);
  addShort(form, 'Stato', true);

  form.addSectionHeaderItem()
    .setTitle('📍 Coordinate per la mappa')
    .setHelpText('Facoltative. Se fornite vengono utilizzate per collocare il vino con precisione sulla mappa. In alternativa il sistema le deduce combinando produttore, regione e stato.');

  const latValidation = FormApp.createTextValidation()
    .setHelpText('Inserisci un numero compreso tra -90 e 90.')
    .requireNumberBetween(-90, 90)
    .build();

  const lngValidation = FormApp.createTextValidation()
    .setHelpText('Inserisci un numero compreso tra -180 e 180.')
    .requireNumberBetween(-180, 180)
    .build();

  form.addTextItem()
    .setTitle('Latitudine')
    .setRequired(false)
    .setValidation(latValidation);

  form.addTextItem()
    .setTitle('Longitudine')
    .setRequired(false)
    .setValidation(lngValidation);

  // Vero menu a tendina con branching.
  const typeItem = form.addListItem()
    .setTitle('Tipologia')
    .setHelpText('Scegli la tipologia del vino.')
    .setRequired(true);

  // ============================================================
  // 2. PAGINE DI SCELTA CORTA / COMPLETA
  // ============================================================

  console.log('3/8 — Routing tipologia e modalità');

  const redMode = form.addPageBreakItem().setTitle('🍷 Rosso');
  const redModeItem = addModeDropdown(form);

  const whiteMode = form.addPageBreakItem().setTitle('🥂 Bianco');
  const whiteModeItem = addModeDropdown(form);

  const sparklingMode = form.addPageBreakItem().setTitle('✨ Spumante');
  const sparklingModeItem = addModeDropdown(form);

  const roseMode = form.addPageBreakItem().setTitle('🌸 Rosé');
  const roseModeItem = addModeDropdown(form);

  const orangeMode = form.addPageBreakItem().setTitle('🟠 Arancione');
  const orangeModeItem = addModeDropdown(form);

  typeItem.setChoices([
    typeItem.createChoice('Rosso', redMode),
    typeItem.createChoice('Bianco', whiteMode),
    typeItem.createChoice('Spumante', sparklingMode),
    typeItem.createChoice('Rosé', roseMode),
    typeItem.createChoice('Arancione', orangeMode)
  ]);

  // ============================================================
  // 3. VALUTAZIONE CORTA — PAGINA 1: COLORE
  // ============================================================

  console.log('4/8 — Percorso corto');

  const redShortVisual = form.addPageBreakItem()
    .setTitle('👁️ 1/4 — Colore · Rosso');
  addShortColor(form, [
    'Rosso violaceo',
    'Rosso rubino',
    'Rosso granato',
    'Rosso porpora',
    'Rosso sangue',
    'Bordeaux',
    'Rosso mattone',
    'Nero'
  ]);
  const redShortExit = form.addPageBreakItem().setTitle('—');

  const whiteShortVisual = form.addPageBreakItem()
    .setTitle('👁️ 1/4 — Colore · Bianco');
  addShortColor(form, [
    'Giallo verdolino',
    'Giallo paglierino',
    'Giallo dorato',
    'Giallo ambrato'
  ]);
  const whiteShortExit = form.addPageBreakItem().setTitle('—');

  const sparklingShortVisual = form.addPageBreakItem()
    .setTitle('👁️ 1/4 — Colore · Spumante');
  addSparklingMethod(form);
  addShortColor(form, [
    'Giallo verdolino',
    'Giallo paglierino',
    'Giallo dorato',
    'Rosa tenue',
    'Rosa salmone',
    'Rosa cerasuolo'
  ]);

  addRadio(form, 'Effervescenza - intensità', [
    'Debole',
    'Media',
    'Intensa'
  ], true);

  addRadio(form, 'Perlage - dimensione delle bollicine', [
    'Fine',
    'Media',
    'Grossolana'
  ], true);

  addRadio(form, 'Perlage - persistenza', [
    'Poco persistente',
    'Persistente',
    'Molto persistente'
  ], true);

  addCheckboxWithOther(form, 'Altre osservazioni visive', [
    'Brillantezza',
    'Sedimenti'
  ], false);

  const sparklingShortExit = form.addPageBreakItem().setTitle('—');

  const roseShortVisual = form.addPageBreakItem()
    .setTitle('👁️ 1/4 — Colore · Rosé');
  addShortColor(form, [
    'Rosa',
    'Rosa tenue',
    'Rosa salmone',
    'Rosa chiaretto',
    'Rosso cerasuolo',
    'Rosa corallo'
  ]);
  const roseShortExit = form.addPageBreakItem().setTitle('—');

  const orangeShortVisual = form.addPageBreakItem()
    .setTitle('👁️ 1/4 — Colore · Arancione');
  addShortColor(form, [
    'Giallo dorato',
    'Giallo ambrato',
    'Arancio chiaro',
    'Arancio',
    'Arancio ramato',
    'Ambrato scuro'
  ]);
  const orangeShortExit = form.addPageBreakItem().setTitle('—');

  // --- Pagina 2: olfattivo corto
  const shortOlfactory = form.addPageBreakItem()
    .setTitle('👃 2/4 — Valutazione olfattiva')
    .setHelpText('Valuta il naso e seleziona le famiglie aromatiche percepite.');

  addRadio(form, 'Condizione dei sentori', ['Netti', 'Non netti'], true);
  addRadio(form, 'Intensità', ['Leggera', 'Media', 'Pronunciata'], true);

  addCheckbox(form, '🌸 Floreale / Fruttato', [
    'Floreale (Acacia, Caprifoglio, Camomilla, Sambuco, Fiori bianchi, Rosa, Violetta)',
    'Frutti verdi (Mela verde, Mela rossa, Pera, Uva spina, Uva sultanina)',
    'Agrumi (Pompelmo, Limone, Limone verde / scorza, Agrumi confits)',
    'Frutti con nocciolo (Pesca, Albicocca, Nettarina fresca, Nettarina essiccata)',
    'Frutti esotici (Banana, Litchi, Mango, Melone, Frutto della passione, Ananas)',
    'Frutti rossi (Fragola, Lampone, Ciliegia, Prugna rossa, Ribes)',
    'Frutti neri (Ribes nero, Mora, Mirtillo, Ciliegia nera, Prugna)',
    'Frutti secchi / cotti (Fico, Prugna secca, Uva passa, Confettura, Frutta cotta)'
  ], false);

  addCheckbox(form, '🌿 Speziato / Vegetale', [
    'Linfa (Peperone verde, Erba tagliata, Foglia di pomodoro)',
    'Vegetale (Erba, Asparago, Foglie di ribes nero)',
    'Erbe spontanee (Eucalyptus, Menta, Piante medicinali, Lavanda, Finocchio selvatico, Aneto)',
    'Spezie dolci (Cannella, Chiodo di garofano, Zenzero, Noce moscata)',
    'Spezie forti (Pepe nero / bianco, Liquirizia, Ginepro)'
  ], false);

  addCheckbox(form, '🧭 Altri', [
    'Minerale (Pietra focaia, Gesso, Mina di matita, Petrolio)',
    'Marino (Iodio, Marea, Alga)',
    'Balsamico (Resina, Cera d\'ape, Canfora)',
    'Animale (Cuoio, Selvaggina, Muschio)'
  ], false);
  
  addCheckbox(form, '🧪 Aromi secondari', [
    'Lieviti / fecce / autolisi (Biscotto, Pane grigliato, Pasticceria, Brioche, Impasto del pane)',
    'Prodotti caseari (Burro, Formaggio, Crema)',
    'Tostati (Vaniglia, Pane grigliato, Cedro, Noce di cocco, Caramello, Affumicato, Cioccolato, Caffè)'
  ], false);

  addCheckbox(form, '🕰️ Aromi terziari', [
    'Ossidazione deliberata (Mandorla, Pasta di mandorle, Nocciola, Noce, Cioccolato, Caffè, Caramello)'
  ], false);

  addShort(
    form,
    'Difetti',
    false,
    'Descrivi brevemente eventuali difetti percepiti (es. tappo, aceto, cartone bagnato, zolfo, muffa, riduzione, uovo marcio, stalla).'
  );

  addShort(form, 'Altro aroma', false);

  // --- Pagina 3: gusto corto
  const shortTaste = form.addPageBreakItem()
    .setTitle('👅 3/4 — Profilo degustazione')
    .setHelpText('Forma condensata dell’esame gustativo completo.');

  addTasteProfile(form);

  // --- Pagina 4: finale corto
  const shortFinal = form.addPageBreakItem()
    .setTitle('⭐ 4/4 — Valutazione finale');

  addShort(form, 'Le tue impressioni', false);
  addShort(form, 'Un piatto di accompagnamento', false);
  addHalfPointRating(form, 'Valutazione complessiva');

  // Il page break seguente controlla la navigazione della pagina precedente:
  // alla fine della valutazione corta viene inviato il form.
  const shortSubmit = form.addPageBreakItem().setTitle('—');
  shortSubmit.setGoToPage(FormApp.PageNavigationType.SUBMIT);

  redShortExit.setGoToPage(shortOlfactory);
  whiteShortExit.setGoToPage(shortOlfactory);
  sparklingShortExit.setGoToPage(shortOlfactory);
  roseShortExit.setGoToPage(shortOlfactory);
  orangeShortExit.setGoToPage(shortOlfactory);

  // ============================================================
  // 4. VALUTAZIONE COMPLETA — VISIVO
  // ============================================================

  console.log('5/8 — Esame visivo completo');

  const redFull = form.addPageBreakItem()
    .setTitle('👁️ 2. Esame visivo — Rosso');
  addFullVisual(form, ['Limpido', 'Torbido'], [
    'Rosso violaceo',
    'Rosso rubino',
    'Rosso granato',
    'Rosso porpora',
    'Rosso sangue',
    'Bordeaux',
    'Rosso mattone',
    'Nero'
  ], ['Brillantezza', 'Archetti o lacrime', 'Sedimenti']);
  const redFullExit = form.addPageBreakItem().setTitle('—');

  const whiteFull = form.addPageBreakItem()
    .setTitle('👁️ 2. Esame visivo — Bianco');
  addFullVisual(form, ['Limpido', 'Torbido'], [
    'Giallo verdolino',
    'Giallo paglierino',
    'Giallo dorato',
    'Giallo ambrato'
  ], ['Brillantezza', 'Archetti o lacrime', 'Sedimenti']);
  const whiteFullExit = form.addPageBreakItem().setTitle('—');

  const roseFull = form.addPageBreakItem()
    .setTitle('👁️ 2. Esame visivo — Rosé');
  addFullVisual(form, ['Limpido', 'Torbido'], [
    'Rosa',
    'Rosa tenue',
    'Rosa salmone',
    'Rosa chiaretto',
    'Rosso cerasuolo',
    'Rosa corallo'
  ], ['Brillantezza', 'Archetti o lacrime', 'Sedimenti']);
  const roseFullExit = form.addPageBreakItem().setTitle('—');

  const orangeFull = form.addPageBreakItem()
    .setTitle('👁️ 2. Esame visivo — Arancione');
  addFullVisual(form, ['Limpido', 'Velato', 'Torbido'], [
    'Giallo dorato',
    'Giallo ambrato',
    'Arancio chiaro',
    'Arancio',
    'Arancio ramato',
    'Ambrato scuro'
  ], ['Brillantezza', 'Archetti o lacrime', 'Sedimenti']);
  const orangeFullExit = form.addPageBreakItem().setTitle('—');

  const sparklingFull = form.addPageBreakItem()
    .setTitle('👁️ 2. Esame visivo — Spumante');

  addSparklingMethod(form);
  addRadio(form, 'Limpidezza', ['Limpido', 'Torbido'], true);
  addRadio(form, 'Intensità del colore', ['Pallido', 'Medio', 'Intenso'], true);
  addRadioWithOther(form, 'Colore', [
    'Giallo verdolino',
    'Giallo paglierino',
    'Giallo dorato',
    'Rosa tenue',
    'Rosa salmone',
    'Rosa cerasuolo'
  ], true);
  addRadio(form, 'Effervescenza - intensità', ['Debole', 'Media', 'Intensa'], true);
  addRadio(form, 'Perlage - dimensione delle bollicine', [
    'Fine', 'Media', 'Grossolana'
  ], true);
  addRadio(form, 'Perlage - persistenza', [
    'Poco persistente', 'Persistente', 'Molto persistente'
  ], true);
  addCheckboxWithOther(form, 'Altre osservazioni visive', [
    'Brillantezza', 'Sedimenti'
  ], false);

  const sparklingFullExit = form.addPageBreakItem().setTitle('—');

  // ============================================================
  // 5. SOLO LE DUE PARTI OLFATTIVE SPECIFICHE
  // ============================================================

  console.log('6/8 — Esame olfattivo completo ottimizzato');

  // Solo Rosso
  const redEvolution = form.addPageBreakItem()
    .setTitle('🍒 Evoluzione delle note fruttate — Rosso');

  addAromaGroup(form, 'Evoluzione delle note fruttate nei vini rossi', [
    'Fico',
    'Prugna',
    'Catrame',
    'Cuoio',
    'Sottobosco',
    'Terra',
    'Funghi',
    'Selvaggina',
    'Tabacco',
    'Carne'
  ]);
  const redEvolutionExit = form.addPageBreakItem().setTitle('—');

  // Solo Bianco
  const whiteEvolution = form.addPageBreakItem()
    .setTitle('🍯 Evoluzione delle note fruttate — Bianco');

  addAromaGroup(form, 'Evoluzione delle note fruttate nei vini bianchi', [
    'Albicocca secca',
    'Confettura',
    'Mela essiccata',
    'Banana essiccata',
    'Kerosene',
    'Zenzero',
    'Pane grigliato',
    'Frutta secca',
    'Funghi',
    'Fieno',
    'Miele'
  ]);
  const whiteEvolutionExit = form.addPageBreakItem().setTitle('—');

  // Un'unica sezione olfattiva comune per TUTTE le tipologie.
  const fullOlfactory = form.addPageBreakItem()
    .setTitle('👃 3. Esame olfattivo');

  addRadio(form, 'Condizione dei sentori', ['Netti', 'Non netti'], true);
  addRadio(form, 'Intensità', ['Leggera', 'Media', 'Pronunciata'], true);
  addRadio(form, 'Evoluzione olfattiva', [
    'Giovane',
    "In corso d'evoluzione",
    'Totalmente evoluto',
    'Affaticato / troppo vecchio'
  ], true);

  form.addSectionHeaderItem()
    .setTitle('Caratteristiche degli aromi')
    .setHelpText('Seleziona soltanto i descrittori effettivamente percepiti.');

  addAromaGroup(form, 'Floreale', [
    'Acacia', 'Caprifoglio', 'Camomilla', 'Sambuco',
    'Fiori bianchi', 'Rosa', 'Violetta'
  ]);

  addAromaGroup(form, 'Frutti verdi', [
    'Mela verde', 'Mela rossa', 'Pera', 'Uva spina', 'Uva sultanina'
  ]);

  addAromaGroup(form, 'Agrumi', [
    'Pompelmo', 'Limone', 'Limone verde / scorza', 'Agrumi confits'
  ]);

  addAromaGroup(form, 'Frutti con nocciolo', [
    'Pesca', 'Albicocca', 'Nettarina fresca', 'Nettarina essiccata'
  ]);

  addAromaGroup(form, 'Frutti esotici', [
    'Banana', 'Litchi', 'Mango', 'Melone', 'Frutto della passione', 'Ananas'
  ]);

  addAromaGroup(form, 'Frutti rossi', [
    'Fragola', 'Lampone', 'Ciliegia', 'Prugna rossa', 'Ribes'
  ]);

  addAromaGroup(form, 'Frutti neri', [
    'Ribes nero', 'Mora', 'Mirtillo', 'Ciliegia nera', 'Prugna'
  ]);

  addAromaGroup(form, 'Frutti secchi / cotti', [
    'Fico', 'Prugna secca', 'Uva passa', 'Confettura', 'Frutta cotta'
  ]);

  addAromaGroup(form, 'Linfa', [
    'Peperone verde', 'Erba tagliata', 'Foglia di pomodoro'
  ]);

  addAromaGroup(form, 'Vegetale', [
    'Erba', 'Asparago', 'Foglie di ribes nero'
  ]);

  addAromaGroup(form, 'Erbe spontanee', [
    'Eucalyptus', 'Menta', 'Piante medicinali',
    'Lavanda', 'Finocchio selvatico', 'Aneto'
  ]);

  addAromaGroup(form, 'Spezie dolci', [
    'Cannella', 'Chiodo di garofano', 'Zenzero', 'Noce moscata'
  ]);

  addAromaGroup(form, 'Spezie forti', [
    'Pepe nero / bianco', 'Liquirizia', 'Ginepro'
  ]);

  addAromaGroup(form, 'Balsamici', [
    'Resina', "Cera d'ape", 'Canfora'
  ]);

  addAromaGroup(form, 'Minerali', [
    'Pietra focaia', 'Gesso', 'Mina di matita', 'Petrolio'
  ]);

  addAromaGroup(form, 'Marini', [
    'Iodio', 'Marea', 'Alga'
  ]);

  form.addSectionHeaderItem().setTitle('Animali');

  addAromaGroup(form, 'Nobili', [
    'Cuoio', 'Selvaggina', 'Muschio'
  ]);

  addAromaGroup(form, 'Possibili difetti', [
    'Pipì di gatto', 'Topo', 'Carne frollata', 'Stalla'
  ]);

  addAromaGroup(form, 'Riduzione', [
    'Ridotto', 'Uovo marcio', 'Cipolla'
  ]);

  addAromaGroup(form, 'Difetti', [
    'Aceto', 'Tappo', 'Cartone bagnato', 'Zolfo', 'Muffa'
  ]);

  form.addSectionHeaderItem().setTitle('Aromi secondari — vinificazione');

  addAromaGroup(form, 'Lieviti / fecce / autolisi', [
    'Biscotto', 'Pane grigliato', 'Pasticceria', 'Brioche', 'Impasto del pane'
  ]);

  addAromaGroup(form, 'Prodotti caseari', [
    'Burro', 'Formaggio', 'Crema'
  ]);

  addAromaGroup(form, 'Tostati', [
    'Vaniglia', 'Pane grigliato', 'Cedro', 'Noce di cocco',
    'Caramello', 'Affumicato', 'Cioccolato', 'Caffè'
  ]);

  form.addSectionHeaderItem().setTitle('Aromi terziari — invecchiamento');

  addAromaGroup(form, 'Ossidazione deliberata', [
    'Mandorla', 'Pasta di mandorle', 'Nocciola', 'Noce',
    'Cioccolato', 'Caffè', 'Caramello'
  ]);

  addShort(form, 'Altri aromi / note olfattive', false);

  // Routing:
  // Rosso -> evoluzione rossi -> olfattivo comune
  // Bianco -> evoluzione bianchi -> olfattivo comune
  // Rosé / Arancione / Spumante -> olfattivo comune direttamente
  redFullExit.setGoToPage(redEvolution);
  whiteFullExit.setGoToPage(whiteEvolution);
  roseFullExit.setGoToPage(fullOlfactory);
  orangeFullExit.setGoToPage(fullOlfactory);
  sparklingFullExit.setGoToPage(fullOlfactory);

  redEvolutionExit.setGoToPage(fullOlfactory);
  whiteEvolutionExit.setGoToPage(fullOlfactory);

  // ============================================================
  // 6. COMPLETA — ESAME GUSTATIVO + FINALE
  // ============================================================

  console.log('7/8 — Gusto e valutazione finale');

  const fullTaste = form.addPageBreakItem()
    .setTitle('👅 4. Esame gustativo');

  addTasteProfile(form);

  form.addCheckboxItem()
    .setTitle('Caratteristiche degli aromi al palato')
    .setHelpText("Utilizzare gli stessi descrittori dell'esame olfattivo.")
    .setChoiceValues(['Primari', 'Secondari', 'Terziari'])
    .setRequired(false);

  const fullFinal = form.addPageBreakItem()
    .setTitle('⭐ 5. Valutazione finale');

  addShort(form, 'Le mie impressioni', false);
  addShort(form, 'Un piatto di accompagnamento', false);
  addHalfPointRating(form, 'Valutazione complessiva');

  // ============================================================
  // 7. IMPOSTA IL BRANCHING DELLE MODALITÀ
  // ============================================================

  redModeItem.setChoices([
    redModeItem.createChoice('Corta', redShortVisual),
    redModeItem.createChoice('Completa', redFull)
  ]);

  whiteModeItem.setChoices([
    whiteModeItem.createChoice('Corta', whiteShortVisual),
    whiteModeItem.createChoice('Completa', whiteFull)
  ]);

  sparklingModeItem.setChoices([
    sparklingModeItem.createChoice('Corta', sparklingShortVisual),
    sparklingModeItem.createChoice('Completa', sparklingFull)
  ]);

  roseModeItem.setChoices([
    roseModeItem.createChoice('Corta', roseShortVisual),
    roseModeItem.createChoice('Completa', roseFull)
  ]);

  orangeModeItem.setChoices([
    orangeModeItem.createChoice('Corta', orangeShortVisual),
    orangeModeItem.createChoice('Completa', orangeFull)
  ]);

  // ============================================================
  // 8. FOGLIO RISPOSTE
  // ============================================================

  console.log('8/8 — Collegamento foglio risposte');

  const responseSheet = SpreadsheetApp.create(
    'Risposte - Scheda di degustazione del vino'
  );

  form.setDestination(
    FormApp.DestinationType.SPREADSHEET,
    responseSheet.getId()
  );

  console.log('COMPLETATO');
  console.log('URL modifica Form: ' + form.getEditUrl());
  console.log('URL pubblico Form: ' + form.getPublishedUrl());
  console.log('Foglio risposte: ' + responseSheet.getUrl());
}


// ============================================================
// HELPERS
// ============================================================

function addModeDropdown(form) {
  return form.addListItem()
    .setTitle('Valutazione')
    .setHelpText('Corta = percorso sintetico. Completa = metodo dettagliato.')
    .setRequired(true);
}

function addShort(form, title, required, helpText) {
  const item = form.addTextItem()
    .setTitle(title)
    .setRequired(required);

  if (helpText) {
    item.setHelpText(helpText);
  }

  return item;
}

function addRadio(form, title, values, required) {
  return form.addMultipleChoiceItem()
    .setTitle(title)
    .setChoiceValues(values)
    .setRequired(required);
}

function addRadioWithOther(form, title, values, required) {
  return form.addMultipleChoiceItem()
    .setTitle(title)
    .setChoiceValues(values)
    .showOtherOption(true)
    .setRequired(required);
}

function addCheckbox(form, title, values, required) {
  return form.addCheckboxItem()
    .setTitle(title)
    .setChoiceValues(values)
    .setRequired(required);
}

function addCheckboxWithOther(form, title, values, required) {
  return form.addCheckboxItem()
    .setTitle(title)
    .setChoiceValues(values)
    .showOtherOption(true)
    .setRequired(required);
}

function addAromaGroup(form, title, values) {
  return addCheckboxWithOther(form, title, values, false);
}

function addShortColor(form, colors) {
  addCheckboxWithOther(form, 'Colore', colors, true);

  addRadio(
    form,
    'Intensità del colore',
    ['Pallido', 'Medio', 'Intenso'],
    true
  );
}

function addFullVisual(form, clarityValues, colors, observationValues) {
  addRadio(form, 'Limpidezza', clarityValues, true);

  addRadio(
    form,
    'Intensità del colore',
    ['Pallido', 'Medio', 'Intenso'],
    true
  );

  addRadioWithOther(form, 'Colore', colors, true);

  addCheckboxWithOther(
    form,
    'Altre osservazioni visive',
    observationValues,
    false
  );
}

function addSparklingMethod(form) {
  form.addListItem()
    .setTitle('Metodo di produzione')
    .setChoiceValues([
      'Metodo Martinotti / Charmat',
      'Metodo classico / tradizionale',
      'Metodo Asti',
      'Metodo ancestrale / Pét-Nat',
      'Metodo di trasferimento',
      'Altro'
    ])
    .setRequired(true);

  form.addTextItem()
    .setTitle('Metodo di produzione — Altro')
    .setHelpText('Compila soltanto se hai selezionato “Altro”.')
    .setRequired(false);
}

function addTasteProfile(form) {
  addRadio(form, 'Zucchero', [
    'Secco',
    'Non del tutto secco',
    'Demi-sec',
    'Morbido',
    'Dolce',
    'Molto dolce'
  ], true);

  addRadio(form, 'Acidità', [
    'Flebile',
    'Media',
    'Elevata'
  ], true);

  addRadio(form, 'Tannini', [
    'Flebili',
    'Medi',
    'Potenti'
  ], true);

  addRadio(form, 'Alcol', [
    'Flebile',
    'Medio',
    'Elevato'
  ], true);

  addRadio(form, 'Corpo', [
    'Leggero',
    'Medio',
    'Strutturato'
  ], true);

  addRadio(form, 'Intensità dei sapori', [
    'Leggera',
    'Media',
    'Pronunciata'
  ], true);

  addRadio(form, 'Persistenza / finale', [
    'Corto',
    'Medio',
    'Lungo'
  ], true);
}

function addHalfPointRating(form, title) {
  return form.addListItem()
    .setTitle(title)
    .setHelpText('Valutazione da 0 a 5 con incrementi di 0,5.')
    .setChoiceValues([
      '0',
      '0,5',
      '1',
      '1,5',
      '2',
      '2,5',
      '3',
      '3,5',
      '4',
      '4,5',
      '5'
    ])
    .setRequired(true);
}
