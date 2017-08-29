function [clusters,numSpikes,numClusters] = ReadCUTFile(filename)
%[clusters,numSpikes,numClusters] = ReadCUTFile(filename)
%reads the cut file 
%which is an ASCII output from MClust
%cluster 0 is the throwaway cluster
%cluster -1 is the overlap cluster

clusters = load(filename);
numSpikes = size(clusters,1);
numClusters = max(clusters);


