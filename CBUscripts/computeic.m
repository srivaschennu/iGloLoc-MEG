function computeic(basename)

loadpaths

modalities = {'EEG' 'MEGMAG' 'MEGPLANAR'};
icatype = 'runica';
pcacheck = true;

if ischar(basename)
    D = spm_eeg_load(sprintf('%s%s_clean.mat',filepath,lower(basename)));
else
    D = basename;
end

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

if strcmp(icatype,'runica')
    if pcacheck
        kfactor = 60;
        pcadim = kfactor;
        if D.nchannels > pcadim
            fprintf('Too many channels for stable ICA. Data will be reduced to %d dimensions using PCA.\n',pcadim);
            icaopts = {'extended' 1 'pca' pcadim 'maxsteps' 800};
        else
            icaopts = {'extended' 1 'maxsteps' 800};
        end
    else
        icaopts = {'extended' 1 'maxsteps' 800};
    end
else
    icaopts = {};
end

for m = 1:length(modalities)
    icainfo(m).icachansind = setdiff(find(strcmp(modalities{m},D.chantype)),badchannels);
    if ~isempty(icainfo(m).icachansind)
        data = D(icainfo(m).icachansind,:,:);
        data = reshape(data,size(data,1),size(data,2)*size(data,3));
        [icainfo(m).weights,icainfo(m).sphere,icainfo(m).compvars,icainfo(m).bias,icainfo(m).signs,icainfo(m).lrates] = ...
            runica(data,icaopts{:});
    end
end

save(sprintf('%s%s_icainfo.mat',filepath,lower(basename)),'icainfo');