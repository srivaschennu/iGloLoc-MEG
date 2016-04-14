function rundcm(subjname)

subjname = lower(subjname);

loadpaths
% dcmdir = 'DCM-withoutIPC/';
dcmdir = 'DCM-final/';

convec = [1 0];

% compare attend-auditory local deviants vs standards
sesstypes = {'global','global'};

% compare attend-visual local deviants vs standards
% sesstypes = {'visual','visual'};

% trialtypes = {'ld','ls'};
trialtypes = {'od','oc'};

model = dcmmodels(convec);
models2run = 1:length(model);

%------------------------------------------------------------------------

convec = [
    1 -1  1 -1 %standards vs. deviants
%     1  1 -1 -1 %attend-auditory vs. attend-visual
    1 -1 -1  1 %attention vs. deviance interaction
    ];

sesstypes = {'global','global','visual','visual'};

conntypes = {'none','f','b','fbl','fbu','bfl','bfu','fb'};

% compare attend-auditory local deviants vs standards
% trialtypes = {'ld','ls','ld','ls'};

% compare attend-auditory omissions vs. omission controls
trialtypes = {'od','oc','od','oc'};

model = dcmmodels(convec);

%------------------------------------------------------------------------

filesuffix = '_cond';
timewin = [0 300];
% timewin = [0 150];

modality = 'EEG';
% modality = 'MEG';
% modality = 'MEGPLANAR';

fullfilename = sprintf('%s%s%s.mat',filepath,subjname,filesuffix);
D = spm_eeg_load(fullfilename);

%locate indices of conditions to model
fprintf('\nRunning DCM on %s conditions:\n',subjname);
for t = 1:length(trialtypes)
    condnames{t} = sprintf('%s_%s',sesstypes{t},trialtypes{t});
    condidx(t) = find(strcmp(condnames{t},D.conditions));
    fprintf('%d: %s\n',condidx(t),condnames{t});
end
fprintf('\nModality = %s.\n',modality);

% ------------------------------------------------------------------------
load(sprintf('%s%s-%s_%d-%d_%s_BMS.mat',filepath,condnames{1},condnames{2},timewin(1),timewin(2),modality));
[~,winmodidx] = max(BMS.DCM.ffx.model.post);
fprintf('\nRunning winning model %d for %s.\n',winmodidx,subjname);
winmod = model(winmodidx);

clear model
for c = 1:length(conntypes)
    model(c) = setupmodel(winmod,conntypes{c},convec);
end
models2run = 1:length(model);
% ------------------------------------------------------------------------

% model specification
modelspec.options.analysis = 'ERP'; % analyze evoked responses
modelspec.options.model = 'ERP'; % ERP model
modelspec.options.spatial = 'ECD'; % spatial model OR ECD??? Manual recommends ECD
modelspec.options.trials  = condidx;  % index of ERPs within ERP/ERF file
modelspec.options.Tdcm(1) = timewin(1);      % start of peri-stimulus time to be modelled
modelspec.options.Tdcm(2) = timewin(2);    % end of peri-stimulus time to be modelled
modelspec.options.Nmodes  = 8;      % nr of modes for data selection
modelspec.options.h       = 1;      % nr of DCT components
modelspec.options.onset   = 60;     % selection of onset (prior mean)
modelspec.options.D       = 1;      % downsampling
modelspec.options.Nmax    = 256;    % Max number of iterations

% model between trial effects
modelspec.xU.name = {sprintf('%s-%s',condnames{1},condnames{2})};

modelspec.options.lock     = 0;      % (if want modulations to be in same direction for all connections)
modelspec.options.location = 0;      % (Not relevant; only for ECD)
modelspec.options.symmetry = 0;      % (Not relevant; only for ECD)

modelspec.xY.Dfile = fullfilename;
modelspec.xY.modality = modality;

modelspec.options.gety = 0;
modelspec.options.nograph  = 1;


%prepare DCM
modelspec = spm_dcm_erp_data(modelspec,modelspec.options.h);

% this assumes that all models have the same nodes
modelspec.Lpos = model(1).Lpos;
modelspec.Sname = model(1).Sname;
modelspec = spm_dcm_erp_dipfit(modelspec, 0);

%run models
for n = models2run
    fprintf('Running model %d.\n',n);
    
    if exist('winmodidx','var')
        modelnames{n} = sprintf('%s%s%s_%s_%d-%d_%s_DCM%d_%s',filepath,dcmdir,subjname,modelspec.xU.name{1},timewin(1),timewin(2),modality,winmodidx,conntypes{n});
    else
        modelnames{n} = sprintf('%s%s%s_%s_%d-%d_%s_DCM%d',filepath,dcmdir,subjname,modelspec.xU.name{1},timewin(1),timewin(2),modality,n);
    end
    
    DCM      = modelspec;
    DCM.name = modelnames{n};
    DCM.A = model(n).A;
    DCM.C = model(n).C;
    
%     for c = 1:size(convec,1)
        
        DCM.xU.X = convec';%(c,:)';
        DCM.B = model(n).B;%(c);
%         if size(convec,1) > 1
%             DCM.name = sprintf('%s_con%d',modelnames{n},c);
%         end
        
%         if exist([DCM.name '.mat'],'file')
%             fprintf('\n%s.mat exists. Skipping\n',DCM.name);
%             continue;
%         end
        
        fprintf('\nSaving model %d to %s.mat.\n',n,DCM.name);
        
        tic
        spm_dcm_erp(DCM);
        fprintf('\nModel %d took %.1f minutes.\n',n,toc/60);
        
%         plotdcm(DCM);
%         export_fig(gcf,sprintf('figures/%s_%d.pdf','dcmmodels',n));
%         close(gcf);
%     end
end

function model = setupmodel(model,conntype,convec)
switch conntype
    case 'none'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c}));
        end
    case 'f'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{1};
        end
    case 'b'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{2};
        end
    case 'l'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{3};
        end
    case 'fb'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{1} + model.A{2};
        end
    case 'fl'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{1} + model.A{3};
        end
    case 'bl'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{2} + model.A{3};
        end
        
    case 'fbl'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{1};
            model.B{c}(1,3) = model.A{2}(1,3);
            model.B{c}(2,4) = model.A{2}(2,4);
        end
    case 'fbu'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{1};
            model.B{c}(4,5) = model.A{2}(4,5);
            model.B{c}(3,6) = model.A{2}(3,6);
        end
        
    case 'bfl'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{2};
            model.B{c}(3,1) = model.A{1}(3,1);
            model.B{c}(4,2) = model.A{1}(4,2);
        end
    case 'bfu'
        for c = size(convec,1)
            model.B{c} = diag(diag(model.B{c})) + model.A{2};
            model.B{c}(5,4) = model.A{1}(5,4);
            model.B{c}(6,3) = model.A{1}(6,3);
        end
    otherwise
        error('Unrecognised conntype string!');
end
