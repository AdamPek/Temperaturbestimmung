function Spaltfunktion(PfadDaten, PfadTheorie)

AnzahlTage = size(PfadDaten,2);
for Tag = 1:AnzahlTage
    
    PfadDaten1 = PfadDaten{Tag};
    PfadRef1 = strcat(PfadDaten1, "\Zwischenergebnisse\Referenz aufbereitet verschoben");
    Speicherpfad = strcat(PfadDaten1, "\Zwischenergebnisse\Spaltfunktion");
    SP = isfolder(Speicherpfad); %Überprüft, ob bereits ein Ordner mit Spaltfunktion existiert
    
    if SP==0
        Dir = dir(PfadRef1);
        count = 1;    
        while Dir(count).bytes == 0
            count = count+1;
        end
        RefName = Dir(count).name;
        PfadRef = strcat(PfadRef1, "\", RefName);

        
        mkdir(Speicherpfad);

        for h=1:5
            Ref = readtable(PfadRef);
            Theorie = readtable(PfadTheorie);
            Ref = Ref.Variables;
            Ref = Ref(:,h);
            Ref = Ref/max(Ref);
            Ref = flip(Ref);
            Theorie = Theorie.Variables;
            H = find(Theorie == max(Theorie));
            L = H-120;
            R = H+120;
            Theorie = Theorie(L:R);
            

            %Test Spaltfunktionsbestimmung Bereich1
            x = 1:1:110;

            % % a1 = 0.616;
            % b1 = 55.43;
            % c1 = 6.869;
            % % a2 = 0.09126;
            % b2 = 53.58;
            % c2 = 14.58;

            a01 = 0.7;
            a02 = 0.2;
            b01 = 57.5;
            b02 = 55.5;
            c01 = 5.5;
            c02 = 12;
            F = {};
            Param = {};
            count1 = 1;
            for i = 1:5
                a1 = a01 - 0.2 + (i-1)*0.1;

                for j = 1:5
                    a2 = a02 - 0.5 + (j-1)*0.1;

                    for k=1:6
                        b1 = b01 - 0.5 + (k-1)*0.15;

                        for l=1:6
                            b2 = b02 - 0.5 + (l-1)*0.15;


                            for m=1:11
                                c1 = c01 - 1 + (m-1)*0.4;

                                for n=1:11
                                    c2 = c02 - 1  + (n-1)*0.4;
                                    Gauss1 = @(x) a1 * exp( - ((x-b1)/c1)^2)...
                                    + a2 * exp( - ((x-b2)/c2)^2);
                                    Gauss  = arrayfun(Gauss1,x);

                                    Konv = conv(Theorie, Gauss);
                                    Konv = Konv/max(Konv);

                                    Hoch1 = find(Konv==max(Konv));
                                    Hoch2 = find(Ref==max(Ref));
                                    links1 = Hoch1-20;
                                    rechts1 = Hoch1+20;
                                    links2 = Hoch2-20;
                                    rechts2 = Hoch2+20;

                                    Konv = Konv(links1:rechts1);
                                    Ref1 = Ref(links2:rechts2);

                                    F{count1} = immse(Konv, Ref1);
                                    Param{count1} = [a1, a2, b1, b2, c1, c2];
                                    count1 = count1 + 1;

                                end
                            end

                        end
                    end
                end
            end


            FF = cell2mat(F);
            Minimum = find(FF == min(FF))
            Parameter1 = Param{Minimum(1)}
            Abweichung = FF(Minimum)

            a11 = Parameter1(1);
            a12 = Parameter1(2);
            b11 = Parameter1(3);
            b12 = Parameter1(4);
            c11 = Parameter1(5);
            c12 = Parameter1(6);

            for i = 1:5
                a1 = a11 - 0.04 + (i-1)*0.02;

                for j = 1:5
                    a2 = a12 - 0.04 + (j-1)*0.02;

                    for k=1:6
                        b1 = b11 - 0.086 + (k-1)*0.025;

                        for l=1:6
                            b2 = b12 - 0.086 + (l-1)*0.025;


                            for m=1:11
                                c1 = c11 - 0.1 + (m-1)*0.04;

                                for n=1:11
                                    c2 = c12 - 0.1  + (n-1)*0.04;
                                    Gauss1 = @(x) a1 * exp( - ((x-b1)/c1)^2)...
                                    + a2 * exp( - ((x-b2)/c2)^2);
                                    Gauss  = arrayfun(Gauss1,x);

                                    Konv = conv(Theorie, Gauss);
                                    Konv = Konv/max(Konv);

                                    Hoch1 = find(Konv==max(Konv));
                                    Hoch2 = find(Ref==max(Ref));
                                    links1 = Hoch1-20;
                                    rechts1 = Hoch1+20;
                                    links2 = Hoch2-20;
                                    rechts2 = Hoch2+20;

                                    Konv = Konv(links1:rechts1);
                                    Ref1 = Ref(links2:rechts2);

                                    F{count1} = immse(Konv, Ref1);
                                    Param{count1} = [a1, a2, b1, b2, c1, c2];
                                    count1 = count1 + 1;

                                end
                            end

                        end
                    end
                end
            end

            FF = cell2mat(F);
            Minimum = find(FF == min(FF));
            Parameter2 = Param{Minimum(1)};
            Abweichung(h) = FF(Minimum);

            a1 = Parameter2(1);
            a2 = Parameter2(2);
            b1 = Parameter2(3);
            b2 = Parameter2(4);
            c1 = Parameter2(5);
            c2 = Parameter2(6);
            Gauss1 = @(x) a1 * exp( - ((x-b1)/c1)^2)...
                     + a2 * exp( - ((x-b2)/c2)^2);
            Gauss  = arrayfun(Gauss1,x);

            Table = array2table(Gauss.');

            Speicherpfad1 = strcat(Speicherpfad, "\", string(h), ".xlsx");

            writetable(Table, Speicherpfad1);
        end
        Speicherpfad2 = strcat(PfadDaten1, "\Zwischenergebnisse\GegencheckSpaltfunktion.xlsx");
        Table = array2table(Abweichung);
        Table.Properties.VariableNames=["Bereich 1", "Bereich 2", "Bereich 3","Bereich 4", "Bereich 5"];
        writetable(Table, Speicherpfad2);
    end
end