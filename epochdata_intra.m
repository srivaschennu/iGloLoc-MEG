function epochdata_intra(subjname)

loadpaths

loadsubj

epochwin   = [-200 1300];

%Aoffset = 13; % Before sound-card change
Aoffset = 0;  % After sound-card change (ie now!)
%Voffset = 34;  % Amazingly Visual projection delay very similar, so might as well use Aoffset!

%% Start Preprocessing...

sessnames = {'global','visual'};

out_wd = filepath;
fD = {};

for sessidx = 1:length(sessnames)
    sesstype = sessnames{sessidx};
    
    [~,~,markers] = xlsread('MARKERS_intra.xls',sesstype);
    markers = markers(2:end,[1 2 3]);
    
    fprintf('\nLoading data from %s session of %s...\n',sesstype,subjname);
    
    %% load data
    file2load = sprintf('%s%s_%s.mat',filepath,lower(subjname),sesstype);
    fprintf('\nLoading %s.\n',file2load);
    D = spm_eeg_load(file2load);
    
    %% Calculate samples of trials of interest
    fprintf('\nCalculating trial extents...\n');
    eventlist = D.events;
    timelist = D.time;
    trlsamp = [];
    trllabel = {};
    epochsampwin = round(((epochwin+Aoffset)/1000) * D.fsample);
    epochoffset = round((epochwin(1)/1000) * D.fsample);
    
    for e = 1:length(eventlist)
        evidx = find(str2double(eventlist(e).value) == cell2mat(markers(:,1)));
        if strcmp(eventlist(e).type, 'trigger') && ~isempty(evidx)
            evtype = [upper(sesstype(1)) markers{evidx,2}];
            if ~isnan(markers{evidx,3})
                evtype = [evtype sprintf('%d',markers{evidx,3})];
            end
            
            switch evtype(2:end)
                case {'BGIN', 'BEND', 'SESS', 'VINS'}
                    stdcount = 0;
                    prevdev = 0;
                    firstdev = false;
                    
                otherwise
                    switch evtype(3:4)
                        case 'CL'
                            evsamp = find(min(abs(timelist-eventlist(e).time)) == abs(timelist-eventlist(e).time),1);
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
                                            evsamp = find(min(abs(timelist-eventlist(e).time)) == abs(timelist-eventlist(e).time),1);
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
                                        evsamp = find(min(abs(timelist-eventlist(e).time)) == abs(timelist-eventlist(e).time),1);
                                        trlsamp = cat(1, trlsamp, [evsamp+epochsampwin epochoffset]);
                                        trllabel = cat(1,trllabel,{evtype});
                                end
                            end
                    end
            end
        end
    end
    fprintf('Extracting following epoch types and counts from %s session.\n', sesstype);
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

