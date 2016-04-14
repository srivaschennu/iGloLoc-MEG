function viewdcm

loadpaths
loadsubj

dcmdir = 'DCM-final/';

% compare attend-auditory omissions vs omission controls
sesstypes = {'global','global'};
% compare attend-visual omissions vs omission controls
% sesstypes = {'visual','visual'};

% trialtypes = {'ld','ls'};
trialtypes = {'od','oc'};

% modality = 'EEG';
modality = 'MEG';
% modality = 'MEGPLANAR';

timewin = [0 300];

for t = 1:length(trialtypes)
    condnames{t} = sprintf('%s_%s',sesstypes{t},trialtypes{t});
    fprintf('%s\n',condnames{t});
end

fileprefix = sprintf('%s-%s_%d-%d_%s',condnames{1},condnames{2},timewin(1),timewin(2),modality);

load(sprintf('%s%s_BMS.mat',filepath,fileprefix),'BMS');

winmodidx = find(BMS.DCM.ffx.model.post == max(BMS.DCM.ffx.model.post));

for s = 1:size(subjlist,1)
    subjname = lower(subjlist{s,1});
    load(sprintf('%s%s%s_%s_DCM%d.mat',filepath,dcmdir,subjname,fileprefix,winmodidx));
    spm_dcm_erp_results(DCM,'Scalp maps');
    export_fig(gcf,sprintf('figures/%s_%s_DCM%d.tif',subjname,fileprefix,winmodidx));
    close(gcf);
end