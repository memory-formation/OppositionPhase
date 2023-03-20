function [buttons] = ReadLuminaButtons()
%  ReadLuminaButtons
%    Reads buttons status from Lumina interface.
%
%  Usage:
%    >> [buttons] = ReadLuminaButtons;
%
%  Argument:
%    o) buttons - button status (0/1 if inactive/active)
%
%  V_0.9 - 2014-07
%  Laurent Hugueville (laurent.hugueville@upmc.fr)


global h_lumina;
if isempty(h_lumina)
    error('Lumina interface not open.');
end

data = IOPort('Read', h_lumina);

if isempty(data)
    data = 0;
end

% buttons = zeros(1,5);
buttons = [bitget(data, 1), bitget(data, 2), bitget(data, 3), bitget(data, 4), bitget(data, 5)];

end
