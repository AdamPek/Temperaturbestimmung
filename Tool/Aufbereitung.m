function Aufbereitung(PfadDaten, Dunkel, FensterPfad, Filter, Ent, Radius, Inte)

AnzahlTage = size(PfadDaten,2);

for Tag = 1:AnzahlTage
    Intens = 0;
    PfadDaten1 = PfadDaten{Tag};
    PfadMess = strcat(PfadDaten1, "\MessDaten");
    PfadRef = strcat(PfadDaten1, "\Referenz");
    Speicherpfad = strcat(PfadDaten1, "\Zwischenergebnisse");
    %Zeit der ersten Messung bestimmen, um nötige Referenzmessung 0 zu
    %bestimmen. In bezug auf dieses Spektrum werden die Messungen
    %verschoben und die Spaltfunktionen bestimmt.
    Dir = dir(PfadMess);
    A = 1;
    while Dir(A).bytes == 0
       A = A+1;
    end
    
    Datei = Dir(A).name;
    PfadMess0 = strcat(PfadMess, "\", Datei);
    Mess0 = readimx(char(PfadMess0));
    ZeitMess0 = datetime(Mess0.Attributes{2,1}.Value); 

    Dir = dir(PfadRef);
    Anzahl = numel(Dir);
    countRef = 0;
    
    for i=1:Anzahl
       if  Dir(i).bytes > 0
            Datei = Dir(i).name;
            Pfad2 = strcat(PfadRef, "\", Datei);
            Messung = readimx(char(Pfad2));
            ZeitRef = datetime(Messung.Attributes{2,1}.Value); 
            Diff0(i) = ZeitMess0-ZeitRef;
            if Diff0(i)<0 && Diff0(i-1)>0
               countRef0 = countRef;
            end
       end
       countRef = countRef+1;
    end
    
    %Buckel bestimmen
    
    DunkelBild = readimx(char(Dunkel));
    DunkelBild = DunkelBild.Frames{1,1}.Components{1,1}.Planes{1,1};
    DateiRef0 = Dir(countRef0).name;
    PfadRef0 = strcat(PfadRef, "\", DateiRef0);
    Messung = readimx(char(PfadRef0));
    ZeitRef0 = datetime(Messung.Attributes{2,1}.Value);
    Mess = Messung.Frames{1,1}.Components{1,1}.Planes{1,1};
    Mess = Mess-DunkelBild;
    
    if Filter == 2
       Mess = movmean(Mess,Radius);   
    end
    
    if Filter == 3
        Mess=imgaussfilt(Mess,Radius);
    end
    
    Pixel1 = size(Mess, 1);
    Pixel2 = size(Mess, 2);
    Aufbereitet1=zeros(Pixel1, Pixel2);
    Untergrund = zeros(Pixel1, Pixel2);

    for i=1:Pixel1
        M = Mess(i,:);
        y0 = mean(M(:,73:113));
        y1 = mean(M(:,248:288));
        for x=73:288
            Untergrund(i, x) =(y0-y1)/(93-268)*(x-93)+y0;
        end

        Aufbereitet1(i,:) = M-Untergrund(i,:);
    end
    
    %
    Buckel = mean(Untergrund,2);

    %Aufbereitung der Referenz-Messungen
    Dir = dir(PfadRef);
    Anzahl = numel(Dir);
    Ordner = regexp(PfadRef,'\','split');
    Ordner = Ordner(size(Ordner,2));
    Ordner = strcat(Ordner, " aufbereitet");
    OrdnerPfad = strcat(Speicherpfad, "\", Ordner);
    mkdir (OrdnerPfad);
    ZeitDiff=zeros(512,1);
    count = 1;
    k=1;

    DunkelBild = readimx(char(Dunkel));
    DunkelBild = DunkelBild.Frames{1,1}.Components{1,1}.Planes{1,1};

    Fenster = readtable(FensterPfad);
    Fenster = Fenster.Variables;
    
    for j = countRef0:Anzahl
        if Dir(j).bytes > 0

            Datei = Dir(j).name;
            Pfad2 = strcat(PfadRef, "\", Datei);
            Messung = readimx(char(Pfad2));


            Mess = Messung.Frames{1,1}.Components{1,1}.Planes{1,1};

            Mess = Mess-DunkelBild;
            for i=1:Pixel1
                Mess(i,:) = Mess(i,:)./Fenster.';
            end


            [Aufbereitet, ~, ~] = Untergrundabzug(Mess, Buckel, Filter, Radius, Pixel1, Pixel2);

                
            Zeit = datetime(Messung.Attributes{2,1}.Value);            
            ZeitDiff(1) = minutes(Zeit - ZeitRef0);

            TableZeit = array2table(ZeitDiff);
            TableZeit.Properties.VariableNames="Zeit[min]";

            Bereich1 = sum(Aufbereitet(35:122,:),1);
            Bereich1 = array2table(Bereich1.');
            Bereich1.Properties.VariableNames="Bereich1";

            Bereich2 = sum(Aufbereitet(123:210,:),1);
            Bereich2 = array2table(Bereich2.');
            Bereich2.Properties.VariableNames="Bereich2";

            Bereich3 = sum(Aufbereitet(211:298,:),1);
            Bereich3 = array2table(Bereich3.');
            Bereich3.Properties.VariableNames="Bereich3";

            Bereich4 = sum(Aufbereitet(299:386,:),1);
            Bereich4 = array2table(Bereich4.');
            Bereich4.Properties.VariableNames="Bereich4";

            Bereich5 = sum(Aufbereitet(387:474,:),1);
            Bereich5 = array2table(Bereich5.');
            Bereich5.Properties.VariableNames="Bereich5";


            Table = [Bereich1, Bereich2, Bereich3, Bereich4, Bereich5, TableZeit];

            Speicherpfad1 = strcat(Speicherpfad, "\", Datei);
            [Speicherpfad2, SpeicherName, ~] = fileparts(Speicherpfad1);
            writetable(Table, strcat(OrdnerPfad,"\",SpeicherName, ".xlsx"));
            count = count+1;
        else
            k = k+1;
        end

    end

    %Aufbereitung der Messungen

    Dir = dir(PfadMess);
    Anzahl = numel(Dir);
    Ordner = regexp(PfadMess,'\','split');
    Ordner = Ordner(size(Ordner,2));
    Ordner = strcat(Ordner, " aufbereitet");
    OrdnerPfad = strcat(Speicherpfad, "\", Ordner);
    mkdir (OrdnerPfad);
    count = 1;

    DunkelBild = readimx(char(Dunkel));
    DunkelBild = DunkelBild.Frames{1,1}.Components{1,1}.Planes{1,1};

    Mess1 = {};
    ZeitDiff = {};
    for j = 1:Anzahl
        if Dir(j).bytes > 0
            Datei = Dir(j).name;
            Pfad2 = strcat(PfadMess, "\", Datei);
            Messung = readimx(char(Pfad2));


            Mess = Messung.Frames{1,1}.Components{1,1}.Planes{1,1};
            MessB = sum(Mess(150:350, :)); %Messung im Bereich 1.5cm-3.5cm
            MessHoch = max(MessB); %Hoochpunkt der Messung B
            MessTief = mean(MessB(300:330));  %Durchschnittlicher Wert in Tiefen Bereich der Messung  (262.9901 bis 263.6288 WZ)
            Intens(count) = MessHoch/MessTief;
            Mess = double(Mess);
            Mess = Mess-DunkelBild;            
            for i=1:Pixel1
                Mess(i,:) = Mess(i,:)./Fenster.';
            end


            [Aufbereitet, Untergrund, A] = Untergrundabzug(Mess, Buckel, Filter, Radius, Pixel1, Pixel2);

            
            Mess1{j} = Aufbereitet;
            count = count+1; 
            Zeit2 = datetime(Messung.Attributes{2,1}.Value);
            ZeitDiff{j} = minutes(Zeit2 - ZeitRef0);
            
        end
    end
    
    Mittel = 0;
    count = 0;
    for j = 1:size(Intens,2)
        Mittel = Mittel + Intens(j);
        if Intens(j) > 0
            count = count+1;
        end
    end
    
    Mittel = Mittel/count;
    count = 1;

    Inte1 =  1-Inte/100; 
    
    for j = 1:Anzahl
        
        if Dir(j).bytes > 0
            
            In = (Mittel-Intens(count))/Mittel;
            
            if Ent == 1
                if In < Inte1
                    Datei = Dir(j).name;
                    Pfad2 = strcat(PfadMess, "\", Datei);
                    Aufbereitet = Mess1{j};
                    ZeitDiff1 = zeros(512,1);

                    ZeitDiff1(1) = ZeitDiff{j};
                    TableZeit = array2table(ZeitDiff1);
                    TableZeit.Properties.VariableNames="Zeit[min]";

                    Bereich1 = sum(Aufbereitet(35:122,:),1);
                    Bereich1 = array2table(Bereich1.');
                    Bereich1.Properties.VariableNames="Bereich1";

                    Bereich2 = sum(Aufbereitet(123:210,:),1);
                    Bereich2 = array2table(Bereich2.');
                    Bereich2.Properties.VariableNames="Bereich2";

                    Bereich3 = sum(Aufbereitet(211:298,:),1);
                    Bereich3 = array2table(Bereich3.');
                    Bereich3.Properties.VariableNames="Bereich3";

                    Bereich4 = sum(Aufbereitet(299:386,:),1);
                    Bereich4 = array2table(Bereich4.');
                    Bereich4.Properties.VariableNames="Bereich4";

                    Bereich5 = sum(Aufbereitet(387:474,:),1);
                    Bereich5 = array2table(Bereich5.');
                    Bereich5.Properties.VariableNames="Bereich5";


                    Table = [Bereich1, Bereich2, Bereich3, Bereich4, Bereich5, TableZeit];

                    Speicherpfad1 = strcat(Speicherpfad, "\", Datei);
                    [~, SpeicherName, ~] = fileparts(Speicherpfad1);
                    writetable(Table, strcat(OrdnerPfad,"\",SpeicherName, ".xlsx"));
                end
            end
            if Ent==0
                    Datei = Dir(j).name;
                    Pfad2 = strcat(PfadMess, "\", Datei);
                    Aufbereitet = Mess1{j};
                    ZeitDiff1 = zeros(512,1);

                    ZeitDiff1(1) = ZeitDiff{j};
                    TableZeit = array2table(ZeitDiff1);
                    TableZeit.Properties.VariableNames="Zeit[min]";

                    Bereich1 = sum(Aufbereitet(35:122,:),1);
                    Bereich1 = array2table(Bereich1.');
                    Bereich1.Properties.VariableNames="Bereich1";

                    Bereich2 = sum(Aufbereitet(123:210,:),1);
                    Bereich2 = array2table(Bereich2.');
                    Bereich2.Properties.VariableNames="Bereich2";

                    Bereich3 = sum(Aufbereitet(211:298,:),1);
                    Bereich3 = array2table(Bereich3.');
                    Bereich3.Properties.VariableNames="Bereich3";

                    Bereich4 = sum(Aufbereitet(299:386,:),1);
                    Bereich4 = array2table(Bereich4.');
                    Bereich4.Properties.VariableNames="Bereich4";

                    Bereich5 = sum(Aufbereitet(387:474,:),1);
                    Bereich5 = array2table(Bereich5.');
                    Bereich5.Properties.VariableNames="Bereich5";


                    Table = [Bereich1, Bereich2, Bereich3, Bereich4, Bereich5, TableZeit];

                    Speicherpfad1 = strcat(Speicherpfad, "\", Datei);
                    [~, SpeicherName, ~] = fileparts(Speicherpfad1);
                    writetable(Table, strcat(OrdnerPfad,"\",SpeicherName, ".xlsx"));
                
            end
            count = count+1;
        end

    end

end