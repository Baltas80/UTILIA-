import 'package:flutter/material.dart';

enum UtiliaLanguage { system, es, en, fr, de, it, pt }

class UtiliaStrings {
  const UtiliaStrings(this.selectedLanguage);
  final UtiliaLanguage selectedLanguage;
  static UtiliaLanguage fromCode(String? code) => switch (code) { 'en' => UtiliaLanguage.en, 'fr' => UtiliaLanguage.fr, 'de' => UtiliaLanguage.de, 'it' => UtiliaLanguage.it, 'pt' => UtiliaLanguage.pt, 'es' => UtiliaLanguage.es, _ => UtiliaLanguage.system };
  static String code(UtiliaLanguage v) => switch (v) { UtiliaLanguage.system => 'system', UtiliaLanguage.es => 'es', UtiliaLanguage.en => 'en', UtiliaLanguage.fr => 'fr', UtiliaLanguage.de => 'de', UtiliaLanguage.it => 'it', UtiliaLanguage.pt => 'pt' };
  static Locale? locale(UtiliaLanguage v) => v == UtiliaLanguage.system ? null : Locale(code(v));
  static UtiliaLanguage effective(UtiliaLanguage selected, Locale platform) => selected == UtiliaLanguage.system ? fromCode(platform.languageCode) : selected;
  String get languageName => switch (selectedLanguage) { UtiliaLanguage.system => 'Automático', UtiliaLanguage.es => 'Español', UtiliaLanguage.en => 'English', UtiliaLanguage.fr => 'Français', UtiliaLanguage.de => 'Deutsch', UtiliaLanguage.it => 'Italiano', UtiliaLanguage.pt => 'Português' };
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
  String get copied => _t('Resultado copiado', 'Result copied', 'Résultat copié', 'Ergebnis kopiert', 'Risultato copiato', 'Resultado copiado');
  String get clearHistory => _t('Borrar historial', 'Clear history', 'Effacer l’historique', 'Verlauf löschen', 'Cancella cronologia', 'Apagar histórico');
  String get emptyFavorites => _t('Favoritos\nMantén pulsada una herramienta para añadirla.', 'Favorites\nLong-press a tool to add it.', 'Favoris\nMaintenez un outil pour l’ajouter.', 'Favoriten\nWerkzeug gedrückt halten zum Hinzufügen.', 'Preferiti\nTieni premuto uno strumento per aggiungerlo.', 'Favoritos\nMantenha uma ferramenta pressionada para adicionar.');
  String get emptyHistory => _t('Historial\nTus cálculos aparecerán aquí.', 'History\nYour calculations will appear here.', 'Historique\nVos calculs apparaîtront ici.', 'Verlauf\nIhre Berechnungen erscheinen hier.', 'Cronologia\nI tuoi calcoli appariranno qui.', 'Histórico\nOs seus cálculos aparecerão aqui.');
  String toolsCount(int n) => _t('$n herramientas', '$n tools', '$n outils', '$n Werkzeuge', '$n strumenti', '$n ferramentas');
  String get invalidDate => _t('Introduce una fecha válida.', 'Enter a valid date.', 'Saisissez une date valide.', 'Geben Sie ein gültiges Datum ein.', 'Inserisci una data valida.', 'Introduza uma data válida.');
  String category(String id) => switch (id) {
        'Dinero' => _t('Dinero', 'Money', 'Argent', 'Geld', 'Denaro', 'Dinheiro'),
        'Tiempo' => _t('Tiempo', 'Time', 'Temps', 'Zeit', 'Tempo', 'Tempo'),
        'Casa' => _t('Casa', 'Home', 'Maison', 'Haus', 'Casa', 'Casa'),
        'Coche' => _t('Coche', 'Car', 'Voiture', 'Auto', 'Auto', 'Carro'),
        'Conversores' => _t('Conversores', 'Converters', 'Convertisseurs', 'Umrechner', 'Convertitori', 'Conversores'),
        'Salud' => _t('Salud', 'Health', 'Santé', 'Gesundheit', 'Salute', 'Saúde'),
        'Estudio' => _t('Estudio', 'Study', 'Études', 'Lernen', 'Studio', 'Estudo'),
        'Varios' => _t('Varios', 'Miscellaneous', 'Divers', 'Sonstiges', 'Varie', 'Vários'),
        _ => id,
      };
  String toolName(String id, String fallback) => _tool(id, fallback, 0);
  String toolDescription(String id, String fallback) => _tool(id, fallback, 1);
  String _t(String es, String en, String fr, String de, String it, String pt) => switch (selectedLanguage) { UtiliaLanguage.en => en, UtiliaLanguage.fr => fr, UtiliaLanguage.de => de, UtiliaLanguage.it => it, UtiliaLanguage.pt => pt, _ => es };

  static const _tools = <String, List<String>>{
    'percentage':['Porcentaje','Calcular un porcentaje de una cantidad','Percentage','Calculate a percentage of a value','Pourcentage','Calculer un pourcentage d’une valeur','Prozent','Einen Prozentsatz berechnen','Percentuale','Calcolare una percentuale','Percentagem','Calcular uma percentagem de um valor'],
    'discount':['Descuentos','Calcular el precio final tras un descuento','Discounts','Calculate the final price after a discount','Réductions','Calculer le prix final après réduction','Rabatte','Endpreis nach Rabatt berechnen','Sconti','Calcolare il prezzo finale dopo uno sconto','Descontos','Calcular o preço final após um desconto'],
    'iva':['IVA','Añadir IVA a un precio','VAT','Add VAT to a price','TVA','Ajouter la TVA à un prix','MwSt.','Mehrwertsteuer zu einem Preis hinzufügen','IVA','Aggiungere l’IVA a un prezzo','IVA','Adicionar IVA a um preço'],
    'tip':['Propinas','Calcular una propina y repartir el total','Tips','Calculate a tip and split the total','Pourboires','Calculer un pourboire et partager le total','Trinkgeld','Trinkgeld berechnen und Gesamtbetrag teilen','Mance','Calcolare una mancia e dividere il totale','Gorjetas','Calcular uma gorjeta e dividir o total'],
    'loan':['Préstamos','Calcular la cuota mensual de un préstamo','Loans','Calculate a monthly loan payment','Prêts','Calculer une mensualité de prêt','Kredite','Eine monatliche Kreditrate berechnen','Prestiti','Calcolare una rata mensile','Empréstimos','Calcular uma prestação mensal'],
    'compoundInterest':['Interés compuesto','Calcular el crecimiento con interés compuesto','Compound interest','Calculate growth with compound interest','Intérêts composés','Calculer une croissance avec intérêts composés','Zinseszins','Wachstum mit Zinseszins berechnen','Interesse composto','Calcolare la crescita con interesse composto','Juros compostos','Calcular crescimento com juros compostos'],
    'age':['Edad','Calcular la edad a partir de una fecha de nacimiento','Age','Calculate age from a birth date','Âge','Calculer l’âge à partir d’une date de naissance','Alter','Alter anhand des Geburtsdatums berechnen','Età','Calcolare l’età dalla data di nascita','Idade','Calcular a idade a partir de uma data de nascimento'],
    'dateDifference':['Diferencia de fechas','Calcular los días entre dos fechas','Date difference','Calculate the days between two dates','Différence de dates','Calculer les jours entre deux dates','Datumsdifferenz','Tage zwischen zwei Daten berechnen','Differenza date','Calcolare i giorni tra due date','Diferença de datas','Calcular os dias entre duas datas'],
    'workHours':['Horas trabajadas','Calcular las horas trabajadas descontando pausas','Work hours','Calculate worked hours after breaks','Heures travaillées','Calculer les heures travaillées après les pauses','Arbeitszeit','Arbeitszeit nach Pausen berechnen','Ore lavorate','Calcolare le ore lavorate dopo le pause','Horas trabalhadas','Calcular horas trabalhadas após pausas'],
    'countdown':['Cuenta atrás','Convertir horas, minutos y segundos a segundos','Countdown','Convert hours, minutes and seconds to total seconds','Compte à rebours','Convertir heures, minutes et secondes en secondes','Countdown','Stunden, Minuten und Sekunden in Sekunden umrechnen','Conto alla rovescia','Convertire ore, minuti e secondi in secondi','Contagem regressiva','Converter horas, minutos e segundos em segundos'],
    'area':['Superficie','Calcular el área de una superficie rectangular','Area','Calculate rectangular surface area','Surface','Calculer une surface rectangulaire','Fläche','Rechteckige Fläche berechnen','Area','Calcolare una superficie rettangolare','Área','Calcular uma área retangular'],
    'paint':['Pintura','Estimar los litros de pintura necesarios','Paint','Estimate litres of paint needed','Peinture','Estimer les litres de peinture nécessaires','Farbe','Benötigte Liter Farbe schätzen','Vernice','Stimare i litri di vernice necessari','Tinta','Estimar litros de tinta necessários'],
    'electricity':['Consumo eléctrico','Estimar el coste de la electricidad','Electricity','Estimate electricity cost','Électricité','Estimer le coût de l’électricité','Strom','Stromkosten schätzen','Elettricità','Stimare il costo dell’elettricità','Eletricidade','Estimar o custo da eletricidade'],
    'fuel':['Combustible','Calcular el coste de combustible de un viaje','Fuel','Calculate fuel cost for a trip','Carburant','Calculer le coût du carburant d’un trajet','Kraftstoff','Kraftstoffkosten einer Fahrt berechnen','Carburante','Calcolare il costo del carburante di un viaggio','Combustível','Calcular o custo de combustível de uma viagem'],
    'costPerKm':['Coste por km','Calcular el coste por kilómetro','Cost per km','Calculate cost per kilometre','Coût au km','Calculer le coût par kilomètre','Kosten pro km','Kosten pro Kilometer berechnen','Costo al km','Calcolare il costo per chilometro','Custo por km','Calcular o custo por quilómetro'],
    'length':['Conversor de longitud','Convertir entre unidades de longitud','Length converter','Convert between length units','Convertisseur de longueur','Convertir entre unités de longueur','Längenumrechner','Längeneinheiten umrechnen','Convertitore di lunghezza','Convertire tra unità di lunghezza','Conversor de comprimento','Converter entre unidades de comprimento'],
    'weight':['Conversor de peso','Convertir entre unidades de peso','Weight converter','Convert between weight units','Convertisseur de poids','Convertir entre unités de poids','Gewichtsumrechner','Gewichtseinheiten umrechnen','Convertitore di peso','Convertire tra unità di peso','Conversor de peso','Converter entre unidades de peso'],
    'bmi':['IMC','Calcular el índice de masa corporal','BMI','Calculate body mass index','IMC','Calculer l’indice de masse corporelle','BMI','Body-Mass-Index berechnen','IMC','Calcolare l’indice di massa corporea','IMC','Calcular o índice de massa corporal'],
    'gradeAverage':['Media de notas','Calcular la media de varias notas','Grade average','Calculate the average of several grades','Moyenne des notes','Calculer la moyenne de plusieurs notes','Notendurchschnitt','Durchschnitt mehrerer Noten berechnen','Media dei voti','Calcolare la media di più voti','Média das notas','Calcular a média de várias notas'],
    'ruleOfThree':['Regla de tres','Resolver un cálculo proporcional','Rule of three','Solve a proportional calculation','Règle de trois','Résoudre un calcul proportionnel','Dreisatz','Eine proportionale Rechnung lösen','Regola del tre','Risolvere un calcolo proporzionale','Regra de três','Resolver um cálculo proporcional'],
    'calculator':['Calculadora','Calculadora rápida con teclado numérico','Calculator','Fast calculator with numeric keypad','Calculatrice','Calculatrice rapide avec pavé numérique','Rechner','Schneller Rechner mit Ziffernblock','Calcolatrice','Calcolatrice rapida con tastierino numerico','Calculadora','Calculadora rápida com teclado numérico'],
    'scientificCalculator':['Calculadora científica','Funciones trigonométricas y matemáticas avanzadas','Scientific calculator','Trigonometric and advanced mathematical functions','Calculatrice scientifique','Fonctions trigonométriques et mathématiques avancées','Wissenschaftlicher Rechner','Trigonometrische und erweiterte mathematische Funktionen','Calcolatrice scientifica','Funzioni trigonometriche e matematiche avanzate','Calculadora científica','Funções trigonométricas e matemáticas avançadas'],
  };

  String _tool(String id, String fallback, int field) { final v = _tools[id]; if (v == null) return fallback; final offset = switch (selectedLanguage) { UtiliaLanguage.en => 2, UtiliaLanguage.fr => 4, UtiliaLanguage.de => 6, UtiliaLanguage.it => 8, UtiliaLanguage.pt => 10, _ => 0 }; return v[offset + field]; }
  String inputLabel(String id, int index) {
    const d = <String,List<String>>{
      'percentage':['Cantidad','Porcentaje (%)'],'discount':['Precio (€)','Descuento (%)'],'iva':['Precio (€)','IVA (%)'],'tip':['Cuenta (€)','Propina (%)','Personas'],'loan':['Capital (€)','Interés anual (%)','Meses'],'compoundInterest':['Capital (€)','Interés anual (%)','Años'],'age':['Fecha de nacimiento (dd/mm/aaaa)'],'dateDifference':['Fecha inicial (dd/mm/aaaa)','Fecha final (dd/mm/aaaa)'],'workHours':['Hora de inicio (ej. 8,5)','Hora de fin (ej. 17)','Descanso (min)'],'countdown':['Horas','Minutos','Segundos'],'area':['Largo (m)','Ancho (m)'],'paint':['Superficie (m²)','Cobertura (m²/L)'],'electricity':['Potencia (W)','Horas/día','Días'],'fuel':['Distancia (km)','Consumo (L/100 km)','Precio €/L'],'costPerKm':['Coste total (€)','Kilómetros'],'length':['Valor','Unidad de origen','Unidad de destino'],'weight':['Valor','Unidad de origen','Unidad de destino'],'bmi':['Peso (kg)','Altura (cm)'],'gradeAverage':['Notas separadas por comas'],'ruleOfThree':['A','B','C']};
    final es = d[id] ?? ['Valor'];
    final translated = switch (selectedLanguage) {
      UtiliaLanguage.en => {'bmi':['Weight (kg)','Height (cm)'],'gradeAverage':['Grades separated by commas'],'length':['Value','Source unit','Target unit'],'weight':['Value','Source unit','Target unit']},
      UtiliaLanguage.fr => {'bmi':['Poids (kg)','Taille (cm)'],'gradeAverage':['Notes séparées par des virgules'],'length':['Valeur','Unité source','Unité cible'],'weight':['Valeur','Unité source','Unité cible']},
      UtiliaLanguage.de => {'bmi':['Gewicht (kg)','Größe (cm)'],'gradeAverage':['Noten durch Kommas getrennt'],'length':['Wert','Quelleinheit','Zieleinheit'],'weight':['Wert','Quelleinheit','Zieleinheit']},
      UtiliaLanguage.it => {'bmi':['Peso (kg)','Altezza (cm)'],'gradeAverage':['Voti separati da virgole'],'length':['Valore','Unità di origine','Unità di destinazione'],'weight':['Valore','Unità di origine','Unità di destinazione']},
      UtiliaLanguage.pt => {'bmi':['Peso (kg)','Altura (cm)'],'gradeAverage':['Notas separadas por vírgulas'],'length':['Valor','Unidade de origem','Unidade de destino'],'weight':['Valor','Unidade de origem','Unidade de destino']},
      _ => <String,List<String>>{},
    };
    final list = translated[id] ?? es;
    return index < list.length ? list[index] : es[index];
  }
}
