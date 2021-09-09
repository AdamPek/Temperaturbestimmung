function [Aufbereitet, Untergrund, A] = Untergrundabzug(Mess, Buckel, Filter, Radius, Pixel1, Pixel2)
    

    if Filter == 2
       Mess = movmean(Mess,Radius);   
    end
    
    if Filter == 3
        Mess=imgaussfilt(Mess,Radius);
    end
    Aufbereitet1=zeros(512);
    Untergrund = zeros(512);
    
for i=1:Pixel1
    M = Mess(i,:);
    y0 = mean(M(:,73:113));
    y1 = mean(M(:,248:288));
    for y=73:288
        Untergrund(i, y) =(y0-y1)/(93-268)*(y-93)+y0;
    end
    
    Aufbereitet1(i,:) = M-Untergrund(i,:);
end
A = Aufbereitet1;
for i=1:Pixel2
    Aufbereitet1(:,i) = Aufbereitet1(:,i)./Buckel;
end

    Aufbereitet = Aufbereitet1;
    
end
