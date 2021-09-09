function TheorieFaltungGesamt = Faltung(PfadRamses, PfadDaten, PfadTheorie348)

AnzahlTage = size(PfadDaten,2);
TheorieFaltungGesamt = {};

T348roh = readtable(PfadTheorie348);
T348roh = T348roh.Variables;
for Tag = 1:AnzahlTage
    
    PfadDaten1 = PfadDaten{Tag};
    PfadSpalt = strcat(PfadDaten1, "\Zwischenergebnisse\Spaltfunktion");
    PfadRef1 = strcat(PfadDaten1, "\Zwischenergebnisse\Referenz aufbereitet verschoben");
    Dir = dir(PfadRef1);
    count = 1;    
    TheorieFaltung = {};
    while Dir(count).bytes == 0
        count = count+1;
    end
    
    RefName = Dir(count).name;
    PfadRef = strcat(PfadRef1, "\", RefName);
    

    %Theoriefunktionen(Ramses), Spaltfunktionen, Referenzmessung für jeden
    %Bereich oder Temperatur laden


    Dir = dir(PfadSpalt);
    Anzahl = numel(Dir);
    count = 0;
    for i=1:Anzahl
       if Dir(i).bytes == 0
       count = count+1;
       end
    end
    Raw = readtable(strcat(PfadRamses));
    Theorie = Raw.Variables;

    Referenz = readtable(strcat(PfadRef));
    Referenz = Referenz.Variables;

    TheorieFaltung = {};
    Size2 = size(Theorie,2);
    Size1 = size(Theorie,1);
    %Schleife faltet Ramses-Daten für jeden Bereich
    for i=1:5
        x = count + i;
        Datei = Dir(x).name;
        SpaltPfad = strcat(PfadSpalt, "\", Datei);    
        Spalt = readtable(SpaltPfad);
        Spaltfunktion = Spalt.Variables;
        Spalt = Spaltfunktion(:,1);
        T348 = conv(T348roh,Spalt,"same");

        A = zeros(Size1, Size2);
        for j=1:Size2
            
            A(:,j) = conv(Theorie(:,j), Spalt, "same");

            A(:,j) = A(:,j)/max(A(:,j));
            
        end
        
        %Versetzung zwischen gefalteten Theoriemessungen und Referenzmessung
        Ref = flip(Referenz(:,i));
        RefMax = find(Ref == max(Ref));
        B = T348;
        
        BMax = find(B == max(B));
        Dif = RefMax - BMax;
        if Dif > 0
            A = [zeros(Dif, size(A,2)); A];
            A = A(1:Size1, :);
        end
        if Dif < 0
            Dif = -Dif;
            A = [A; zeros(Dif, size(A,2))];
            A = A(1+Dif:Dif+Size1,:);
        end
        TheorieFaltung{i} = A; 
    

    end  
    
    TheorieFaltungGesamt{Tag} = TheorieFaltung;
end


