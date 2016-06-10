function batchjob

loadsubj
loadpaths

spm('defaults','EEG');

% TASKS TO BE RUN IN SEQUENCE FOR EACH SUBJECT'S DATASET
tasklist = {
    %run maxfilter
    'runmaxfilter'    '{subjidx}'
    %import data into SPM
    'dataimport'      '{subjidx}'
    %convert continuous data to epochs
    'epochdata'       '{subjidx}'
    %build forward model
    'modelhead'       'subjlist(subjidx,1)'
    %visually identify bad channels and trials
    'markbad'         '{[subjlist{subjidx,1} ''_epochs'']}'
    %reject bad trials
    'rejartifacts'    '{subjlist{subjidx,1} ''_epochs'' ''_clean''}'
    %compute ICA
    'computeic'       'subjlist(subjidx,1)'
    %mark bad ICA components
    'markic'          'subjlist(subjidx,1)'
    %visually reject bad ICA components
    'rejectic'        'subjlist(subjidx,1)'
    %mark remaining bad channels and trials
    'markbad'         '{[subjlist{subjidx,1} ''_ica'']}'
    %reject remaining bad trials
    'rejartifacts'    '{subjlist{subjidx,1} ''_ica'' ''''}'
    %re-reference data to common average
    'rereference'     'subjlist(subjidx,1)'
    %calculate ERPs for conditions of interest
    'calcerp'         'subjlist(subjidx,1)'
    %re-baseline the trials to the onset of the 5th tone
    'subcond'         'subjlist(subjidx,1)'
    %combine MEG planar gradiometers with RMS
    'combineplanar'   'subjlist(subjidx,1)'
    %generage images for SPM statistics
    'genimg'          '{subjlist{subjidx,1} ''sensor'' ''EEG''}'
    %run DCM modelling
    'rundcm'   'subjlist(subjidx,1)'
    };

fprintf('Preparing jobs.\n');
j = 1;
lastjob = zeros(size(subjlist,1),1);
for t = 1:size(tasklist,1)
    for subjidx = 1:size(subjlist,1)
        jobs(j).task = str2func(tasklist{t,1});
        jobs(j).input_args = eval(tasklist{t,2});
        jobs(j).n_return_values = 0;
        
        if isempty(strfind(tasklist{t,2},'subjidx'))
            jobs(j).depends_on = unique(lastjob);
            lastjob(:) = j;
            j= j+1;
            break;
        else
            jobs(j).depends_on = lastjob(subjidx);
            lastjob(subjidx) = j;
            j = j+1;
        end
    end 
end

for j = 1:length(jobs)
    disp(jobs(j));
    jobs(j).task(jobs(j).input_args{:});
end


%% ADDITIONAL SCRIPTS FOR STATISTICAL ANALYSIS AND PLOTTING

% run SPM statistics
spmbatch
% run SPM contrasts
runcon
% plot significant clusters identified by SPM
plotclusters
% run BMS over DCM fits
