%% DCM script for MEG MMN using s-Loreta source localised scripts

clear all
clc
cwd = '/imaging/hp02/mmn_08/analysis_spm/DCM/';
cd(cwd)

addpath(genpath('/imaging/hp02/spm8'));
addpath(genpath('/imaging/local/software/mne'));


%% Define your subject data and MRIs
prefix1 = 'macefffM';
prefix2 = 'maefffM';
path_file = '/imaging/hp02/mmn_08/analysis_spm/Preproc_new_mf/source_localisation/MEGgrad_sLoreta/100_200ms'

cnt = 0;

cnt = cnt + 1;
data_name{cnt} = '/s18/'; % File name for results after averaging (input for source estimation)
subjects{cnt} = [prefix1, 's18_MMN_blk1.mat'];   % letter strings for subject-specific paths
subj_dotdat{cnt} = [prefix1, 's18_MMN_blk1.dat'];
sname(cnt) = 18;

cnt = cnt + 1;
data_name{cnt} = '/s19/'; % File name for results after source estimation
subjects{cnt} = [prefix1, 's19_MMN_blk1.mat'];   % letter strings for subject-specific paths
subj_dotdat{cnt} = [prefix1, 's19_MMN_blk1.dat'];
sname(cnt) = 19;

% etc


% Note: you may have to copy your MRI first (e.g. from /imaging/local/structurals/cbu)

nr_subs = length(data_name);
fprintf(1, 'Going to process %d data sets\n', nr_subs);


%% Matlab pool stuff

%ParType = 0;  % Fun on Login machines (not generally advised!)
%ParType = 1;   % Run maxfilter call on Compute machines using spmd (faster)
ParType = 2;   % Run on multiple Compute machines using parfar (best, but less feedback if crashes)

% open matlabpool if required
% matlabpool close force CBU_Cluster
if ParType
    if matlabpool('size')==0;
        %MaxNsubs = 1;
        %if ParType == 2
        %    for g=1:length(cbu_codes)
        %        MaxNsubs = max([MaxNsubs length(cbu_codes{g})]);
        %    end
        %end
        P = cbupool(11);
        matlabpool(P);
    end
end

TransDefaultFlag = 1; 


%% DCM
tic
datafit = 'std_dvt'; datacons = [1:2];

Twin = [0 250];


LF = 2; HF = 30;
%%
for dc = 1%:length(datafit)
    for tw = 1:size(Twin,1)
        
        % Parameters and options used for setting up model.
        %-------------------------------------------------------
        DCMbase.options.analysis = 'ERP'; % analyze evoked responses
        DCMbase.options.model = 'ERP'; % ERP model
        DCMbase.options.spatial = 'ECD'; % spatial model OR ECD??? Manual recommends ECD
        DCMbase.options.trials  = [1:2];  % index of ERPs within ERP/ERF file
        DCMbase.options.Tdcm(1) = Twin(tw,1);      % start of peri-stimulus time to be modelled
        DCMbase.options.Tdcm(2) = Twin(tw,2);    % end of peri-stimulus time to be modelled
        DCMbase.options.Nmodes  = 8;      % nr of modes for data selection
        DCMbase.options.h       = 1;      % nr of DCT components
        DCMbase.options.onset   = 60;     % selection of onset (prior mean)
        DCMbase.options.D       = 1;      % downsampling
        DCMbase.options.han     = 1;      % no Hanning
        
        DCMbase.options.lock     = 0;      % (if want modulations to be in same direction for all connections)
        DCMbase.options.location = 0;      % (Not relevant; only for ECD)
        DCMbase.options.symmetry = 0;      % (Not relevant; only for ECD)
        
        DCMbase.options.nograph  = 0;
        
        
        % location priors for dipoles
        %----------------------------------------------------------
        DCMbase.Lpos = [[-42; -22; 7] [46; -14; 8] [-61; -32; 8] [59; -25; 8] [46; 20; 8] [-46; 20; 8] [60; -62; 35] [-59; -56; 42]];
        DCMbase.Sname = {'left AI', 'right A1', 'left STG', 'right STG', 'right IFG', 'left IFG', 'right parietal', 'left parietal'};
        Nareas    = size(DCMbase.Lpos,2);
        
        
        %----------------------------------------------------------
        % between trial effects
        %----------------------------------------------------------
         DCMbase.xU.X = [0 1]'; % [std dvt]'
        DCMbase.xU.name = {'rare'};
        
        %----------------------------------------------------------
        % specify connectivity model (models 1-6 are the Garrido models)
        %----------------------------------------------------------
        
        model = [];
        
        
        % Bilateral inputs into A1
        model(1).A{1} = zeros(8);             % forward connection
        model(1).A{2} = zeros(8);             % backward connection
        model(1).A{3} = zeros(8);             % lateral
        model(1).B{1} = zeros(8);             % Null model
        model(1).C    = [1 1 0 0 0 0]';         % Inputs into A1
        
        % add intrinsic connections
        m=2;
        model(m) = model(1);
        model(m).B{1}(1,1)=1; %A1 modulation on itself
        model(m).B{1}(2,2)=1; %A1 modulation on itself
        
        
        % Add STG
        m=3;
        model(m) = model(1);
        model(m).A{1}(3,1) = 1; % LA1 forward connection on LSTG
        model(m).A{1}(4,2) = 1; % RA1 forward connection on RSTG
        model(m).A{2}(1,3) = 1; % LA1 backward connection on LSTG
        model(m).A{2}(2,4) = 1; % RA1 backward connection on RSTG
        
        model(m).B{1}(3,1) = 1; % LA1 modulation on LSTG forward
        model(m).B{1}(4,2) = 1; % RA1 modulation on LSTG foward
        model(m).B{1}(1,3) = 1; % LA1 modulation on LSTG Backward
        model(m).B{1}(2,4) = 1; % RA1 modulation on RSTG backward
        
         % add intrinsic connections
        m=4;
        model(m) = model(3);
        model(m).B{1}(1,1)=1; %A1 modulation on itself
        model(m).B{1}(2,2)=1; %A1 modulation on itself
        
        
        % Add RIFG
        m=5;
        model(m) = model(3);
        model(m).A{1}(5,4) = 1; % RSTG forward connection on RIFG
        model(m).A{2}(4,5) = 1; % RIFG backward connection on RSTG
        model(m).B{1}(5,4) = 1; %!
        model(m).B{1}(4,5) = 1; %!
        
        % Add A1 with intrinsic connections
        m=6;
        model(m) = model(5);
        model(m).B{1}(1,1)=1; %A1 modulation on itself
        model(m).B{1}(2,2)=1; %A1 modulation on itself
        
        
        
        LogEvd=[]; DCMname={};
        parfor ss = 1:nr_subs
         ss   
            DCMsub = DCMbase;
            
            data_subj = ['/imaging/hp02/mmn_08/analysis_spm/DCM/ECD/1_0/my_spm/garrido_with_parietal/' subjects{ss}];
            S=[]; S.D = data_subj;
            
            DCMsub.xY.Dfile = S.D;
            DCMsub.xY.modality = 'MEGPLANAR';
            DCMsub = spm_dcm_erp_data(DCMsub,DCMsub.options.h);
            DCMsub = spm_dcm_erp_dipfit(DCMsub, 0);
            
            DCMsub.options.gety = 0;
            DCMsub.options.nograph  = 1;
            
            for n=1:numel(model)
               n 
                DCM      = DCMsub;
                DCM.name = sprintf('DCM_evk_mod%d_sub%d_%s_%d-%d',n,sname(ss),datafit,Twin(tw,1),Twin(tw,2));
                
                DCM.A = model(n).A;
                DCM.B = model(n).B;
                DCM.C = model(n).C;
                
                if exist(['/imaging/hp02/mmn_08/analysis_spm/DCM/ECD/1_0/my_spm/garrido_with_parietal/' DCM.name '.mat'], 'file')
                    disp('file exists');
                else
                
                    DCM   = spm_dcm_erp(DCM);
                
                end
                %LogEvd(n) = DCM.F;
                
            end % end of models
            
            
            % put here because otherwise the parfor gets unhappy
            for n = 1:numel(model)
                DCM      = DCMsub;
                DCM.name = sprintf('DCM_evk_mod%d_sub%d_%s_%d-%d',n,sname(ss),datafit,Twin(tw,1),Twin(tw,2));
                DCMname{ss,m} = DCM.name;
                
            end
            
        end % End of subjects
        
        
    end %end of the time windows
end
toc
if ParType
    matlabpool close force CBU_Cluster
end
pause
%% BMS
Twin = [0 250];

for dc = 1%:length(datafit)
    for tw = 1:size(Twin,1)
  
        owd = fullfile(cwd,sprintf('BMS_%s_%d_%d',datafit,Twin(tw,1),Twin(tw,2)))
        try eval(sprintf('!mkdir %s',owd)); end

        clear matlabbatch
        matlabbatch{1}.spm.stats.bms.bms_dcm.dir = cellstr(owd);
        ses=1;
        for ss = 1:nr_subs%-1 %if looking at Twin 0-250ms
            subj = sname(ss);
            dcmfile = {};
            for m=1:numel(model)
                DCMname{ss,m} = sprintf('DCM_evk_mod%d_sub%d_%s_%d-%d',m,subj,datafit,Twin(tw,1),Twin(tw,2));
                dcmfile{m} = fullfile(cwd,[DCMname{ss,m} '.mat']);
            end
            matlabbatch{1}.spm.stats.bms.bms_dcm.sess_dcm{ss}(ses).mod_dcm = cellstr(strvcat(dcmfile));
        end
        matlabbatch{1}.spm.stats.bms.bms_dcm.model_sp = {''};
        matlabbatch{1}.spm.stats.bms.bms_dcm.load_f = {''};
        matlabbatch{1}.spm.stats.bms.bms_dcm.method = 'FFX';
        %matlabbatch{1}.spm.stats.bms.bms_dcm.method = 'RFX';
        matlabbatch{1}.spm.stats.bms.bms_dcm.verify_id = 0;  %already done once
        spm_jobman('run',matlabbatch);
        
        %pause       
        

 
    end
end



