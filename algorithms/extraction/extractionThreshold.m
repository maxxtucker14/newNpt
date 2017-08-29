function [sumX,sumX2,n] = extractionThreshold(data,neurongroup_info,threshold,groups);
%ExtractorWrapper	Computes mean and stdev used during spike extraction
%	[sumX sumX2 n]=ExtractorWrapper(DATA,
%	DESCRIPTOR,GROUP_INFO) computes the mean and and 4 standard
%	deviations for each group in DATA and then recomputes these two 
%	variables after clipping out points that are larger than 4 
%	standard deviations.  DESCRIPTOR is the data structure 
%	returned by ReadDescriptor which contains descriptions of the data. 
%	GROUP_INFO is the data structure returned by GroupSignals which
%	describes how groups of data are organized. The sum and sum of 
%   squared amplitudes is returned for the clipped data.  Also the number
%   of points in the clipped data.  Since only a portion of the 
%   entire session data is usually inputed, these parameters are used to calculate
%   the mean and standard deviation of the entire data set.

% Calculate 4-sigma thresholds for each channel
if nargin<3
    threshold=4;
else
    fprintf(['     Calculating extraction threshold at ' num2str(threshold) ' standard deviations.   '])
end
if nargin<4
    groups=1:size(neurongroup_info,2);
end
% Loops over group number  
fprintf([' Group ' num2str(groups)])
for i=groups
    group=neurongroup_info(i).group;
    groupdata=[];
    %...we only want to give data for one group at a time
    groupdata=[data(neurongroup_info(i).channels,:)];	
    
    %c=cleandata(groupdata,1);
    %groupdata = transpose(c(:,1:size(groupdata,1)));
    
    clip_data=groupdata';
    sigma=std(clip_data);
    avg=mean(clip_data);
    % comptute positive threshold
    v_plusthreshold= avg + threshold*sigma; 
    avgplus=mean(v_plusthreshold);    %threshold for all channels in group
    % compute negative threshold
    v_minusthreshold = avg - threshold*sigma;
    avgminus=mean(v_minusthreshold);   %threshold for all channels in group
    % chigh=abs(clip_data)>avg2;	
    % clow=abs(clip_data)<avg2;
    % meanavg=ones(size(chigh,1),1)*avg;
    % clip_data=clip_data .* clow + meanavg .* chigh; 
    
    % set points larger than positive threshold to 1 and the rest 0
    cliphigh=clip_data>avgplus;
    % set points smaller than negative threshold to 1 and the rest 0
    cliplow=clip_data<avgminus;
    % combine cliphigh and cliplow. These are the outliers.
    outliers = cliphigh + cliplow;
    %    % get the inverse which are the points that are within +/- threshold
    %    unclipped = ~outliers;
    %    % get inverse, i.e. points larger than -threshold are 1 and the rest 0
    %    % unclippedlow=invert(cliplow);
    %    % pull out the data that is between +/- threshold and replace all points
    %    % exceeding the threshold with the mean value
    %    
    %    clip_data=(unclipped .* clip_data) + (outliers * diag(avg));
    
    %figure;plot(clip_data(:,1));hold on
    %collapse accross channels
    outliers = sum(outliers,2);
    clip_data(find(outliers),:)=[];
    %plot(clip_data(:,1),'r');
    
    sumX(i,:) = sum(clip_data,1);
    sumX2(i,:) = sum(clip_data.^2,1);
    n(i,:) = size(clip_data,1);
    
    
    %     v_mean(i,:) = mean(clip_data);
    %     v_threshold(i,:)=threshold*std(clip_data);   
    
end

