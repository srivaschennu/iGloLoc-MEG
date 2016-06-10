function subcond(subjname)

subjname = lower(subjname);

loadpaths

sesslist = {'global','visual'};

timeshift = 600; %milliseconds

condlists = {
    {'ld','oc'}
    {'ls','oc'}
    {'gd','oc'}
    {'gs','oc'}
    {'od','oc'}
    {'x2','xc'}
    {'y2','yc'}
    {'xc','yc'}
    };

fullfilename = sprintf('%s%s_erp.mat',filepath,subjname);
fprintf('Reading %s.\n',fullfilename);
Derp = spm_eeg_load(fullfilename);

D = Derp;

D = timeonset(D,D.timeonset-(timeshift/1000));

S = [];
S.D = D;
S.timewin = [-200 0];
D = spm_eeg_bc(S);

if isfield(Derp,'inv')
    D.inv = Derp.inv;
end

S = [];
S.D = D;
S.outfile = sprintf('%s_cond',subjname);
D = spm_eeg_copy(S);
delete(S.D);
