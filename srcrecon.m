function srcrecon

loadpaths

loadsubj

filelist = {};

timeshift = 0;
foi = [0 Inf];

tois = {
    [-200 700]
%     [0 600]
%     [0 300]
%     [300 600]
    };

filesuffix = '_cond';

fprintf('Loading data...\n');
for subjidx = 1:size(subjlist,1)
    subjname = lower(subjlist{subjidx,1});
    fullfilename = sprintf('%s%s%s.mat',filepath,subjname,filesuffix);
    filelist = cat(1,filelist,fullfilename);
    D{subjidx} = spm_eeg_load(fullfilename);
    subjinv{subjidx} = load(sprintf('%s%s_inv.mat',filepath,subjname));
end

coi = D{1}.conditions;

fprintf('Reconstructing sources for:\n');
disp(filelist);

moilist = {
    {'MEGPLANAR', 'MEG', 'EEG'}
    {'MEGPLANAR', 'MEG'}
    {'EEG'}
    };

val = 1;
for moiidx = 1:length(moilist)
    moi = moilist{moiidx};
    for toiidx = 1:length(tois)
        toi = tois{toiidx};
        fprintf('Inversion %d with ',val); fprintf('%s ',moi{:}); fprintf('within %d-%dms\n',toi);
        for subjidx = 1:size(subjlist,1)
            D{subjidx}.val = val;
            D{subjidx}.inv{val} = subjinv{subjidx}.inv{1};
            D{subjidx}.inv{val}.inverse = [];
            D{subjidx}.inv{val}.inverse.type     = 'GS';
            D{subjidx}.inv{val}.inverse.modality = moi;
            D{subjidx}.inv{val}.inverse.woi      = timeshift+toi;
            D{subjidx}.inv{val}.inverse.trials   = coi;
            D{subjidx}.inv{val}.inverse.lpf      = foi(1);
            D{subjidx}.inv{val}.inverse.hpf      = foi(2);
        end
        D = spm_eeg_invert(D);
        val = val+1;
    end
end

for subjidx = 1:size(subjlist,1)
    D{subjidx}.save;
end