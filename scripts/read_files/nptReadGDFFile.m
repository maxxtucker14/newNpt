function [gdf,numSpikes,numClusters,spikesPerCluster] = nptReadGDFFile(filename)

gdf = load(filename);

numSpikes = size(gdf,1);
clusters = gdf(:,1) - 100;
numClusters = max(clusters);

for i = 1:numClusters
	spikesPerCluster(i) = length(find(gdf(:,1)==(100+i)));
end
