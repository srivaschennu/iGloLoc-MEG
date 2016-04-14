function compdcm_intra(subjname)

loadsubj
loadpaths

dcmdir = 'DCM/';

% % compare attend-auditory local deviants vs standards
% sesstypes = {'global','global'};
% trialtypes = {'ld','ls'};
% convec = [1 0];
% nummod = length(garridomodels_intra(convec));

% % compare attend-visual local deviants vs standards
% sesstypes = {'visual','visual'};
% trialtypes = {'ld','ls'};
% convec = [1 0];
% nummod = length(garridomodels_intra(convec));

% compare attend-auditory omissions vs omission controls
sesstypes = {'global','global'};
trialtypes = {'od','oc'};
convec = [1 0];
nummod = length(omissionmodels_intra(convec));

% % compare attend-visual omissions vs omission controls
% sesstypes = {'visual','visual'};
% trialtypes = {'od','oc'};
% convec = [1 0];
% nummod = length(omissionmodels_intra(convec));

%%%%%% subtraction conditions - not used %%%%%%
% % compare attend-auditory omissions vs omission controls
% sesstypes = {'global','global'};
% trialtypes = {'x2','y2'};
% convec = [1 0];
% nummod = length(omissionmodels(convec));

% % compare attend-visual omissions vs omission controls
% sesstypes = {'visual','visual'};
% trialtypes = {'x2','y2'};
% convec = [1 0];
% nummod = length(omissionmodels(convec));


% % compare attend-auditory local deviants vs standards
% sesstypes = {'global','global'};
% trialtypes = {'ld-oc','ls-oc'};
% convec = [1 0];
% nummod = length(garridomodels(convec));

% % compare attend-visual local deviants vs standards
% sesstypes = {'visual','visual'};
% trialtypes = {'ld-oc','ls-oc'};
% convec = [1 0];
% nummod = length(garridomodels(convec));

% % compare attend-auditory omissions vs omission controls
% sesstypes = {'global','global'};
% trialtypes = {'od-oc','xc-yc'};
% convec = [1 0];
% nummod = length(omissionmodels(convec));

% % compare attend-visual omissions vs omission controls
% sesstypes = {'visual','visual'};
% trialtypes = {'od-oc','xc-yc'};
% convec = [1 0];
% nummod = length(omissionmodels(convec));

% % compare attend-auditory vs attend-visual omissions
% sesstypes = {'global','visual'};
% trialtypes = {'od-oc','od-oc'};
% convec = [1 0];
% nummod = length(omissionmodels(convec));
%%%%%% subtraction conditions - not used %%%%%%


% % compare attend-auditory local deviants vs standards
% sesstypes = {'global','global','visual','visual'};
% trialtypes = {'ld','ls','ld','ls'};
% conntypes = {'none','f','fbl','fbu','fb'};
% nummod = length(conntypes);
% winmodidx = 6;
% conidx = 3;

% % compare attend-auditory local deviants vs standards
% sesstypes = {'global','global','visual','visual'};
% trialtypes = {'od','oc','od','oc'};
% conntypes = {'none','b','bfl','bfu','fb'};
% nummod = length(conntypes);
% winmodidx = 9;
% conidx = 3;

timewin = [0 300];
modality = 'LFP';

fprintf('\nConditions:\n');
for t = 1:length(trialtypes)
    condnames{t} = sprintf('%s_%s',sesstypes{t},trialtypes{t});
    fprintf('%s\n',condnames{t});
end

bmsbatch{1}.spm.dcm.bms.inference.dir = {filepath};

fprintf('\nLoading models for subject:\n');
fprintf('%s\n',subjname);

for sessidx = 1:1
    for modidx = 1:nummod
        if exist('winmodidx','var')
            dcmfiles{modidx,1} = sprintf('%s%s%s_%s-%s_%d-%d_%s_DCM%d_%s_con%d.mat',...
                filepath,dcmdir,subjname,condnames{1},condnames{2},timewin(1),timewin(2),modality,winmodidx,conntypes{modidx},conidx);
        else
            dcmfiles{modidx,1} = sprintf('%s%s%s_%s-%s_%d-%d_%s_DCM%d.mat',...
                filepath,dcmdir,subjname,condnames{1},condnames{2},timewin(1),timewin(2),modality,modidx);
        end
    end
    bmsbatch{1}.spm.dcm.bms.inference.sess_dcm{1}.dcmmat = dcmfiles;
end
fprintf('\n');

bmsbatch{1}.spm.dcm.bms.inference.model_sp = {''};
bmsbatch{1}.spm.dcm.bms.inference.load_f = {''};
bmsbatch{1}.spm.dcm.bms.inference.method = 'FFX';
bmsbatch{1}.spm.dcm.bms.inference.family_level.family_file = {''};
bmsbatch{1}.spm.dcm.bms.inference.bma.bma_no = 0;
bmsbatch{1}.spm.dcm.bms.inference.verify_id = 0;

spm_jobman('initcfg');
spm_jobman('run',bmsbatch);

if exist('winmodidx','var')
    fileprefix = sprintf('%s-%s_%d-%d_%s_DCM%d_con%d',condnames{1},condnames{2},timewin(1),timewin(2),modality,winmodidx,conidx);
else
    fileprefix = sprintf('%s-%s_%d-%d_%s',condnames{1},condnames{2},timewin(1),timewin(2),modality);
end

movefile([filepath 'BMS.mat'],sprintf('%s%s_BMS.mat',filepath,fileprefix));
movefile([filepath 'model_space.mat'],sprintf('%s%s_model_space.mat',filepath,fileprefix));
