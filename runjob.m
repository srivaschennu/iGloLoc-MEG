function tasks = runjob(runmode)

% runmode = serial, local or phoenix
loadpaths
loadsubj

tasklist = {
%     'moveinfo'        '{subjidx}'
%     'dataimport'      '{subjidx}'
%     'epochdata'       '{subjidx}'
%     'modelhead'       'subjlist(subjidx,1)'
%     'markbad'         '{[subjlist{subjidx,1} ''_epochs'']}'
%     'readbad'         '{[subjlist{subjidx,1} ''_epochs'']}'
%     'rejartifacts'    '{subjlist{subjidx,1} ''_epochs'' ''_clean''}'
%     'computeic'       'subjlist(subjidx,1)'
%     'markic'          'subjlist(subjidx,1)'
%     'rejectic'        'subjlist(subjidx,1)'
%     'markbad'         '{[subjlist{subjidx,1} ''_ica'']}'
%     'readbad'         '{[subjlist{subjidx,1} ''_ica'']}'
%     'rejartifacts'    '{subjlist{subjidx,1} ''_ica'' ''''}'
%     'rereference'     'subjlist(subjidx,1)'
%     'ctnorm'     'subjlist(subjidx,1)'
%     'calcerp'         'subjlist(subjidx,1)'
%     'combineplanar'   'subjlist(subjidx,1)'
%     'subcond'         'subjlist(subjidx,1)'
%     'srcrecon'        '{}'
%     'grandaverage'        '{}'
%     'genimg'          '{subjlist{subjidx,1} ''sensor'' ''EEG''}'
%     'genimg'          '{subjlist{subjidx,1} ''source'' 3}'
%     'rundcm'   'subjlist(subjidx,1)'
    'filecopy'         'subjlist(subjidx,1)'
    };


%% -- INITIALISATION

if strcmp(runmode,'serial')
    for subjidx = 1:size(subjlist,1)
        for taskidx = 1:size(tasklist,1)
            tasks(subjidx,taskidx).func = str2func(tasklist{taskidx,1});
            tasks(subjidx,taskidx).inputs = eval(tasklist{taskidx,2});
            disp(tasks(subjidx,taskidx));
            tasks(subjidx,taskidx).func(tasks(subjidx,taskidx).inputs{:});
        end
    end
    return;
end

% -- Add current MATLAB path to worker path
curpath = path;
matlabpath = strrep(curpath,pathsep,''';''');
matlabpath = eval(['{''' matlabpath '''}']);
% matlabpath = matlabpath(~cellfun(@isempty,strfind(matlabpath,'M:\MATLAB\')));
workerpath = cat(1,{pwd},matlabpath);

if exist('rawpath','var')
    workerpath = cat(1,{rawpath},workerpath);
end

if exist('filepath','var')
    workerpath = cat(1,{filepath},workerpath);
end

workerpath = strrep(workerpath,'M:\','\\csresws.kent.ac.uk\exports\home\');

%% -- MAIN SEQUENCE
% -- Step 1: Create a cluster object
disp('Connecting to Cluster.');

if strcmp(runmode,'local')
    clust = parcluster('local');        % Run this on the local desktop
    hostname = get(clust,'Host');
    disp(['Cluster not selected. Job runs on local desktop: ' hostname]);
    
elseif strcmp(runmode,'phoenix')
    hpc_profile = 'HPCServerProfile1'; % The MATLAB Cluster Profile to use
    clust = parcluster(hpc_profile);    % Run on a HPC Cluster
    hostname = get(clust,'Host');
    disp(['Cluster selected: ' hostname]);
end
disp(['No of Workers: ' num2str(clust.NumWorkers)]);

%-- Step 2: Create job and attach any required files
disp('Creating job, attaching files.');
clust_job = createJob(clust,'AdditionalPaths',workerpath');
clust_job.AutoAttachFiles = false;      % Important, this speeds thigs up

% -- Step 3: Create the input for the tasks
disp('Creating input for tasks.');

% -- Step 4: Create the tasks and add to the job
disp('Creating tasks, adding to job... ');
for subjidx = 1:size(subjlist,1)
    for taskidx = 1:size(tasklist,1)
        tasks(subjidx,taskidx) = createTask(clust_job, str2func(tasklist{taskidx,1}), 0, eval(tasklist{taskidx,2}),'CaptureDiary',true);
    end
end

fprintf('created %d tasks.\n',length(tasks(:)));

% -- Step 5: Submit the job to the cluster queue
disp('Submitting job to cluster queue.');
submit(clust_job);
