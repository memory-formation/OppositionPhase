function WriteArduinoPort( data, mask )
%  WriteArduinoPort
%    Write data to Arduino port interface.
%
%  Usage:
%    >> WriteArduinoPort(data[, mask]);
%
%  Argument:
%    i) data - data in [0-255] range
%    i) mask - mask to be applied to data (default: 255)
%
%  V_0.9b - 2018-05
%  Laurent Hugueville (laurent.hugueville@upmc.fr)


global h_arduinoport;
global ArduinoPortOK;

if ~ArduinoPortOK
    error( 'WriteArduinoPort : Parallel port not initialized.' );
end

if nargin < 1
    error( 'WriteArduinoPort : Not enough input arguments.' );
end
if ~exist( 'mask', 'var' )
    mask = 255;
end

if ArduinoPortOK ~= 99
    IOPort( 'Write', h_arduinoport, uint8( bitand( data, mask ) ) );
end

end
