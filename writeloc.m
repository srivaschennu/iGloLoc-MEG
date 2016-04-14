function writeloc(D)

loadpaths

if ischar(D)
    D = spm_eeg_load(D);
end

modalities = {'EEG' 'MEGMAG' 'MEGPLANAR','MEGCOMB'};

[~,basename,~] = fileparts(D.fname);

% find and exclude bad channels
badchannels = D.badchannels;
if ~isempty(badchannels)
    fprintf('\nFound %d bad channels: ', length(badchannels));
    for ch=1:length(badchannels)-1
        fprintf('%s ',D.chanlabels{badchannels(ch)});
    end
    fprintf('%s\n',D.chanlabels{badchannels(end)});
else
    fprintf('No bad channel info found.\n');
end

for m = 1:length(modalities)
    sensidx = setdiff(find(strcmp(modalities{m},D.chantype)),badchannels);
    switch modalities{m}
        case 'EEG'
            sensinfo = D.sensors(modalities{m});
            sensidx = 1:length(sensinfo.label);
            
        case {'MEGMAG','MEGPLANAR'}
            sensinfo = D.sensors('MEG');
            sensidx = find(strcmp(modalities{m},D.chantype))-find(strncmp('MEG',D.chantype,3),1,'first')+1;
            
        case 'MEGCOMB'
            sensinfo = D.sensors('MEG');
            planaridx = find(strcmp('megplanar',sensinfo.chantype));
            planaridx = planaridx(2:2:end);
            sensinfo.chanpos = sensinfo.chanpos(planaridx,:);
            sensidx = find(ismember(find(strcmp(modalities{m},D.chantype)),sensidx));
            
        otherwise
            error('Unrecognised sensor type: %s.', modalities{m});
    end
    
    chanlocfile = sprintf('%s%s_%s.xyz',filepath,basename,modalities{m});
    fprintf('Writing %s locations to %s.\n',modalities{m},chanlocfile);
    
    fid = fopen(chanlocfile,'w');
    for s = 1:length(sensidx)
        fprintf(fid,'%d\t%f\t%f\t%f\t%s\n', s, sensinfo.chanpos(sensidx(s),:), sensinfo.label{sensidx(s)});
    end
    
    fclose(fid);
end
