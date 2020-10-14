function fc = mipconstants(name,unit)
% MIPCONSTANTS  Fundamental constants in Physics
% From the refence Intermediate Physics for Medicine and Biology
% Hobbie, Russell K., Roth, Bradley J., 1997, Springer-Verlag, New York, 3rd
% Edition]
%     case 'plank'
%         if unit == 'ev'
%             fc = 4.136e-15; % eV (electron volt)
%         elseif 'joule'
%             fc = 6.626074e-34; % Js
%         end
%     case 'light speed'
%         fc = 2.997925e8; % m/s
%     case 'graviation'
%         fc = 6.672e-11 % N-m^2/kg^2
%     case 'electron mass'
%         fc = 9.1019390e-31 % Kg
%     case 'electron energy'
%         fc = 8.187114e-14 % Joule (J)
%     case 'Avagadro'
%         fc = 6.022137e23 % 1/mol
%     case 'Boltzman'
%         fc = 1.380658e-23 % J/Kelvin
%     case 'Electron charge'
%         fc = 1.602177e-19 % Coulomb (C)
%     case 'Proton mass'
%         fc = 1.672623e-27 % Kg

%
%   FC = MIPCONSTANTS(NAME,UNIT)
%
%   This function provides some of the fundamental constants in Physics 
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox


switch name
    case 'plank'
        if unit == 'ev'
            fc = 4.136e-15; % eV (electron volt)
        elseif 'joule'
            fc = 6.626074e-34; % Js
        end
    case 'light speed'
        fc = 2.997925e8; % m/s
    case 'graviation'
        fc = 6.672e-11 % N-m^2/kg^2
    case 'electron mass'
        fc = 9.1019390e-31 % Kg
    case 'electron energy'
        fc = 8.187114e-14 % Joule (J)
    case 'Avagadro'
        fc = 6.022137e23 % 1/mol
    case 'Boltzman'
        fc = 1.380658e-23 % J/Kelvin
    case 'Electron charge'
        fc = 1.602177e-19 % Coulomb (C)
    case 'Proton mass'
        fc = 1.672623e-27 % Kg
end

