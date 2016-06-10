function rejartifacts(basename,oldsuffix,newsuffix)

loadpaths

basename = lower(basename);

D = spm_eeg_load(sprintf('%s%s%s.mat',filepath,basename,oldsuffix));

%% delete bad trials
S = [];
S.D = D;
D = spm_eeg_remove_bad_trials(S);

%% copy data over to final file
S = [];
S.D = D;
S.outfile = sprintf('%s%s.mat',basename,newsuffix);
fprintf('\nCopying to %s.\n',S.outfile);
spm_eeg_copy(S);
delete(S.D);
