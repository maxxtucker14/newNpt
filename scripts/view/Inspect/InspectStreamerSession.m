function InspectStreamerSession(sessionname,channel)
%InspectStreamerSession		Plots data for all trials in a session 
%	InspectStreamerSession(SESSIONNAME,CHANNEL)
%
%	Dependencies: @streamerdata,@streamerdata/Inspect.

s = streamer(sessionname,channel);

Inspect(s)

