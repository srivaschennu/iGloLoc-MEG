
% This script was not run as below; there was an error in that DCMsub was
% not reset to DCMbase on each iteration - could rerun?

clear

%dosubs = [1 2 3 6 7 8 9 10 11 12];

dosubs = [1 2 3 6 8];  % "good" subjects from paper

cwd = '/imaging/rh01/Collaborations/Bernhard/Well01/iEEG';
cd(cwd)


% Set up DCM structure

DCMbase = [];
DCMbase.xY.modality = 'LFP';
DCMbase.xY.Ic    = [1:2]; % All channels used

DCMbase.options.analysis = 'IND'; 
DCMbase.options.model    = 'ERP';  
DCMbase.options.spatial =  'LFP'; 
DCMbase.options.trials  = [1 2 3];  % CR-IO-IS
DCMbase.options.Tdcm(1) = 0;      % start of peri-stimulus time to be modelled
DCMbase.options.Tdcm(2) = 1500;   % end of peri-stimulus time to be modelled
DCMbase.options.Fdcm(1) = 1;      % start of freq to be modelled
DCMbase.options.Fdcm(2) = 99;    % end of freq to be modelled [play with????]
DCMbase.options.Rft     = 5;      % Morlet wavelet scale
DCMbase.options.Nmodes  = 5;      % nr of modes for data selection (subject 1: Kaiser=3, Scree=5)
DCMbase.options.h       = 1;      % nr of polynomial confounds
DCMbase.options.onset   = 100;    % selection of onset (V1 = 60ms, MTL = 100?)
DCMbase.options.D       = 5;      % downsampling (min of 4ms imposed by spm_dcm_ind_data anyway!)
DCMbase.options.han     = 1;      % no Hanning

DCMbase.options.lock     = 0;      % (if want modulations to be in same direction for all connections)
DCMbase.options.location = 0;      % (Not relevant; only for ECD)
DCMbase.options.symmetry = 0;      % (Not relevant; only for ECD)

DCMbase.options.nograph  = 0;

% Region names (Location, Lpos, irrelevant for LFP)
DCMbase.Sname = {'Rc'; 'Hc'};
DCMbase.Lpos = [];

DCMbase.xU.X = [-1 1 0; 0 -1 1]'; 
DCMbase.xU.name = {'IO - CR', 'IS - IO'};

Nareas = length(DCMbase.Sname);

% Create a set of models (just three here for example)
%-----------------------------------------------------

model = [];

%%%%%%%%%%%%% Model 1 (conditions affect Rc->Hc)

    % Input (C)
model(1).C = [1; 0];     % Input to Rc

    % Intrinsic Connections (A)

model(1).A{1} = ones(Nareas,Nareas);   % fully interconnected (linear)
model(1).A{2} = ones(Nareas,Nareas);   % fully interconnected (nonlinear)

        % Linear connections (within-freq)
        
% model(1).A{1} = zeros(Nareas,Nareas);
% model(1).A{1}(1,2) = 1;   % Rc -> Hc
% 
%         % Nonlinear connections (across-freq)
%         
% model(1).A{2} = zeros(Nareas,Nareas);
% model(1).A{2}(2,1) = 1;   % Hc -> Rc

        % (Third matrix not used for induced)
model(1).A{3} = zeros(Nareas,Nareas);  


      % Modulatory Connections (B) (columns = 'from', rows = 'to'):

model(1).B{1} = zeros(Nareas,Nareas);
model(1).B{1}(1,2) = 1;   % Rc -> Hc (always both lin+nonlin)
model(1).B{2} = zeros(Nareas,Nareas);
model(1).B{2}(1,2) = 1;   % Rc -> Hc (always both lin+nonlin)


%%%%%%%%%%%%% Model 2 (conditions affect Hc->Rc (always both lin+nonlin))

model(2) = model(1);

model(2).B{1} = zeros(Nareas,Nareas);
model(2).B{1}(2,1) = 1;   % Hc -> Rc
model(2).B{2} = zeros(Nareas,Nareas);
model(2).B{2}(2,1) = 1;   % Hc -> Rc


%%%%%%%%%%%%% Model 3 (conditions affect both Rc->Hc and Hc->Rc (always both lin+nonlin)

model(3) = model(1);

model(3).B{1} = zeros(Nareas,Nareas);
model(3).B{1}(1,2) = 1;   % Rc -> Hc
model(3).B{1}(2,1) = 1;   % Hc -> Rc
model(3).B{2} = zeros(Nareas,Nareas);
model(3).B{2}(1,2) = 1;   % Rc -> Hc
model(3).B{2}(2,1) = 1;   % Hc -> Rc


% (Other models could try: 1. Input (C) to Hc (or both)
%                          3. Modulation of self-connections (local effects))

% (ultimately, test same set of models on different timewindows within
% epoch, eg early vs late, to see if directionality changes over time)

LogEvd=[]; DCMname={};

for s = 1:length(dosubs)
    
    sub    = dosubs(s);
   
    DCMsub = DCMbase;
    
%    S=[]; S.D = sprintf('rtf_cbSPM_TFR_format_s%02d_retrieval_cr.mat',sub);
    S=[]; S.D = sprintf('cbSPM_TFR_format_s%02d_retrieval_cr.mat',sub)
    
    DCMsub.xY.Dfile = S.D;

    DCMsub = spm_dcm_erp_dipfit(DCMsub, 1);

    if ~isfield(DCMsub.xY,'source')  % (always true here)
        DCMsub  = spm_dcm_ind_data(DCMsub);
    end
    DCMsub.options.gety = 0;
    DCMsub.options.nograph  = 1;

    for m=1:numel(model)
        
        DCM      = DCMsub;
        DCM.name = sprintf('DCM_ind_mod%d_%s',m,S.D);
        
        DCM.A = model(m).A;
        DCM.B = model(m).B;
        DCM.C = model(m).C;
        
        DCM   = spm_dcm_ind(DCM);   % saves automatically
        
        LogEvd(s,m) = DCM.F;
        DCMname{s,m} = DCM.name;
    end

end


%%%% (put in sep directory, cos dunno how to change output filename yet!)

owd = fullfile(cwd,'BMS_3mod');
try eval(sprintf('!mkdir %s',owd)); end

clear matlabbatch
matlabbatch{1}.spm.stats.bms.bms_dcm.dir = cellstr(owd);
ses=1;
for s=1:length(dosubs)
    sub = dosubs(s);
    dcmfile = {};
    for m=1:numel(model)
%        Dname = sprintf('cbSPM_TFR_format_s%02d_retrieval_cr.mat',sub); 
%        DCMname{s,m} = sprintf('DCM_ind_mod%d_%s',m,Dname);
        dcmfile{m} = fullfile(cwd,DCMname{s,m});
    end
    matlabbatch{1}.spm.stats.bms.bms_dcm.sess_dcm{s}(ses).mod_dcm = cellstr(strvcat(dcmfile));
end
matlabbatch{1}.spm.stats.bms.bms_dcm.model_sp = {''};
matlabbatch{1}.spm.stats.bms.bms_dcm.load_f = {''};
matlabbatch{1}.spm.stats.bms.bms_dcm.method = 'FFX';
%matlabbatch{1}.spm.stats.bms.bms_dcm.method = 'RFX';
%matlabbatch{1}.spm.stats.bms.bms_dcm.family_level(1).family.family_models = [];
%matlabbatch{1}.spm.stats.bms.bms_dcm.family_level(1).family.family_name = [];    
%matlabbatch{1}.spm.stats.bms.bms_dcm.family_level(1).bma.bma_no = 0;
matlabbatch{1}.spm.stats.bms.bms_dcm.verify_id = 0;  %already done once
spm_jobman('run',matlabbatch);


% Assuming matches BMS above!
for s=1:length(dosubs)
    sub = dosubs(s);
    Dname = sprintf('cbSPM_TFR_format_s%02d_retrieval_cr.mat',sub); disp(Dname)
    for m=1:numel(model)
%        DCMname{s,m} = sprintf('DCM_ind_mod%d_%s',m,Dname);
	    load(fullfile(cwd,DCMname{s,m}));
        LogEvd(s,m) = DCM.F;
    end
end

t_matrix(LogEvd,1);
[dummy,maxi] = max(LogEvd(s,:));
    
fprintf('Model %d is best\n',maxi);

P = strvcat(DCMname{:,maxi});
DCM = spm_dcm_average(P,sprintf('N%d_Mod%d',length(dosubs),maxi));

spm_dcm_ind_results(DCM,'Coupling (A - Hz)');
spm_dcm_ind_results(DCM,'Coupling (B - Hz)');
spm_dcm_ind_results(DCM,'Coupling (A - modes)');
spm_dcm_ind_results(DCM,'Coupling (B - modes)');
spm_dcm_ind_results(DCM,'Input (C - Hz)');
    
return

    
%     load(sprintf('DCM_ind_mod%d_%s',maxi,S.D));
%     spm_dcm_ind_results(DCM,'Frequency Modes');
%     spm_dcm_ind_results(DCM,'Time-modes');
%     spm_dcm_ind_results(DCM,'Time-Frequency');

    
    % write out t-f images of best model
    
    dcmfile = sprintf('DCM_ind_%d_%s',maxi,S.D)
    load(dcmfile);
    
    fprintf('Saving the Time-frequency representation at sources\n');
    DCM.saveInd='TFR';
    spm_dcm_ind_results(DCM,'Wavelet');
    
    fprintf('Saving the coupling matrix A\n');
    DCM.saveInd='Amatrix';
    spm_dcm_ind_results(DCM,'Coupling (A - Hz)');
    
    fprintf('Saving the coupling matrix B\n');
    DCM.saveInd='Bmatrix';
    spm_dcm_ind_results(DCM,'Coupling (B - Hz)');
    DCM=rmfield(DCM,'saveInd');
