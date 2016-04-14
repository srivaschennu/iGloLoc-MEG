function ctnorm(subjname)

loadpaths

subjname = lower(subjname);

S.D = sprintf('%s%s.mat',filepath,subjname);
S.outfile = sprintf('%s_norm',subjname);
D = spm_eeg_copy(S);

% calculate joint mean (M) and standard deviation (SD) for each electrode at each time point
M = mean(D(:,:,:),3);
SD = std(D(:,:,:),[],3);

D(:,:,:) = D(:,:,:) .* repmat(abs(M./SD),[1,1,D.ntrials]);

D.save;