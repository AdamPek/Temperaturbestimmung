function Pfad = SpeicherPfad()

%Dunkelbild
Pfad.Dunkel = "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Dunkelbild\B00001_avg.IM7";
%Fenstereinfluss
Pfad.Fenster = "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Transmission\TransmissionEndgueltig.txt";
%Simulierte Spektren
Pfad.Ramses = "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Theoriefunktionen\TheorieSpektren 500-1100K_1KSchritte.xlsx";
%Simuliertes Spektrum bei 348 Kelvin für Spaötfunktionsbestimmung
Pfad.Theorie348 = "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Theoriefunktionen\TheorieSpektrum348K.xlsx";
% Ordner mit MessDaten und Referenz für den jeweiligen Tag
Pfad.Daten=["C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Messdaten\Messphase Juni\2020_06_16"...
    "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Messdaten\Messphase Juni\2020_06_17"...
    "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Messdaten\Messphase Juni\2020_06_18"...
    "C:\Users\adamp\OneDrive\Desktop\BA\Temperaturbestimmungstool\Daten\Messdaten\Messphase Juni\2020_06_19"];