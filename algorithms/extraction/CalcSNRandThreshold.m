function [SNRc,sigmalc]=CalcSNRandThreshold(data,neurongroup_info,groups)
% Calculates the Threshold and Signal to Noise Ratio based on the following
% equation: sigma = median(abs(data)/0.6745) which is an estimate of the
% noise level even during episodes of high firing rates. The SNR is the
% Range of Signal Values divided by the Range of the Noise Values.

channels=[];
for ii=groups
    channels = [channels ; transpose(neurongroup_info(ii).channels)];	
end
data = data(channels,:);



%Estimate of the Noise 
sigma = median(abs(data)/0.6745,2);

%Calculate clipping level for all channels
s=(3*sigma)*ones(1,size(data,2));

%find data above clip level
Psignal = NaN(size(data));
clip = data-s;
ind = find(clip>0);
Psignal(ind) = data(ind);

%find data below clip level
ind=[];clip=[];
Nsignal = NaN(size(data));
clip = data+s;
ind = find(clip<0);
Nsignal(ind) = data(ind);

if find(isnan(Nsignal)-1) | find(isnan(Psignal)-1)
    Positive_Signal = prctile(Psignal',99);
    Negative_Signal = prctile(Nsignal',1);
    SNR = (Positive_Signal- Negative_Signal)./(2*3*sigma');

    % Baseline SNR for electrical noise
    SNR(isnan(SNR))=1.4;
else %no signals on any channels for this chunk.
    SNR = 1.4*ones(size(sigma));
    frpintf('Warning no data above threshold on any channel for this chunk!')
end
sigmalc(channels) = sigma;
SNRc(channels) = SNR;

%SNR(channels) = (max(data,[],2) - min(data,[],2)) ./ (2*3*transpose(sigma(channels)));






% % SNR Calculation
% noise=data;
% [ind] = find(data>(3*sigma) | data<(-3*sigma));
% if ~isempty(ind)
%     signal = data(ind);
%     noise(ind) = [];
% else
%     signal=[];
% end
% % Some channels might just be electrical noise
% if ~isempty(signal)
%     Mean_Noise_Level = mean(noise);
%     Positive_Noise = Mean_Noise_Level+(3*std(noise));
%     Negative_Noise = Mean_Noise_Level-(3*std(noise));
%     Positive_Signal = prctile(signal(find(signal>Mean_Noise_Level)),99);
%     Negative_Signal = prctile(signal(find(signal<Mean_Noise_Level)),1);
%     SNR = (range([Positive_Signal Negative_Signal]))/(range([Positive_Noise Negative_Noise]));
% else
%     % Baseline SNR for electrical noise
%     SNR = 1.4;
% end