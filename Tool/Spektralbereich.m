function [links, rechts] = Spektralbereich(Messung, Bereich)

[maxValue, indexOfMax] = max(Messung);
value = Bereich/100 * maxValue;
min1 = indexOfMax - 50;
max1 = indexOfMax + 50;
% Find 25% point on left
for index = indexOfMax : -1 : min1
    if Messung(index) < value
        leftIndex = index;
        break;
    end
end
% Find 25% point on right
for index = indexOfMax : 1 : max1
    if Messung(index) < value
        rightIndex = index;
        break;
    end
end

links = leftIndex;
rechts = rightIndex;

end