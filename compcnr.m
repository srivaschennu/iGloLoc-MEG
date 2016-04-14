function cnr = compcnr(modality)

loadpaths
loadsubj

condlist = [5 6 15 16];

for s = 1:size(subjlist,1)
    subjname = lower(subjlist{s,1});
    fprintf('Processing %s.\n',subjname);
    
    %load subject data
    D = spm_eeg_load(sprintf('%s%s_comb.mat',filepath,subjname));
    chanidx = find(strcmp(modality,D.chantype));
    badchan = intersect(chanidx,D.badchannels);
    
    %collate data
    if s == 1
        conddata = zeros(length(chanidx),length(D.time),length(condlist),size(subjlist,1));
    end
    conddata(:,:,:,s) = D(chanidx,:,condlist);
    if ~isempty(badchan)
        conddata(badchan,:,:,s) = NaN;
    end
end

baseline = [-200 0];
timewin = [0 300];
timeline = D.time * 1000;

baselineidx = find(min(abs(baseline(1)-timeline)) == abs(baseline(1)-timeline)):...
    find(min(abs(baseline(2)-timeline)) == abs(baseline(2)-timeline));

toiidx = find(min(abs(timewin(1)-timeline)) == abs(timewin(1)-timeline)):...
    find(min(abs(timewin(2)-timeline)) == abs(timewin(2)-timeline));

% %calculate contrast-to-noise ratio between pairs of conditions
% cnr = abs( nanmean(conddata(:,toiidx,1,:),2) - nanmean(conddata(:,toiidx,2,:),2) ) ./ ...
%     sqrt( ( nanvar(conddata(:,baselineidx,1,:),[],2) + nanvar(conddata(:,baselineidx,2,:),[],2) ) / 2 ) ;

cnr = nanstd(conddata(:,toiidx,:,:),[],2) ./ nanstd(conddata(:,baselineidx,:,:),[],2);

%average over conditions
cnr = nanmean(cnr,3);

%average over channels
cnr = squeeze(nanmean(cnr,1));