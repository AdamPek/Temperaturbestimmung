 function Verschiebung(PfadDaten)

AnzahlTage = size(PfadDaten,2);

for Tag = 1:AnzahlTage
    PfadDaten1 = PfadDaten{Tag};
    Speicherpfad = strcat(PfadDaten1, "\Zwischenergebnisse");
    PfadRef = strcat(PfadDaten1, "\Zwischenergebnisse\Referenz aufbereitet");
    PfadMess = strcat(PfadDaten1, "\Zwischenergebnisse\MessDaten aufbereitet");


    %Daten Laden
    DirRef = dir(PfadRef);
    DirMess = dir(PfadMess);
    DataSets = numel(DirRef);

    %Pfad für verschobene Refs
    OrdnerRef = regexp(PfadRef,'\','split');
    OrdnerRef = OrdnerRef(size(OrdnerRef,2));
    OrdnerRef1 = strcat(OrdnerRef, " verschoben");
    OrdnerRefPfad = strcat(Speicherpfad, "\", OrdnerRef1);
    mkdir (OrdnerRefPfad);

    %Pfad füt verschobene Messungen
    OrdnerMess = regexp(PfadMess,'\','split');
    OrdnerMess = OrdnerMess(size(OrdnerMess,2));
    OrdnerMess1 = strcat(OrdnerMess, " verschoben");
    OrdnerMessPfad = strcat(Speicherpfad, "\", OrdnerMess1);
    assignin('caller','PfadMess',OrdnerMessPfad);
    mkdir (OrdnerMessPfad);

    r = 1;
    while DirRef(r).bytes == 0
        r = r+1;
    end

    DateiRef0 = DirRef(r).name;
    %VerschiebungsMatrix für Referenzen Bestimmen

    TableRef0 = readtable(strcat(PfadRef,"\", DateiRef0));
    VerschiebungsMatrixRef = zeros(DataSets, 6);

    for x=r:DataSets


        for y=1:5
            Ref0 = TableRef0.Variables;
            Ref0 = Ref0(:,y);
            Ref0 = Ref0/max(Ref0);
            Hochpunkt = find(Ref0==1);
            Pix_Links = Hochpunkt - 15;
            Pix_Rechts = Hochpunkt + 15;

            Ref0 = Ref0(Pix_Links:Pix_Rechts);
            Ref0I = zeros(1, (size(Ref0, 1)-1)*100+1);
            for i=1:size(Ref0, 1)-1
                for j = 1:100
                    k = (i-1) * 100 +j;
                    Ref0I(k) = Ref0(i) + (Ref0(i+1)-Ref0(i)) * (j-1)/100;
                end
            end
            Ref0I((size(Ref0, 1)-1)*100+1) = Ref0(i+1);


            TableRef = readtable(strcat(PfadRef, "\", DirRef(x).name));

            Ref = TableRef.Variables;
            Ref = Ref(:,y);
            Ref = Ref/max(Ref);
            Ref = Ref(Pix_Links:Pix_Rechts);
            RefI = zeros(1, (size(Ref, 1)-1)*100+1);
            % Interpolieren um Verschiebung exakter zu bestimmen

            for i=1:size(Ref, 1)-1
                for j = 1:100
                    k = (i-1) * 100 +j;
                    RefI(k) = Ref(i) + (Ref(i+1)-Ref(i)) * (j-1)/100;
                end
            end
            RefI((size(Ref0, 1)-1)*100+1) = Ref0(i+1);

            Pix_Links1 = 200;
            Pix_Rechts1 = 2801;
            Fehler = zeros(201,1);

            %Verschiebung mit kleinstem Fehler wählen
            for k = 1:201
                Verschiebung = k - 101;
                RefShifted = circshift(RefI, Verschiebung);
                Fehler(k) = immse(RefShifted(Pix_Links1:Pix_Rechts1), Ref0I(Pix_Links1:Pix_Rechts1));        
            end

            Verschiebung = -1 + (find(Fehler == min(Fehler))-1) * 0.01;
            VerschiebungsMatrixRef(x,y+1) = Verschiebung; 


        end
        Zeit = TableRef(1, "Zeit_min_");
        VerschiebungsMatrixRef(x,1) = Zeit.Variables;

    end
    VerschiebungsMatrixRef1 = VerschiebungsMatrixRef(r:end, :);
    TableVerschiebungsMatrix = array2table(VerschiebungsMatrixRef1);
    writetable(TableVerschiebungsMatrix, strcat(OrdnerRefPfad, "\", OrdnerRef, " VerschiebungsMatrixMess.xlsx"));


    %Referenzen verschieben

    Refverschoben = {};
    for x=r:DataSets
        for y=1:5
            Verschiebung = uint8(VerschiebungsMatrixRef(x,y)*100);
            DateiRef =  DirRef(x).name;       
            TableRef = readtable(strcat(PfadRef, "\", string(DateiRef)));
            Ref = TableRef.Variables;
            Ref = Ref(:,y);
            Ref = Ref/max(Ref);
            counter = 1;



            for i=1:size(Ref, 1)-1
                for j = 1:100
                    k = (i-1) * 100 +j;
                    RefI(k) = Ref(i) + (Ref(i+1)-Ref(i)) * (j-1)/100;
                    counter = counter+1;
                end
            end
           RefI(counter) = Ref(512);
           RefI = circshift(RefI, Verschiebung);

           Refverschoben{x,y} = RefI(:,1:100:end);
        end
    end
    RefGemittelt = zeros(5, 512);
    for i=1:5
        for j=r:DataSets
            RefGemittelt(i,:) = RefGemittelt(i,:) + Refverschoben{j,i}; 
        end

    end
    RefGemittelt = RefGemittelt./(DataSets-r+1);
    SpeicherpfadRef = strcat(OrdnerRefPfad, "\Ref_gemittelt.xlsx");
    Table = array2table(RefGemittelt.');
    writetable(Table, SpeicherpfadRef);

    %Speichere Refverschoben in Tabelle
    count = 0;
    for x=r:DataSets
        for y=1:5
            if y==1
                Table = array2table(Refverschoben{x,y}.');
                Table.Properties.VariableNames = "Bereich 1";
            else
                Table0 = array2table(Refverschoben{x,y}.');
                Table0.Properties.VariableNames = "Bereich " + string(y);
                Table = [Table, Table0];

            end
        end
        SpeicherpfadRef = strcat(OrdnerRefPfad, "\", Datei = DirRef(x).name);
        writetable(Table, SpeicherpfadRef);
        if count == 0
            assignin('caller','PfadRef',SpeicherpfadRef);
        end
        count = 1;
    end

    %Verschiebungsmatrix für Messung bestimmen und Messung verschieben
    TimeRef = VerschiebungsMatrixRef1(:,1);



    Messverschoben = {};
    DataSetsMess = numel(DirMess);

    s = 1;
    while DirMess(s).bytes == 0
        s = s+1;
    end

    VerschiebungMess = zeros(DataSetsMess-s+1, 5);
    for x=s:DataSetsMess

        p = 0;
        count = 1;    
        while p==0
            MessungName = DirMess(x).name;
            Messung = readtable(strcat(PfadMess, "\", MessungName));
            Messung = Messung.Variables;
            TimeMess = Messung(1,6);
            Differenz = TimeRef(count) - TimeMess;
            if Differenz > 0
                p=1;
            else
                count = count + 1;
            end
        end

        for y=1:5
            VerschiebungMess(x,y) = round(VerschiebungsMatrixRef1(count-1,y+1) + ...
                (VerschiebungsMatrixRef1(count,y+1)-VerschiebungsMatrixRef1(count-1,y+1)) ...
                *(TimeMess - TimeRef(count-1))/(TimeRef(count)-TimeRef(count-1)),2);

            Verschiebung = int8(VerschiebungMess(x,y)*100);


            MessI = zeros(1, (size(Messung, 1)-1)*100+1);
            Mess = Messung(:,y);

            counter = 1;


            for i=1:size(Mess, 1)-1
                for j = 1:100
                    k = (i-1) * 100 +j;
                    MessI(k) = Mess(i) + (Mess(i+1)-Mess(i)) * (j-1)/100;
                    counter = counter+1;
                end
            end
           MessI(counter) = Mess(512);
           MessI = circshift(MessI, Verschiebung);

           Messverschoben{x,y} = MessI(:,1:100:end).';
        end

    end


    Table = array2table(VerschiebungMess(s:end, :));
    Table.Properties.VariableNames = ["Bereich 1", "Bereich 2", "Bereich 3", "Bereich 4", "Bereich 5"]
    SpeicherpfadMess = strcat(OrdnerMessPfad, "\", "VerschiebungsMatrix.xlsx");
    % writetable(Table, SpeicherpfadMess)
    %Speichere Messverschoben in Tabelle
    for x=s:DataSetsMess
        for y=1:5
            if y==1
                Table = array2table(Messverschoben{x,y});
                Table.Properties.VariableNames = "Bereich 1";
            else
                Table0 = array2table(Messverschoben{x,y});
                Table0.Properties.VariableNames = "Bereich " + string(y);
                Table = [Table, Table0];

            end
        end
        SpeicherpfadMess = strcat(OrdnerMessPfad, "\", Datei = DirMess(x).name);
        writetable(Table, SpeicherpfadMess)
    end


end