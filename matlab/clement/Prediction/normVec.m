function [vecN, vecD] = normVec(vec,varargin)
% Returns a normalize vector (vecN) and "de-nomralized" vector (vecD). The
% function detects if both positive and negative values are present or not
% and automatically normalizes between the appropriate range (i.e., [0,1],
% [-1,0], or [-1,-1].
% Optional argument allows control of normalization range:
% normVec(vec,0) => sets range based on positive/negative value detection
% normVec(vec,1) => sets range to [0,1]
% normVec(vec,2) => sets range to [-1,0]
% normVec(vec,3) => sets range to [-1,1]

%% Default Input Values
% Check for proper length of input arguments
numvarargs = length(varargin);
if numvarargs > 1
    error('Requires at most 1 optional input');
end

% Set defaults for optional inputs
optargs = {0};

% Overwrite default values if new values provided
optargs(1:numvarargs) = varargin;

% Set input to variable names
[setNorm] = optargs{:};

%% Normalize input vector
% get max and min
maxVec = max(vec);
minVec = min(vec);

if setNorm == 0
    % Automated normalization
    if minVec >= 0
        % Normalize between 0 and 1
        vecN = (vec - minVec)./( maxVec - minVec );
        vecD = minVec + vecN.*(maxVec - minVec);
    elseif maxVec <= 0
        % Normalize between -1 and 0
        vecN = (vec - maxVec)./( maxVec - minVec );
        vecD = maxVec + vecN.*(maxVec - minVec);
    else
        % Normalize between -1 and 1
        vecN = ((vec-minVec)./(maxVec-minVec) - 0.5 ) *2;
        vecD = (vecN./2+0.5) * (maxVec-minVec) + minVec;
    end
elseif setNorm == 1
    % Normalize between 0 and 1
    vecN = (vec - minVec)./( maxVec - minVec );
    vecD = minVec + vecN.*(maxVec - minVec);
elseif setNorm == 2
    % Normalize between -1 and 0
    vecN = (vec - maxVec)./( maxVec - minVec );
    vecD = maxVec + vecN.*(maxVec - minVec);
elseif setNorm == 3
    % Normalize between -1 and 1
    vecN = ((vec-minVec)./(maxVec-minVec) - 0.5 ) *2;
    vecD = (vecN./2+0.5) * (maxVec-minVec) + minVec;
else
    error('Unrecognized input argument varargin. Options are {0,1,2,3}');
end