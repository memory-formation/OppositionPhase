function [ data ] = ReadArduinoPort()
%  ReadParPort
%    Reads Arduino port interface.
%
%  Usage:
%    >> value = ReadArduinoPort;
%
%  V_0.9b - 2018-05
%  Laurent Hugueville (laurent.hugueville@upmc.fr)


global h_arduinoport;
global ArduinoPortOK;

if ~ArduinoPortOK
    fprintf( 'CloseArduinoPort : Arduino port not initialized.\n' );
    return;
end

% if LuminaOK ~= 99
%     data = IOPort( 'Read', h_arduinoport );
%     if isempty( data )
%         data = 0;
%     else
%         data = data - 48;
%         IOPort( 'Purge', h_arduinoport );
%     end
% else
    data = 0;
% end

end
