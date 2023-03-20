function CloseArduinoPort()
%  CloseArduinoPort
%    Close Arduino parallel port interface.
%
%  Usage:
%    >> CloseArduinoPort;
%
%  V_0.9b - 2018-05
%  Laurent Hugueville (laurent.hugueville@upmc.fr)


global h_arduinoport;
global ArduinoPortOK;

if ~ArduinoPortOK
    fprintf( 'CloseArduinoPort : Arduino port not initialized.\n' );
    return;
end

if ArduinoPortOK ~= 99
    IOPort( 'Close', h_arduinoport );
end

clear h_arduinoport;
ArduinoPortOK = 0;

fprintf( 'CloseArduinoPort : Arduino port closed.\n' );

end
