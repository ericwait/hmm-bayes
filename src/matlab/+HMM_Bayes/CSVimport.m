function trackData = CSVimport(csvPath,trackStr,xStr,yStr,zStr,timeStr,timeMultiplier,umXYmultiplier,umZmultiplier)

    if (~exist('timeMultiplier','var') || isempty(timeMultiplier))
        timeMultiplier = 1;
    end
    if (~exist('umXYmultiplier','var') || isempty(umXYmultiplier))
        umXYmultiplier = 1;
    end
    if (~exist('umZmultiplier','var') || isempty(umZmultiplier))
        umZmultiplier = 1;
    end
    
    raw = readtable(csvPath);
    if (sum(ismissing(raw(1,:)))>size(raw,2)*0.75)
        raw = raw(2:end,:); % Trackmate has extra rows at the top
    end

    %% Convert data into input to HMM_Bayes.Bayes
    if (isempty(raw.(trackStr)))
        error('Cannont find Track column');
    end
    if (isempty(raw.(xStr)))
        error('Cannont find X column');
    end
    if (isempty(raw.(yStr)))
        error('Cannont find Y column');
    end
    if (isempty(raw.(zStr)))
        error('Cannont find Z column');
    end
    if (isempty(raw.(timeStr)))
        error('Cannont find Time column');
    end
    
    trackVals = raw.(trackStr);
    xVals = raw.(xStr) .* umXYmultiplier;
    yVals = raw.(yStr) .* umXYmultiplier;
    zVals = raw.(zStr) .* umZmultiplier;
    timeVals = raw.(timeStr);

    trackIDs = unique(trackVals);
    
    %% Make a structure that holds each track data
    trackData = struct('trackID',[],'pos_xyz',[],'times',[],'frames',[],'steps_xyz',[]);
    trackData(length(trackIDs)).trackID = trackIDs(end);
    
    for outTrackID=1:length(trackData)
        inTrackID = trackIDs(outTrackID);

        trackData(outTrackID).trackID = inTrackID;
        mask = trackVals == inTrackID;
        
        trackData(outTrackID).pos_xyz = [xVals(mask),yVals(mask),zVals(mask)];
        trackData(outTrackID).steps_xyz = trackData(outTrackID).pos_xyz(2:end,:)-trackData(outTrackID).pos_xyz(1:end-1,:);
        trackData(outTrackID).frames = timeVals(mask);
        trackData(outTrackID).times = trackData(outTrackID).frames .* timeMultiplier;
    end
end
