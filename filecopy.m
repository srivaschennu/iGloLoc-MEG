function filecopy(subjname)

subjname = lower(subjname);

loadpaths

fullfilename = sprintf('%s%s.mat',filepath,subjname);
fprintf('Reading %s.\n',fullfilename);
D = spm_eeg_load(fullfilename);

subjinv = load(sprintf('%s%s_inv.mat',filepath,subjname));

val = 1;
D.val = val;
D.inv{val} = subjinv.inv{1};

S = [];
S.D = D;
S.outfile = sprintf('/Volumes/CHENNU/%s.mat',subjname);
spm_eeg_copy(S);
