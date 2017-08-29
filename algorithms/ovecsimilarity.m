function [r,angle,p] = vecsimilarity(mat,varargin)
%vecsimilarity Compute similarity of vectors
%   [R,ANGLE,P] = vecsimilarity(MAT) computes the magnitude, R, of the 
%   mean of the unit vectors derived from the vectors stored in the 
%   rows of MAT. If MAT is a matrix with two rows, the angle between 
%   the vectors is also computed and returned in ANGLE (in units of 
%   degrees), together with a p-value calculated by shuffling the
%   columns of MAT and computing the percentage of surrogates with
%   greater or lesser values than ANGLE. The number of surrogates can
%   be specified using the RandSets optional input argument (default:
%   1000).

Args = struct('RandSets',1000,'Display',0);
Args.flags = {'Display'};
Args = getOptArgs(varargin,Args);

% get size of mat
[mrows,mcols] = size(mat);
% compute vector magnitudes
vmags = sqrt(sum(mat.^2,2));
% create matrix of magnitudes to do division
magmat = repmat(vmags,1,mcols);
% divide each vector by magnitude to get unit vector
uvecs = mat ./ magmat;
% take mean of unit vectors
mvec = mean(uvecs);
% return the magnitude of mean vector
r = norm(mvec);
% compute angle only if there are only 2 vectors
if(mrows==2)
    % compute and save product of vector magnitudes since it is used again
    % later
    vmprod = prod(vmags);
	angle = rad2deg(acos((mat(1,:) * mat(2,:)')/vmprod));
    if(nargout>2)
        % compute p value by shuffling the firing rates and determining the
        % percentage of shuffled values with greater angles
        % create two matrices with random values
        % get rand sets
        rsets = Args.RandSets;
        % save rsets * 2 since it is used again later
        rsets2 = 2 * rsets;
        rmat = rand(mcols,rsets2);
        % rmatb = rand(mcols,Args.RandSets);
        % sort each column
        [srmat,srmati] = sort(rmat);
        % create shuffled matrices using random indices
        mat1 = mat(1,:);
        rmata = mat1(srmati(:,1:rsets));
        mat2 = mat(2,:);
        rmatb = mat2(srmati(:,(rsets+1):rsets2));
        % now compute angle for each set
        % first compute product
        rmatab = rmata .* rmatb;
        % now compute the sum of the products
        rmatabs = sum(rmatab);
        % vector magnitudes will stay the same so we can use the same
        % calculation as above
        rangles = rad2deg(acos(rmatabs/vmprod));
        % compute percentage of values in rangles that are above or below angle
        % computed from the data
        rangplus = sum(rangles>=angle);
        rangminus = sum(rangles<=angle);
        % see which value is larger
        p = min([rangplus rangminus])/rsets;
        if(Args.Display)
            hist(rangles)
            hold on
            line([angle angle],ylim,'Color','r')
            title(['p = ' num2str(p)])
            hold off
            pause
        end
    else
        p = nan;
    end
else
	angle = nan;
    p = nan;
end
