function epochdata(subjidx)

loadpaths

loadsubj

epochwin   = [-200 1300];

%Aoffset = 13; % Before sound-card change
Aoffset = 32;  % After sound-card change (ie now!)
%Voffset = 34;  % Amazingly Visual projection delay very similar, so might as well use Aoffset!

[~,~,markers] = xlsread('MARKERS.xls');
markers = markers(2:end,[1 2 3]);

%% Start Preprocessing...

subjname = subjlist{subjidx,1};

out_wd = filepath;
fD = {};

for sessidx = 1:size(subjlist{subjidx,2},1)
    sesstype = subjlist{subjidx,2}{sessidx,1};
    runlist = subjlist{subjidx,2}{sessidx,2};
    
    fprintf('\nLoading data from %s session of %s...\n',sesstype,subjname);
    
    for run = runlist
        %% load data
        file2load = sprintf('%s%s_%s_run%02d.mat',filepath,lower(subjname),sesstype,run);
        fprintf('\nLoading %s.\n',file2load);
        D = spm_eeg_load(file2load);
        
        %% Calculate samples of trials of interest
        fprintf('\nCalculating trial extents...\n');
        eventlist = D.events;
        timelist = D.time;
        trlsamp = [];
        trllabel = {};
        epochsampwin = (((epochwin+Aoffset)/1000) * D.fsample);
        epochoffset = (epochwin(1)/1000) * D.fsample;
        
        for e = 1:length(eventlist)
            if strcmp(eventlist(e).type, 'STI101_up')
                
                evtype = [upper(sesstype(1)) markers{eventlist(e).value,2}];
                if ~isnan(markers{eventlist(e).value,3})
                    evtype = [evtype sprintf('%d',markers{eventlist(e).value,3})];
                end
                
                switch evtype(2:end)
                    case {'BGIN', 'BEND', 'SESS', 'VINS'}
                        stdcount = 0;
                        prevdev = 0;
                        firstdev = false;
                        
                    otherwise
                        switch evtype(3:4)
                            case 'CL'
                                evsamp = find(min(abs(timelist-eventlist(e).time)) == abs(timelist-eventlist(e).time));
                                trlsamp = cat(1, trlsamp, [evsamp+epochsampwin epochoffset]);
                                trllabel = cat(1,trllabel,{evtype});
                                
                            otherwise
                                stimtype = str2double(evtype(5));
                                if ~isempty(stimtype)
                                    switch stimtype
                                        case 1
                                            if ~exist('stdcount','var')
                                                stdcount = 0;
                                                prevdev = 0;
                                                firstdev = false;
                                            end
                                            
                                            %only select first standard
                                            %after deviant of type 3
                                            if stdcount == 1 && prevdev == 3
                                                evsamp = find(min(abs(timelist-eventlist(e).time)) == abs(timelist-eventlist(e).time));
                                                trlsamp = cat(1, trlsamp, [evsamp+epochsampwin epochoffset]);
                                                trllabel = cat(1,trllabel,{evtype});
                                            end
                                            if firstdev
                                                stdcount = stdcount + 1;
                                            end
                                            
                                        case {2,3}
                                            if firstdev == false
                                                firstdev = true;
                                            end
                                            prevdev = stimtype;
                                            stdcount = 1;
                                            evsamp = find(min(abs(timelist-eventlist(e).time)) == abs(timelist-eventlist(e).time));
                                            trlsamp = cat(1, trlsamp, [evsamp+epochsampwin epochoffset]);
                                            trllabel = cat(1,trllabel,{evtype});
                                    end
                                end
                        end
                end
            end
        end
        fprintf('Extracting following epoch types and counts from run %d.\n', run);
        trltypes = unique(trllabel);
        for t = 1:length(trltypes)
            fprintf('%s: %d\n',trltypes{t},sum(strcmp(trltypes{t},trllabel)));
        end
        fprintf('\n');
        
        %% Epoching
        S = [];
        S.D = D;
        S.bc = 1;
        S.trl = trlsamp;
        S.conditionlabels = trllabel;
        D = spm_eeg_epochs(S);
        fprintf('Extracted %d epochs.\n',D.ntrials);
        
        %% append current run to list
        fD = cat(2,fD,{D});
    end
end

%% Concatenate runs into one file
cur_wd = cd(out_wd);
fprintf('\nMerging runs...\n');
if numel(fD)>1
    S = [];
    S.D = fname(fD{1});
    for f = 2:numel(fD)
        S.D = char(S.D, fname(fD{f}));
    end
    S.recode = 'same';
    D = spm_eeg_merge(S);
    
    for f = 1:numel(fD)
        delete(fD{f});
    end
elseif numel(fD)==1
    D = fD{1};
else
    error('!!!')
end

%% copy data over to final file
S = [];
S.D = D;
S.outfile = sprintf('%s_epochs.mat',lower(subjname));
fprintf('\nCopying to %s.\n',S.outfile);
spm_eeg_copy(S);
delete(S.D);

cd(cur_wd);

