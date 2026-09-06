import 'package:flutter/material.dart';

enum UtiliaLanguage { system, es, en, fr, de, it, pt }

class UtiliaStrings {
  const UtiliaStrings(this.selectedLanguage);
  final UtiliaLanguage selectedLanguage;

  static UtiliaLanguage fromCode(String? code) => switch (code) {
        'en' => UtiliaLanguage.en,
        'fr' => UtiliaLanguage.fr,
        'de' => UtiliaLanguage.de,
        'it' => UtiliaLanguage.it,
        'pt' => UtiliaLanguage.pt,
        'es' => UtiliaLanguage.es,
        _ => UtiliaLanguage.system,
      };
  static String code(UtiliaLanguage v) => switch (v) {
        UtiliaLanguage.system => 'system',
        UtiliaLanguage.es => 'es',
        UtiliaLanguage.en => 'en',
        UtiliaLanguage.fr => 'fr',
        UtiliaLanguage.de => 'de',
        UtiliaLanguage.it => 'it',
        UtiliaLanguage.pt => 'pt',
      };
  static Locale? locale(UtiliaLanguage v) =>
      v == UtiliaLanguage.system ? null : Locale(code(v));
  static UtiliaLanguage effective(UtiliaLanguage selected, Locale platform) =>
      selected == UtiliaLanguage.system ? fromCode(platform.languageCode) : selected;

  String get languageName => switch (selectedLanguage) {
        UtiliaLanguage.system => 'Automático',
        UtiliaLanguage.es => 'Español',
        UtiliaLanguage.en => 'English',
        UtiliaLanguage.fr => 'Français',
        UtiliaLanguage.de => 'Deutsch',
        UtiliaLanguage.it => 'Italiano',
        UtiliaLanguage.pt => 'Português',
      };
  String get slogan => _t('Pequeñas herramientas.\nGrandes soluciones.', 'Small tools.\nBig solutions.', 'Petits outils.\nGrandes solutions.', 'Kleine Werkzeuge.\nGroße Lösungen.', 'Piccoli strumenti.\nGrandi soluzioni.', 'Pequenas ferramentas.\nGrandes soluções.');
  String get search => _t('Buscar herramientas...', 'Search tools...', 'Rechercher des outils...', 'Werkzeuge suchen...', 'Cerca strumenti...', 'Pesquisar ferramentas...');
  String get categories => _t('Categorías', 'Categories', 'Catégories', 'Kategorien', 'Categorie', 'Categorias');
  String get results => _t('Resultados', 'Results', 'Résultats', 'Ergebnisse', 'Risultati', 'Resultados');
  String get home => _t('Inicio', 'Home', 'Accueil', 'Start', 'Home', 'Início');
  String get favorites => _t('Favoritos', 'Favorites', 'Favoris', 'Favoriten', 'Preferiti', 'Favoritos');
  String get history => _t('Historial', 'History', 'Historique', 'Verlauf', 'Cronologia', 'Histórico');
  String get more => _t('Más', 'More', 'Plus', 'Mehr', 'Altro', 'Mais');
  String get preferences => _t('Preferencias', 'Preferences', 'Préférences', 'Einstellungen', 'Preferenze', 'Preferências');
  String get darkMode => _t('Modo oscuro', 'Dark mode', 'Mode sombre', 'Dunkelmodus', 'Modalità scura', 'Modo escuro');
  String get savedDevice => _t('Guardar preferencia en el dispositivo', 'Save preference on this device', 'Enregistrer sur cet appareil', 'Auf diesem Gerät speichern', 'Salva sul dispositivo', 'Guardar no dispositivo');
  String get languageLabel => _t('Idioma', 'Language', 'Langue', 'Sprache', 'Lingua', 'Idioma');
  String get calculate => _t('Calcular', 'Calculate', 'Calculer', 'Berechnen', 'Calcola', 'Calcular');
  String get result => _t('Resultado', 'Result', 'Résultat', 'Ergebnis', 'Risultato', 'Resultado');
  String get clearHistory => _t('Borrar historial', 'Clear history', 'Effacer l’historique', 'Verlauf löschen', 'Cancella cronologia', 'Apagar histórico');
  String get emptyFavorites => _t('Favoritos\nMantén pulsada una herramienta para añadirla.', 'Favorites\nLong-press a tool to add it.', 'Favoris\nMaintenez un outil pour l’ajouter.', 'Favoriten\nWerkzeug gedrückt halten zum Hinzufügen.', 'Preferiti\nTieni premuto uno strumento per aggiungerlo.', 'Favoritos\nMantenha uma ferramenta pressionada para adicionar.');
  String get emptyHistory => _t('Historial\nTus cálculos aparecerán aquí.', 'History\nYour calculations will appear here.', 'Historique\nVos calculs apparaîtront ici.', 'Verlauf\nIhre Berechnungen erscheinen hier.', 'Cronologia\nI tuoi calcoli appariranno qui.', 'Histórico\nOs seus cálculos aparecerão aqui.');
  String toolsCount(int n) => _t('$n herramientas', '$n tools', '$n outils', '$n Werkzeuge', '$n strumenti', '$n ferramentas');

  String toolName(String id, String fallback) => _tool(id, fallback, 0);
  String toolDescription(String id, String fallback) => _tool(id, fallback, 1);

  String _t(String es, String en, String fr, String de, String it, String pt) => switch (selectedLanguage) {
        UtiliaLanguage.en => en,
        UtiliaLanguage.fr => fr,
        UtiliaLanguage.de => de,
        UtiliaLanguage.it => it,
        UtiliaLanguage.pt => pt,
        _ => es,
      };

  String _tool(String id, String fallback, int field) {
    final d = <String, List<String>>{
      'percentage': ['Porcentaje', 'Calcular un porcentaje de una cantidad', 'Percentage', 'Calculate a percentage of a value', 'Pourcentage', 'Calculer un pourcentage d’une valeur', 'Prozent', 'Einen Prozentsatz berechnen', 'Percentuale', 'Calcolare una percentuale', 'Percentagem', 'Calcular uma percentagem de um valor'],
      'discount': ['Descuentos', 'Calcular el precio final tras un descuento', 'Discounts', 'Calculate the final price after a discount', 'Réductions', 'Calculer le prix final après réduction', 'Rabatte', 'Endpreis nach Rabatt berechnen', 'Sconti', 'Calcolare il prezzo finale dopo uno sconto', 'Descontos', 'Calcular o preço final após um desconto'],
      'iva': ['IVA', 'Añadir IVA a un precio', 'VAT', 'Add VAT to a price', 'TVA', 'Ajouter la TVA à un prix', 'MwSt.', 'Mehrwertsteuer zu einem Preis hinzufügen', 'IVA', 'Aggiungere l’IVA a un prezzo', 'IVA', 'Adicionar IVA a um preço'],
      'tip': ['Propinas', 'Calcular una propina y repartir el total', 'Tips', 'Calculate a tip and split the total', 'Pourboires', 'Calculer un pourboire et partager le total', 'Trinkgeld', 'Trinkgeld berechnen und Gesamtbetrag teilen', 'Mance', 'Calcolare una mancia e dividere il totale', 'Gorjetas', 'Calcular uma gorjeta e dividir o total'],
      'loan': ['Préstamos', 'Calcular la cuota mensual de un préstamo', 'Loans', 'Calculate a monthly loan payment', 'Prêts', 'Calculer une mensualité de prêt', 'Kredite', 'Eine monatliche Kreditrate berechnen', 'Prestiti', 'Calcolare una rata mensile', 'Empréstimos', 'Calcular uma prestação mensal'],
      'compoundInterest': ['Interés compuesto', 'Calcular el crecimiento con interés compuesto', 'Compound interest', 'Calculate growth with compound interest', 'Intérêts composés', 'Calculer une croissance avec intérêts composés', 'Zinseszins', 'Wachstum mit Zinseszins berechnen', 'Interesse composto', 'Calcolare la crescita con interesse composto', 'Juros compostos', 'Calcular crescimento com juros compostos'],
      'age': ['Edad', 'Calcular la edad a partir de una fecha de nacimiento', 'Age', 'Calculate age from a birth date', 'Âge', 'Calculer l’âge à partir d’une date de naissance', 'Alter', 'Alter anhand des Geburtsdatums berechnen', 'Età', 'Calcolare l’età dalla data di nascita', 'Idade', 'Calcular a idade a partir da data de nascimento'],
      'dateDifference': ['Diferencia de fechas', 'Calcular los días entre dos fechas', 'Date difference', 'Calculate the days between two dates', 'Différence de dates', 'Calculer les jours entre deux dates', 'Datumsdifferenz', 'Tage zwischen zwei Daten berechnen', 'Differenza date', 'Calcolare i giorni tra due date', 'Diferença de datas', 'Calcular os dias entre duas datas'],
      'workHours': ['Horas trabajadas', 'Calcular las horas trabajadas descontando pausas', 'Work hours', 'Calculate worked hours after breaks', 'Heures travaillées', 'Calculer les heures travaillées après les pauses', 'Arbeitszeit', 'Arbeitszeit nach Pausen berechnen', 'Ore lavorate', 'Calcolare le ore lavorate dopo le pause', 'Horas trabalhadas', 'Calcular horas trabalhadas após pausas'],
      'countdown': ['Cuenta atrás', 'Convertir horas, minutos y segundos a segundos', 'Countdown', 'Convert hours, minutes and seconds to total seconds', 'Compte à rebours', 'Convertir heures, minutes et secondes en secondes', 'Countdown', 'Stunden, Minuten und Sekunden in Sekunden umrechnen', 'Conto alla rovescia', 'Convertire ore, minuti e secondi in secondi', 'Contagem regressiva', 'Converter horas, minutos e segundos em segundos'],
      'area': ['Superficie', 'Calcular el área de una superficie rectangular', 'Area', 'Calculate rectangular surface area', 'Surface', 'Calculer une surface rectangulaire', 'Fläche', 'Rechteckige Fläche berechnen', 'Area', 'Calcolare una superficie rettangolare', 'Área', 'Calcular uma área retangular'],
      'paint': ['Pintura', 'Estimar los litros de pintura necesarios', 'Paint', 'Estimate litres of paint needed', 'Peinture', 'Estimer les litres de peinture nécessaires', 'Farbe', 'Benötigte Liter Farbe schätzen', 'Vernice', 'Stimare i litri di vernice necessari', 'Tinta', 'Estimar litros de tinta necessários'],
      'electricity': ['Consumo eléctrico', 'Estimar el coste de la electricidad', 'Electricity', 'Estimate electricity cost', 'Électricité', 'Estimer le coût de l’électricité', 'Strom', 'Stromkosten schätzen', 'Elettricità', 'Stimare il costo dell’elettricità', 'Eletricidade', 'Estimar o custo da eletricidade'],
      'fuel': ['Combustible', 'Calcular el coste de combustible de un viaje', 'Fuel', 'Calculate fuel cost for a trip', 'Carburant', 'Calculer le coût du carburant d’un trajet', 'Kraftstoff', 'Kraftstoffkosten einer Fahrt berechnen', 'Carburante', 'Calcolare il costo del carburante di un viaggio', 'Combustível', 'Calcular o custo de combustível de uma viagem'],
      'costPerKm': ['Coste por km', 'Calcular el coste por kilómetro', 'Cost per km', 'Calculate cost per kilometre', 'Coût au km', 'Calculer le coût par kilomètre', 'Kosten pro km', 'Kosten pro Kilometer berechnen', 'Costo al km', 'Calcolare il costo per chilometro', 'Custo por km', 'Calcular o custo por quilómetro'],
      'length': ['Conversor de longitud', 'Convertir entre unidades de longitud', 'Length converter', 'Convert between length units', 'Convertisseur de longueur', 'Convertir entre unités de longueur', 'Längenumrechner', 'Längeneinheiten umrechnen', 'Convertitore di lunghezza', 'Convertire tra unità di lunghezza', 'Conversor de comprimento', 'Converter entre unidades de comprimento'],
      'weight': ['Conversor de peso', 'Convertir entre unidades de peso', 'Weight converter', 'Convert between weight units', 'Convertisseur de poids', 'Convertir entre unités de poids', 'Gewichtsumrechner', 'Gewichtseinheiten umrechnen', 'Convertitore di peso', 'Convertire tra unità di peso', 'Conversor de peso', 'Converter entre unidades de peso'],
      'bmi': ['IMC', 'Calcular el índice de masa corporal', 'BMI', 'Calculate body mass index', 'IMC', 'Calculer l’indice de masse corporelle', 'BMI', 'Body-Mass-Index berechnen', 'IMC', 'Calcolare l’indice di massa corporea', 'IMC', 'Calcular o índice de massa corporal'],
      'gradeAverage': ['Media de notas', 'Calcular la media de varias notas', 'Grade average', 'Calculate the average of several grades', 'Moyenne des notes', 'Calculer la moyenne de plusieurs notes', 'Notendurchschnitt', 'Durchschnitt mehrerer Noten berechnen', 'Media dei voti', 'Calcolare la media di più voti', 'Média das notas', 'Calcular a média de várias notas'],
      'ruleOfThree': ['Regla de tres', 'Resolver un cálculo proporcional', 'Rule of three', 'Solve a proportional calculation', 'Règle de trois', 'Résoudre un calcul proportionnel', 'Dreisatz', 'Eine proportionale Rechnung lösen', 'Regola del tre', 'Risolvere un calcolo proporzionale', 'Regra de três', 'Resolver um cálculo proporcional'],
    };
    final v = d[id];
    if (v == null) return fallback;
    final offset = switch (selectedLanguage) {
      UtiliaLanguage.en => 2,
      UtiliaLanguage.fr => 4,
      UtiliaLanguage.de => 6,
      UtiliaLanguage.it => 8,
      UtiliaLanguage.pt => 10,
      _ => 0,
    };
    return v[offset + field];
  }

  String inputLabel(String id, int index) {
    final d = <String, List<String>>{
      'percentage': ['Cantidad', 'Porcentaje (%)'],
      'discount': ['Precio (€)', 'Descuento (%)'],
      'iva': ['Precio (€)', 'IVA (%)'],
      'tip': ['Cuenta (€)', 'Propina (%)', 'Personas'],
      'loan': ['Capital (€)', 'Interés anual (%)', 'Meses'],
      'compoundInterest': ['Capital (€)', 'Interés anual (%)', 'Años'],
      'age': ['Fecha de nacimiento (dd/mm/aaaa)'],
      'dateDifference': ['Fecha inicial (dd/mm/aaaa)', 'Fecha final (dd/mm/aaaa)'],
      'workHours': ['Hora de inicio (ej. 8,5)', 'Hora de fin (ej. 17)', 'Descanso (min)'],
      'countdown': ['Horas', 'Minutos', 'Segundos'],
      'area': ['Largo (m)', 'Ancho (m)'],
      'paint': ['Superficie (m²)', 'Cobertura (m²/L)'],
      'electricity': ['Potencia (W)', 'Horas/día', 'Días'],
      'fuel': ['Distancia (km)', 'Consumo (L/100 km)', 'Precio €/L'],
      'costPerKm': ['Coste total (€)', 'Kilómetros'],
      'length': ['Valor', 'Unidad de origen (mm/cm/m/km/in/ft/yd/mi)', 'Unidad de destino'],
      'weight': ['Valor', 'Unidad de origen (mg/g/kg/t/oz/lb)', 'Unidad de destino'],
      'bmi': ['Peso (kg)', 'Altura (cm)'],
      'gradeAverage': ['Notas separadas por comas'],
      'ruleOfThree': ['A', 'B', 'C'],
    };
    final es = d[id] ?? const ['Cantidad', 'Porcentaje (%)'];
    final translations = <String, List<String>>{
      'en': ['Amount','Percentage (%)','Price (€)','Discount (%)','Price (€)','VAT (%)','Bill (€)','Tip (%)','People','Capital (€)','Annual interest (%)','Months','Years','Birth date (dd/mm/yyyy)','Start date (dd/mm/yyyy)','End date (dd/mm/yyyy)','Start time (e.g. 8.5)','End time (e.g. 17)','Break (min)','Hours','Minutes','Seconds','Length (m)','Width (m)','Surface (m²)','Coverage (m²/L)','Power (W)','Hours/day','Days','Distance (km)','Consumption (L/100 km)','Price €/L','Total cost (€)','Kilometres','Value','Source unit (mm/cm/m/km/in/ft/yd/mi)','Target unit','Weight (kg)','Height (cm)','Grades separated by commas','A','B','C'],
      'fr': ['Montant','Pourcentage (%)','Prix (€)','Réduction (%)','Prix (€)','TVA (%)','Addition (€)','Pourboire (%)','Personnes','Capital (€)','Taux annuel (%)','Mois','Années','Date de naissance (jj/mm/aaaa)','Date de début (jj/mm/aaaa)','Date de fin (jj/mm/aaaa)','Heure de début (ex. 8,5)','Heure de fin (ex. 17)','Pause (min)','Heures','Minutes','Secondes','Longueur (m)','Largeur (m)','Surface (m²)','Rendement (m²/L)','Puissance (W)','Heures/jour','Jours','Distance (km)','Consommation (L/100 km)','Prix €/L','Coût total (€)','Kilomètres','Valeur','Unité source (mm/cm/m/km/in/ft/yd/mi)','Unité cible','Poids (kg)','Taille (cm)','Notes séparées par des virgules','A','B','C'],
      'de': ['Betrag','Prozentsatz (%)','Preis (€)','Rabatt (%)','Preis (€)','MwSt. (%)','Rechnung (€)','Trinkgeld (%)','Personen','Kapital (€)','Jahreszins (%)','Monate','Jahre','Geburtsdatum (TT.MM.JJJJ)','Startdatum (TT.MM.JJJJ)','Enddatum (TT.MM.JJJJ)','Startzeit (z. B. 8,5)','Endzeit (z. B. 17)','Pause (Min.)','Stunden','Minuten','Sekunden','Länge (m)','Breite (m)','Fläche (m²)','Reichweite (m²/L)','Leistung (W)','Stunden/Tag','Tage','Entfernung (km)','Verbrauch (L/100 km)','Preis €/L','Gesamtkosten (€)','Kilometer','Wert','Ausgangseinheit (mm/cm/m/km/in/ft/yd/mi)','Zieleinheit','Gewicht (kg)','Größe (cm)','Noten durch Kommas getrennt','A','B','C'],
      'it': ['Importo','Percentuale (%)','Prezzo (€)','Sconto (%)','Prezzo (€)','IVA (%)','Conto (€)','Mancia (%)','Persone','Capitale (€)','Interesse annuo (%)','Mesi','Anni','Data di nascita (gg/mm/aaaa)','Data iniziale (gg/mm/aaaa)','Data finale (gg/mm/aaaa)','Ora iniziale (es. 8,5)','Ora finale (es. 17)','Pausa (min)','Ore','Minuti','Secondi','Lunghezza (m)','Larghezza (m)','Superficie (m²)','Copertura (m²/L)','Potenza (W)','Ore/giorno','Giorni','Distanza (km)','Consumo (L/100 km)','Prezzo €/L','Costo totale (€)','Chilometri','Valore','Unità origine (mm/cm/m/km/in/ft/yd/mi)','Unità destinazione','Peso (kg)','Altezza (cm)','Voti separati da virgole','A','B','C'],
      'pt': ['Valor','Percentagem (%)','Preço (€)','Desconto (%)','Preço (€)','IVA (%)','Conta (€)','Gorjeta (%)','Pessoas','Capital (€)','Juro anual (%)','Meses','Anos','Data de nascimento (dd/mm/aaaa)','Data inicial (dd/mm/aaaa)','Data final (dd/mm/aaaa)','Hora inicial (ex. 8,5)','Hora final (ex. 17)','Pausa (min)','Horas','Minutos','Segundos','Comprimento (m)','Largura (m)','Superfície (m²)','Cobertura (m²/L)','Potência (W)','Horas/dia','Dias','Distância (km)','Consumo (L/100 km)','Preço €/L','Custo total (€)','Quilómetros','Valor','Unidade de origem (mm/cm/m/km/in/ft/yd/mi)','Unidade de destino','Peso (kg)','Altura (cm)','Notas separadas por vírgulas','A','B','C'],
    };
    if (selectedLanguage == UtiliaLanguage.es || selectedLanguage == UtiliaLanguage.system) return index < es.length ? es[index] : '';
    final list = translations[code(selectedLanguage)]!;
    final ranges = <String, List<int>>{
      'percentage':[0,2], 'discount':[2,4], 'iva':[4,6], 'tip':[6,9],
      'loan':[9,12], 'compoundInterest':[12,15], 'age':[15,16],
      'dateDifference':[16,18], 'workHours':[18,21], 'countdown':[21,24],
      'area':[24,26], 'paint':[26,28], 'electricity':[28,31], 'fuel':[31,34],
      'costPerKm':[34,36], 'length':[36,39], 'weight':[39,41], 'bmi':[39,41],
      'gradeAverage':[41,42], 'ruleOfThree':[42,45]
    };
    final range = ranges[id] ?? const [0,0];
    final pos = range[0] + index;
    return pos < range[1] && pos < list.length ? list[pos] : (index < es.length ? es[index] : '');
  }

  String get invalidDate => _t('Fecha no válida. Usa dd/mm/aaaa.', 'Invalid date. Use dd/mm/yyyy.', 'Date invalide. Utilisez jj/mm/aaaa.', 'Ungültiges Datum. TT.MM.JJJJ verwenden.', 'Data non valida. Usa gg/mm/aaaa.', 'Data inválida. Use dd/mm/aaaa.');

  String category(String id) {
    final d = <String, List<String>>{
      'Dinero':['Dinero','Money','Argent','Geld','Denaro','Dinheiro'],
      'Tiempo':['Tiempo','Time','Temps','Zeit','Tempo','Tempo'],
      'Casa':['Casa','Home','Maison','Haus','Casa','Casa'],
      'Coche':['Coche','Car','Voiture','Auto','Auto','Carro'],
      'Conversores':['Conversores','Converters','Convertisseurs','Umrechner','Convertitori','Conversores'],
      'Salud':['Salud','Health','Santé','Gesundheit','Salute','Saúde'],
      'Estudio':['Estudio','Study','Études','Lernen','Studio','Estudo'],
      'Varios':['Varios','Miscellaneous','Divers','Sonstiges','Varie','Vários'],
    };
    final v=d[id]; if(v==null)return id;
    return switch(selectedLanguage){UtiliaLanguage.en=>v[1],UtiliaLanguage.fr=>v[2],UtiliaLanguage.de=>v[3],UtiliaLanguage.it=>v[4],UtiliaLanguage.pt=>v[5],_=>v[0]};
  }
}

extension UtiliaStringsCompat on UtiliaStrings { String get language => languageLabel; }
