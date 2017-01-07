function compdcm

loadsubj
loadpaths

dcmdir = 'DCM-final/';

timewin = [0 300];

modality = 'EEG';
% modality = 'MEG';
% modality = 'MEGPLANAR';


% % compare attend-auditory local deviants vs standards
sesstypes = {'global','global'};
% % compare attend-visual local deviants vs standards
% sesstypes = {'visual','visual'};

trialtypes = {'ld','ls'};
% trialtypes = {'od','oc'};

convec = [1 0];
model = dcmmodels(convec);
numuniqmod = length(model);

%------------------------------------------------------------------------
% sesstypes = {'global','global','visual','visual'};
% conntypes = {'none','f','b','fbl','fbu','bfl','bfu','fb'};
% numuniqmod = length(conntypes);
% conidx = 3;

% compare attend-auditory local deviants vs standards
% trialtypes = {'ld','ls','ld','ls'};
% winmodidx = 6;

% % compare attend-auditory omissions vs. omission controls
% trialtypes = {'od','oc','od','oc'};
% winmodidx = 18;
%------------------------------------------------------------------------

selmodels = 1:numuniqmod;

fprintf('\nConditions:\n');
for t = 1:length(trialtypes)
    condnames{t} = sprintf('%s_%s',sesstypes{t},trialtypes{t});
    fprintf('%s\n',condnames{t});
end
fprintf('\nModality: %s.\n',modality);

bmsbatch{1}.spm.dcm.bms.inference.dir = {filepath};

fprintf('\nLoading models for subject:\n');
for subjidx = 1:size(subjlist,1)
    subjname = lower(subjlist{subjidx,1});
    fprintf('%s\n',subjname);
    
    for sessidx = 1:1
        for modidx = 1:length(selmodels)
            if exist('winmodidx','var')
                dcmfiles{modidx,1} = sprintf('%s%s%s_%s-%s_%d-%d_%s_DCM%d_%s.mat',...
                    filepath,dcmdir,subjname,condnames{1},condnames{2},timewin(1),timewin(2),modality,winmodidx,conntypes{selmodels(modidx)});
            else
                dcmfiles{modidx,1} = sprintf('%s%s%s_%s-%s_%d-%d_%s_DCM%d.mat',...
                    filepath,dcmdir,subjname,condnames{1},condnames{2},timewin(1),timewin(2),modality,selmodels(modidx));
            end
            load(dcmfiles{modidx,1});
            allFs(subjidx,modidx) = DCM.F;
        end
        bmsbatch{1}.spm.dcm.bms.inference.sess_dcm{subjidx}.dcmmat = dcmfiles;
    end
end
fprintf('\n');

bmsbatch{1}.spm.dcm.bms.inference.model_sp = {''};
bmsbatch{1}.spm.dcm.bms.inference.load_f = {''};
bmsbatch{1}.spm.dcm.bms.inference.method = 'FFX';
bmsbatch{1}.spm.dcm.bms.inference.bma.bma_no = 0;
bmsbatch{1}.spm.dcm.bms.inference.verify_id = 0;

spm_jobman('initcfg');
spm_jobman('run',bmsbatch);

if exist('winmodidx','var')
    fileprefix = sprintf('%s-%s_%d-%d_%s_DCM%d',condnames{1},condnames{2},timewin(1),timewin(2),modality,winmodidx);
else
    fileprefix = sprintf('%s-%s_%d-%d_%s',condnames{1},condnames{2},timewin(1),timewin(2),modality);
end

movefile([filepath 'BMS.mat'],sprintf('%s%s_BMS.mat',filepath,fileprefix));
movefile([filepath 'model_space.mat'],sprintf('%s%s_model_space.mat',filepath,fileprefix));

winmodidx = 6;
allFs = allFs - repmat(min(allFs,[],2),1,size(allFs,2));
sortedFs = sort(allFs(:,setdiff(1:size(allFs,2),winmodidx)),2,'descend');
figure; hist(allFs(:,winmodidx)-sortedFs(:,1));

close(gcf);
close(gcf);

%% Generate average
load(sprintf('%s%s_BMS.mat',filepath,fileprefix),'BMS');
winmodidx = find(BMS.DCM.ffx.model.post == max(BMS.DCM.ffx.model.post));
fprintf('Generating DCM average.\n');
avgfiles = cell(20,1);
for subjidx = 1:size(subjlist,1)
    dcmfiles = bmsbatch{1}.spm.dcm.bms.inference.sess_dcm{subjidx}.dcmmat;
    avgfiles{subjidx} = dcmfiles{winmodidx};
end

spm_dcm_average(avgfiles,fileprefix);
movefile(sprintf('DCM_avg_%s.mat',fileprefix),sprintf('%sDCM_avg_%s.mat',filepath,fileprefix));
