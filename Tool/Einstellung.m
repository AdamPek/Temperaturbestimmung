function option = Einstellung()

%Filter für die Aufbereitung:
% 1: Kein Filter
% 2: 1-D moving Average
% 3: Gauss-Filter
option.Filter = 3;

%Radius des Fiters
option.Radius = 3;

%Entfernen von Messungen mit weniger als 10% der durchschnittlichen
%Intensität (1 für aktiviert)
option.Ent = 1;

%Ab wie viel Prozent des durchschnittlich
%Signal-zu-Untergrund-Verhältnisses sollen Messungen entfernt werden?
option.Inte = 90;

%Entfernen von Ausreißer-Werten
option.Ent1 = 1;

%Standardabweichung
option.SD = 1.4;

%Prozentuale Peakhöhe, ab der Spektralbereich gewählt wird
option.Bereich = 50;
