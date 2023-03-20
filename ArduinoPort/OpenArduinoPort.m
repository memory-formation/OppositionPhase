function OpenArduinoPort( comPort )
%  OpenArduinoPort
%    Opens Arduino parallel port interface.
%
%  Usage:
%    >> OpenArduinoPort( 'COM1' );
%
%  V_0.9b - 2018-05
%  Laurent Hugueville (laurent.hugueville@upmc.fr)


global h_arduinoport;
global ArduinoPortOK;

ArduinoPortOK = 0;

if nargin == 0
    comPort = '';
end

if isempty( comPort )
    ArduinoPortOK = 99;
else
    [h_arduinoport, err_msg] = IOPort( 'OpenSerialPort', comPort, 'BaudRate=115200, Parity=None, DataBits=8, StopBits=1' );
%    IOPort( 'ConfigureSerialPort', h_arduinoport, 'BaudRate=9600' );
    IOPort( 'Purge', h_arduinoport );
    ArduinoPortOK = 1;
end

if ~ArduinoPortOK
    error( 'OpenArduinoPort : Arduino port installation to %s failed!', comPort );
else
    if ArduinoPortOK == 99
        fprintf( 'OpenArduinoPort : Using Arduino port in dummy mode.\n' );
    else
        fprintf( 'OpenArduinoPort : Using Arduino port connected to port %s.\n', comPort );
    end
end

WriteArduinoPort( 0 );

end
