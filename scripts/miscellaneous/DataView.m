% DataView - Script to pan through continuous data 
% (trial by trial using the trigger channel)

[data, nc, sr, so, points] = nptReadStreamerFile([session '.' num2str(i,'%04i')]);
subplot(3,1,1)
plot(tms(1:points),data(trigChannel,:))
subplot(3,1,2)
plot(tms(1:tIntervals(i*2-1)+1),datac((triggers(2*i-1))+1 : triggers(2*i)+1),'r')
subplot(3,1,3)
plot(tms(1:points),data(7,:))
pend = (points+5)/30;
axis([pend-7 pend -5000 5000])