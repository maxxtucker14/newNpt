function r = plus(p,q,varargin)

Args = struct('StopOnDiff',0);
Args = getOptArgs(varargin,Args,'flags',{'StopOnDiff'});

if(q.data.numRFs==0)
	r = p;
elseif(p.data.numRFs==0)
	r = q;
else
	p.data.sessions = p.data.sessions + q.data.sessions;
	p.data.sessionname = {p.data.sessionname{:} q.data.sessionname{:}};
	p.data.PresenterVersion = {p.data.PresenterVersion{:} ...
		q.data.PresenterVersion{:}};
	p.data.Date = {p.data.Date{:} q.data.Date{:}};
	p.data.Time = {p.data.Time{:} q.data.Time{:}};
	p.data.ScreenWidth = [p.data.ScreenWidth; q.data.ScreenWidth];
	if(length(unique(p.data.ScreenWidth))~=1)
		if(Args.StopOnDiff)
			error('ScreenWidths not identical!');
		else
			fprintf('ScreenWidths not identical!');
		end
	end
	p.data.ScreenHeight = [p.data.ScreenHeight; q.data.ScreenHeight];
	if(length(unique(p.data.ScreenHeight))~=1)
		if(Args.StopOnDiff)
			error('ScreenHeights not identical!');
		else
			fprintf('ScreenHeights not identical!');
		end
	end
	p.data.numRFs = [p.data.numRFs; q.data.numRFs];
	p.data.type = [p.data.type; q.data.type];
	p.data.pts = [p.data.pts; q.data.pts];
	p.data.centerx = [p.data.centerx; q.data.centerx];
	p.data.centery = [p.data.centery; q.data.centery];
	p.data.ori = [p.data.ori; q.data.ori];
	p.data.uDim = [p.data.uDim; q.data.uDim];
	p.data.vDim = [p.data.vDim; q.data.vDim];
	p.data.sf = [p.data.sf; q.data.sf];
	p.data.vel = [p.data.vel; q.data.vel];
	p.data.mark = [p.data.mark; q.data.mark];
	p.data.numRFIndex = [p.data.numRFIndex; (p.data.numRFIndex(end) ...
		+ q.data.numRFIndex(2:end))];
    % add nptdata objects as well
	p.nptdata = plus(p.nptdata,q.nptdata);
    % p = set(p,'Number',p.data.sessions);
    r = p;
end
