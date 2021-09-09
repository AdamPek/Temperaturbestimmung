function TemperaturFit(TheorieFaltungGesamt, PfadDaten, Ent1, SD, Bereich)

AnzahlTage = size(PfadDaten,2);
countTemp = 1;
countTempHA = 1;
for Tag = 1:AnzahlTage
    TheorieFaltung = TheorieFaltungGesamt{Tag};
    PfadDaten1 = PfadDaten{Tag};
    PfadMess = strcat(PfadDaten1, "\Zwischenergebnisse\MessDaten aufbereitet verschoben");
    
    Dir = dir(PfadMess);
    Anzahl = numel(Dir);
    count = 0;
    for i=1:Anzahl
       if Dir(i).bytes == 0
       count = count+1;
       end
    end

    % Dieser Code bestimmt die Temperatur einer oder mehrere Messungen in 10
    % Kelvin schritten aus breits aufbereiteten Spektren und entfalteten
    % Theoriefunktionen.

    %Variablen laden:
    T_Start = 500; 
    T_Bereich = 600;
    Intervall = 1; %10 für 10 Kelvin, 1 für 1 Kelvin
    T_Anzahl = T_Bereich/Intervall+1;

    k = Anzahl-count;
    

    %Schleife um Temperatur für jeden Bereich und jede ausgewählte Messung zu
    %bestimmen
    Position = zeros(5, k);
    for x=1:k
            x1 = x+count;
            Datei = Dir(x1).name;
            Name{countTemp} = Datei;
            Messung = strcat(PfadMess, "\", Datei);
            MessData = flip(readtable(Messung));
            MessData = MessData.Variables;
            for j=1:5

                MessDaten = MessData(:,j);
                MessDaten = MessDaten/max(MessDaten);
                [Pix_Links, Pix_Rechts] = Spektralbereich(MessDaten, Bereich);

                for i=1:T_Anzahl
                  A(i,1) = T_Start + (i-1)*Intervall;
                  RamsesData1 = TheorieFaltung{j};
                  RamsesData = RamsesData1(:,i);
                  B(Pix_Links:Pix_Rechts,i) = (RamsesData(Pix_Links:Pix_Rechts) - MessDaten(Pix_Links:Pix_Rechts)).^2; %Fehlerquadrat zwischen Ramses und Messung
                end

                C = sum(B); %Summe der Fehlerquadrate
                D = find(C == min(C)); 
                Position(j,countTemp) = D;

                Temperatur = T_Start + Intervall*(D-1); %Temperatur mit dem kleinsten Fehlerquadrat
                E(j,countTemp) = Temperatur;
                
            end
            countTemp = countTemp+1;

    end


    end

TempHA = E;

%Entfernen von Ausreißer-Temperaturen
if Ent1 == 1
    TempHA = filloutliers(TempHA,NaN, "mean", 'ThresholdFactor', SD);
end

%Temperatur-Plot
Tgemittelt2 = mean(TempHA, 2, "omitnan");
Tmittel = mean(Tgemittelt2);
unten = Tmittel - 150;
oben = Tmittel + 150;
Standardabweichung = std(TempHA.', "omitnan");
Standardabweichung1 = 0.5*Standardabweichung;
errorbar(1:5, Tgemittelt2, Standardabweichung1)
xlabel("Bereich");
ylabel("Temperatur [K]");
title("Gemittelte Temperatur über Bereiche")
xlim([0 6])
ylim([unten, oben])

TemperaturFinal = Tgemittelt2;
%Speichern in Excel
Table = array2table(TempHA);
Table.Properties.VariableNames = string(Name);
% TableRmse = array2table(RMSE);
% TableRmse.Properties.VariableNames = "RMSE " + string(Name);
TableMittel = array2table(Tgemittelt2);
TableMittel.Properties.VariableNames = "Temperatur gemittelt";

Bereiche = {"1", "2", "3", "4", "5"};
Bereiche = Bereiche.';
Bereiche = cell2table(Bereiche);
Bereiche.Properties.VariableNames = "Bereich";

StandardabweichungT = array2table(Standardabweichung.');
StandardabweichungT.Properties.VariableNames = "Standadabweichung";

Table1 = [Bereiche, Table, TableMittel, StandardabweichungT];


[file,path] = uiputfile();
Speicherpfad = strcat(path,file, ".xlsx")
writetable(Table1, Speicherpfad)

