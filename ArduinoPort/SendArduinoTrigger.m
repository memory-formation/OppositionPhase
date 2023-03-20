function SendArduinoTrigger( value, duration )
%  SendArduinoTrigger
%    Write data to Arduino port interface.
%
%  Usage:
%    >> SendArduinoTrigger( value[, duration] );
%
%  Argument:
%    i) value - trigger value in [0-255] range
%    i) duration - trigger duration in s (default: 0.005s)
%
%  V_0.9b - 2018-05
%  Laurent Hugueville (laurent.hugueville@upmc.fr)


global ArduinoPortOK;

if ~ArduinoPortOK
    warning( 'SendArduinoTrigger : Function unavailable, Arduino port not initialized!' );
    return;
end

if ~exist( 'duration', 'var' )
    duration = .005;
end

if duration < 0
    WriteArduinoPort( 255 );
    duration = abs( duration );
else
    WriteArduinoPort( value );
end
WaitSecs( duration );
WriteArduinoPort( 0 );

end
