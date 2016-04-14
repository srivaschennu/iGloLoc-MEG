clear all;
%Modified from Rik's code "batch_dcm_evk_2con.m"
datafile='mspm8_HRM009-MC_-100_0_dvt_std_prob3_3';

% Specify electrode sources
temp_elec = [35]; 
telec_names = { 'TD4'}; 

frnt_elec = [14];
felec_names = {'G16'};

datafit = 'std_dvt'; datacons = [1:2];

Twin = [ 0 250; ];
Twin_names = {'250'};

LF = 2; HF = 30;

iter=0;
Niter=size(Twin, 1)*length(temp_elec)*length(frnt_elec);

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
        P = cbupool(12);
        matlabpool(P);
    end
end

TransDefaultFlag = 1;
%%
for k = 1:size(Twin, 1) % Loop through time windows
    for i = 1:length(temp_elec) % temporal electrodes
        for j = 1:length(frnt_elec) % Frontal electrodes
            iter=iter+1;
            disp(['%%%%%%%%%%% Iteration k=' int2str(k) ' i=' int2str(i) ' j=' int2str(j) ' %%%%%%%%%%%%%%'])
            disp(['%%%%%%%%%%% Iteration ' int2str(iter) '/' int2str(Niter) ' %%%%%%%%%%%%%%'])
            
            %select pair of electrodes to use in the DCM model
            
            %set all channels as EEG except the ones used for DCM
            S = [];
            S.task = 'settype';
            S.D = datafile;
            S.ind = [1:40];
            S.type = 'EEG';
            S.save = 1;
            D = spm_eeg_prep(S);
            
            %set 2 channels as LFP
            S = [];
            S.task = 'settype';
            S.D = datafile;
            S.ind = [temp_elec(i) frnt_elec(j)]; %temp and front channels used
            S.type = 'LFP';
            S.save = 1;
            D = spm_eeg_prep(S);
            
            % Set up DCM structure
            
            DCMbase = [];
            DCMbase.xY.modality = 'LFP';
            
            DCMbase.options.analysis = 'ERP';
            DCMbase.options.model    = 'ERP';
            DCMbase.options.spatial =  'LFP';
            DCMbase.options.trials  = datacons;  % CR-IO-IS
            DCMbase.options.Tdcm = Twin(k,:);      % start of peri-stimulus time to be modelled
            %        DCMbase.options.Fdcm(1) = LF;      % start of freq to be modelled
            %        DCMbase.options.Fdcm(2) = HF;    % end of freq to be modelled [play with????]
            DCMbase.options.Nmodes  = 2;      % nr of modes
            DCMbase.options.h       = 2;      % nr of polynomial confounds
            DCMbase.options.onset   = 30;    % ASK LAURA (previously 100)
            DCMbase.options.D       = 1;      % downsampling
            DCMbase.options.han     = 1;      % no Hanning
            
            DCMbase.options.lock     = 0;      % (if want modulations to be in same direction for all connections)
            DCMbase.options.location = 0;      % (Not relevant; only for ECD)
            DCMbase.options.symmetry = 0;      % (Not relevant; only for ECD)
            
            DCMbase.options.nograph  = 0;
            
            % Region names (Location, Lpos, irrelevant for LFP)
            DCMbase.Sname = {'Temp'; 'Front'};
            DCMbase.Lpos = [];
            
            DCMbase.xU.X = [1 0]';             %contrast????
            DCMbase.xU.name = datafit;
            
            Nareas = length(DCMbase.Sname);
            
            %% Create a set of models 
            %-----------------------------------------------------
            
            model = [];
            
            Nareas = 2;
            % JUST FORWARD CONNECTIONS:
            model(1).A{1} = [0 0; 1 0];             % forward connection
            model(1).A{2} = [0 0; 0 0];             % backward connection
            model(1).A{3} = [0 0; 0 0];             % lateral
            model(1).B{1} = zeros(Nareas,Nareas);   % Null model
            model(1).C    = [1 0]';                 % Inputs in Temp
            
            m=2;
            model(m) = model(1);
            model(m).B{1}=[0 0; 1 0]; 
            
            m=3;
            model(m) = model(1);
            model(m).C    = [1 1]';                 
            
            m=4;
            model(m) = model(2);
            model(m).C    = [1 1]';                 
            
            
            % FORWARD AND BACKWARD CONNECTIONS:
            
            m=5;
            model(m) = model(1);
            model(m).A{2} = [0 1; 0 0];           
            
            m=6;
            model(m) = model(5);
            model(m).B{1}=[0 0; 1 0]; 
            
            m=7;
            model(m) = model(5);
            model(m).B{1}=[0 1; 0 0];
            
            m=8;
            model(m) = model(5);
            model(m).B{1}=[0 1; 1 0]; 
            
            m=9;
            model(m) = model(5);
            model(m).C    = [1 1]';                 
            
            m=10;
            model(m) = model(6);
            model(m).C    = [1 1]';                 
            
            m=11;
            model(m) = model(7);
            model(m).C    = [1 1]';                
            
            m=12;
            model(m) = model(8);
            model(m).C    = [1 1]';                 
            
            
            
            %%
            DCMsub = DCMbase;
            
            S=[]; S.D = datafile;
            
            DCMsub.xY.Dfile = S.D;
            
            DCMsub = spm_dcm_erp_data(DCMsub,DCMsub.options.h);
            DCMsub = spm_dcm_erp_dipfit(DCMsub, 0);
            
            DCMsub.xY.Ic  = [1 2];%[temp_elec(i) frnt_elec(j)];
            
            DCMsub.options.gety = 0;
            DCMsub.options.nograph  = 1;
            
            %% Fit models
            parfor n=1:numel(model)
                disp(n)
                
                DCM      = DCMsub;
                %    DCM.name = sprintf('DCM_evk_mod_%d',n);
                DCM.name = ['DCM_evk_' telec_names{i} '_' felec_names{j} '_' Twin_names{k} '_mod' int2str(n)];
                
                DCM.A = model(n).A;
                DCM.B = model(n).B;
                DCM.C = model(n).C;
                
                DCM   = spm_dcm_erp(DCM);
                
                LogEvd(n) = DCM.F;
                DCMall{n} = DCM;
                
            end
        end
    end
end

%% at end of script must have this:

if ParType
    matlabpool close force CBU_Cluster
end
