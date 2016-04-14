

% reduce detrending?
% (try re-computing F+S and F-only in data, then making B=Fonly, like fMRI)

% clear

%addpath('/imaging/local/software/spm_cbu_svn/devel/spm8')
%spm('defaults','eeg')

clear

cwd = '/imaging/rh01/Collaborations/Dan/CROI_DCM'

dosubs = [1 2 3 5 6 8 9 10 11 12 15 16 17 18 19 23 24 25]; 

% Set up DCM structure

DCMbase = [];
DCMbase.xY.modality = 'LFP';
DCMbase.options.analysis = 'ERP'; 
DCMbase.options.model    = 'ERP';  
DCMbase.options.spatial =  'LFP'; 
DCMbase.options.trials  = [3 4];  % [3 4] for CROI ([1 2] ROI)
DCMbase.options.Tdcm(1) = 0;      % start of peri-stimulus time to be modelled
DCMbase.options.Tdcm(2) = 400;   % end of peri-stimulus time to be modelled
DCMbase.options.Nmodes  = 5;      % nr of modes for data selection 
DCMbase.options.h       = 4;      % nr of DCT components for detrending [increase to 4????]
DCMbase.options.onset   = 60;     % selection of onset (prior mean = 60ms for onset at 0)
DCMbase.options.D       = 1;      % downsampling
DCMbase.options.han     = 0;      % Hanning

DCMbase.options.lock     = 0;      % (if want modulations to be in same direction for all connections)
DCMbase.options.location = 0;      % (Not relevant; only for ECD)
DCMbase.options.symmetry = 0;      % (Not relevant; only for ECD)

DCMbase.options.gety = 1;
DCMbase.options.nograph  = 0;

% Region names (Location, Lpos, irrelevant for LFP)
DCMbase.Sname = {'lffa','rffa','lofa','rofa','rsts'};
DCMbase.Lpos = [];

DCMbase.xU.X = [1; -1]; % F-S
%DCMbase.xU.X = [1; 0];  % F
DCMbase.xU.name = {'F-S'};

Nareas = length(DCMbase.Sname);

% Create a set of models
%------------------------

model = [];

%%%%%%%%%%%%% Intrinsic connections (columns = 'from', rows = 'to');

for m = 1:9
    model(m).A{1} = [0 0 1 0 0;
                     0 0 0 1 0;
                     0 0 0 0 0;
                     0 0 0 0 0;
                     0 0 0 1 0]; % Forward
    
    model(m).A{2} = [0 0 0 0 0;
                     0 0 0 0 0;
                     1 0 0 0 0;
                     0 1 0 0 1;
                     0 0 0 0 0]; % Backward
                 
    model(m).A{3} = [0 1 0 0 0;
                     1 0 0 0 0;
                     0 0 0 1 0;
                     0 0 1 0 0;
                     0 0 0 0 0]; % Lateral
end

%%%%%%%%%%%%% Inputs (C)

for m =1:3
    model(m).C = [0; 0; 1; 1; 0];   % Input to bofa
end
for m = 4:6
    model(m).C = [1; 1; 0; 0; 0];   % Input to bffa
end
for m = 7:9
    model(m).C = [1; 1; 1; 1; 0];   % Input to bofa+bffa
end

%%%%%%%%%%%%%% Modulatory Connections (B), apply to all types of intrinsic
%%%%%%%%%%%%%% (last index is for inputs, but only one here, ie F-S)

model(1).B{1} = [0 0 1 0 0;
                 0 0 0 1 0;
                 0 0 0 0 0;
                 0 0 0 0 0;
                 0 0 0 1 0]; % Forward
             
model(2).B{1} = [0 0 0 0 0;
                 0 0 0 0 0;
                 1 0 0 0 0;
                 0 1 0 0 1;
                 0 0 0 0 0]; % Backward
             
model(3).B{1} = [0 0 1 0 0;
                 0 0 0 1 0;
                 1 0 0 0 0;
                 0 1 0 0 1;
                 0 0 0 1 0]; % F + B

for m=1:3
    model(m+3).B = model(m).B;
    model(m+6).B = model(m).B;
end


% Null (baseline) model 1 - no modulation by Fac (input to both)

model(10)=model(9);
model(10).B{1} = zeros(5); 


LogEvd=[]; DCMname={};

for s = 1:length(dosubs)
    
    sub    = dosubs(s);
   
    DCMsub = DCMbase;

    S=[]; S.D = sprintf('bsubject_%02d',dosubs(s))
    
    DCMsub.xY.Dfile = S.D;

    DCMsub = spm_dcm_erp_data(DCMsub,DCMsub.options.h);
    DCMsub = spm_dcm_erp_dipfit(DCMsub, 0);

    DCMsub.options.gety = 0;
    DCMsub.options.nograph  = 1;
  
    for n=1:numel(model)
        
        DCM      = DCMsub;
%        DCM.name = sprintf('DCM_erp_croi_mod%d_%s_spm8rikdevel.mat',n,S.D);       
%        DCM.name = sprintf('DCM_erp_croi_mod%d_%s_spm8cbudevel.mat',n,S.D);       
%        DCM.name = sprintf('DCM_erp_roi_mod%d_%s_spm8cbudevel.mat',n,S.D);       
%        DCM.name = sprintf('DCM_erp_croi_mod%d_%s_spm8fildevel.mat',n,S.D);       
        DCM.name = sprintf('DCM_erp_croi_mod%d_%s_spm8rel.mat',n,S.D);
        
        DCM.A = model(n).A;
        DCM.B = model(n).B;
        DCM.C = model(n).C;
        
        DCM   = spm_dcm_erp(DCM);
        
        LogEvd(n) = DCM.F;
        DCMname{s,m} = DCM.name;
        
    end
end

[dummy,maxi] = max(LogEvd);

fprintf('Model %d is best',maxi);

load(sprintf('DCM_erp_%d_%s',maxi,D.fname));
% spm_dcm_erp_results_rik(DCM,'Coupling (C)');
spm_dcm_erp_results_rik(DCM,'Coupling (A)');
% spm_dcm_erp_results_rik(DCM,'Coupling (B)');
spm_dcm_erp_results_rik(DCM,'Response'); 
 
% spm_dcm_erp_results_rik(DCM,'ERPs (mode)');
% spm_dcm_erp_results_rik(DCM,'ERPs (sources)');

    
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
        DCM.name = sprintf('DCM_ind_mod%d_sub%d_%s_%d-%d',m,sub,datafit,Twin(1),Twin(2));
        
        DCM.A = model(m).A;
        DCM.B = model(m).B;
        DCM.C = model(m).C;
        
        DCM   = spm_dcm_ind(DCM);   % saves automatically
        
        LogEvd(s,m) = DCM.F;
        DCMname{s,m} = DCM.name;
    end

end

