clear all

% Speicherpfade zu allen notwendigen Dateien
Pfad = SpeicherPfad();

% Einstellungen zur Auswertung
option = Einstellung();

%Aufbereitung
Aufbereitung(Pfad.Daten, Pfad.Dunkel, Pfad.Fenster, option.Filter, option.Ent, option.Radius, option.Inte);

%Verschiebungen der Referenz- und Messspektren
Verschiebung(Pfad.Daten);

%Berechenen der Spaltfunktionen für jeden Bereich
Spaltfunktion(Pfad.Daten, Pfad.Theorie348);

%Faltung der Theorie-Spektren
TheorieFaltung = Faltung(Pfad.Ramses, Pfad.Daten, Pfad.Theorie348);

%Temperaturbestimmung
TemperaturFit(TheorieFaltung, Pfad.Daten, option.Ent1, option.SD, option.Bereich);