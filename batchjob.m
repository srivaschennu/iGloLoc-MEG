function batchjob

loadsubj
loadpaths

jobqueue = 'compute';
numworkers = size(subjlist,1);
memory = 16;
walltime = 3600*16;

spm('defaults','EEG');

curpath = path;
matlabpath = strrep(curpath,':',''';''');
matlabpath = eval(['{''' matlabpath '''}']);
workerpath = cat(1,{pwd},matlabpath(1:end-1));

jobspath = [filepath 'Jobs/'];

fprintf('Deleting existing Jobs directory.\n');
if exist(jobspath,'dir')
    rmdir(jobspath,'s');
end

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
    'genimg'          '{subjlist{subjidx,1} ''sensor'' ''MEGCOMB''}'
%     'genimg'          '{subjlist{subjidx,1} ''source'' 3}'
%     'rundcm'   'subjlist(subjidx,1)'
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
%     jobs(j).task(jobs(j).input_args{:});
end

fprintf('Scheduling jobs.\n');
scheduler = cbu_scheduler('custom',{jobqueue,numworkers,memory,walltime,jobspath});
cbu_qsub(jobs,scheduler,workerpath);
