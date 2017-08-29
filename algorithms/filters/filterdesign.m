%filterdesign2

close all
clear all



rawfile='e:\Data\syen\Annie\053001\01\annie05300101.0001';
[data,num_channels,sampling_rate,scan_order,points]=nptReadStreamerFile(rawfile);


data=data(4,:);
time=points/sampling_rate;
tt=0:1/sampling_rate:time-1/sampling_rate;

plot(tt,data)
hold on


%resample data
y=[];
for i=1:size(data,1)
   y=[y ; resample(data(i,:),1000,sampling_rate)];
end


tt1=0:1/1000:time;
%plot(tt1,y,'r')	


%filter signal
Fn=500;		%!!!Use nyquist freq
low=1/Fn;	
high=200/Fn;
% [b,a] = butter(4, [low high]); 
b=[0.0459 0 -0.1834 0 0.2751 0 -0.1834 0 0.0459];
a=[1.0000 -4.7759 9.7965 -11.5999 8.9966 -4.7469 1.6072 -0.3083 0.0307];
x=filter(b,a,y);

hold on

[b,a] = butter(2, [low high]); 
z=filtfilt(b,a,y');
size(z);
size(x);

plot(tt1,z(:,1),'r')
plot(tt1,x(1,:),'c')

legend('raw','filtfilt','filter')
