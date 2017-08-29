% CheckEndPoints - script to check end points when there is no end trigger

figure(1)
subplot(5,1,1)
plot(tms(1:points),data(3,:),'.')
subplot(5,1,2)
plot(tms(1:points),data(4,:),'.')
subplot(5,1,3)
plot(tms(1:points),data(5,:),'.')
subplot(5,1,4)
plot(tms(1:points),data(6,:),'.')
subplot(5,1,5)
plot(tms(1:points),data(7,:),'.')

end2 = (points+1)/30;
end1 = end2 - 1.5;
figure(2)
subplot(5,1,1)
plot(tms(1:points),data(3,:),'.')
axis([end1 end2 -30 30])
subplot(5,1,2)
plot(tms(1:points),data(4,:),'.')
axis([end1 end2 -100 10])
subplot(5,1,3)
plot(tms(1:points),data(5,:),'.')
axis([end1 end2 -100 10])
subplot(5,1,4)
plot(tms(1:points),data(6,:),'.')
axis([end1 end2 -2000 500])
subplot(5,1,5)
plot(tms(1:points),data(7,:),'.')
axis([end1 end2 -2000 500])

