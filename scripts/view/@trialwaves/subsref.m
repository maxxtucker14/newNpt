function b = subsref(obj,index)
%TRIALWAVES/SUBSREF Index function for TRIALWAVES object.
%
%   Dependencies: @waveforms/subsref, @trialwaves/ToWaveNumber.

unknown = 0;
myerror = 0;

switch index(1).type
case '.'
	switch index(1).subs
	case 'trials'
		b = obj.trials;
	case 'trial'
		if length(index)>3
			switch(index(2).type)
			case '()'
				trial = index(2).subs{:};
				switch(index(3).type)
				case '.'
					switch (index(3).subs)
					case 'wave'
						switch (index(4).type)
						case '()'
							wave = index(4).subs{:};
							wavenum = ToWaveNumber(obj,trial,wave);
							if wavenum~=0
								if length(index)>4
									s(1).type = '.';
									s(1).subs = 'data';
									s(2).type = '()';
									s(2).subs = {[wavenum]};
									s = [s index(5:end)];
									b = subsref(obj.waveforms,s);
								else
									b = obj.waveforms.data(wavenum);
								end
							end
						otherwise
							myerror = 1;
						end
					otherwise
						myerror = 1;
					end
				otherwise
					myerror = 1;
				end
			otherwise
				myerror = 1;
			end
		else
			myerror = 1;
		end
	otherwise
		unknown = 1;
	end
otherwise
	unknown = 1;
end

if unknown == 1
	b = subsref(obj.waveforms,index);
elseif myerror == 1
	error('Invalid field name');
end
