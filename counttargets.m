function counttargets

loadpaths

loadsubj

[~,~,markers] = xlsread('MARKERS.xls');
markers = markers(2:end,[1 2 3]);

%% Start Preprocessing...

for subjidx = 1:size(subjlist,1)
    subjname = subjlist{subjidx,1};
    
    for sessidx = 1:size(subjlist{subjidx,2},1)
        sesstype = subjlist{subjidx,2}{sessidx,1};
        runlist = subjlist{subjidx,2}{sessidx,2};
        blocknum = 0;
        
        fprintf('\nLoading data from %s session of %s...\n',sesstype,subjname);
        
        for run = runlist
            %% load data
            file2load = sprintf('%s%s_%s_run%02d.mat',filepath,lower(subjname),sesstype,run);
            %         fprintf('\nLoading %s.\n',file2load);
            D = spm_eeg_load(file2load);
            
            %% Calculate samples of trials of interest
            %         fprintf('\nCalculating trial extents...\n');
            eventlist = D.events;
            inblock = false;
            
            for e = 1:length(eventlist)
                if strcmp(eventlist(e).type, 'STI101_up')
                    
                    evtype = [upper(sesstype(1)) markers{eventlist(e).value,2}];
                    if ~isnan(markers{eventlist(e).value,3})
                        evtype = [evtype sprintf('%d',markers{eventlist(e).value,3})];
                    end
                    
                    switch evtype(2:end)
                        case {'BGIN' 'SESS' 'VINS'}
                            if ~inblock
                                blocknum = blocknum+1;
                                if strcmp(sesstype,'global')
                                    atargcount(subjidx,blocknum) = 0;
                                elseif strcmp(sesstype,'visual')
                                    vtargcount(subjidx,blocknum) = 0;
                                end
                                inblock = true;
                            end
                            
                        case {'BEND'}
                            if strcmp(sesstype,'global')
                                if atargcount(subjidx,blocknum) < 5
                                    blocknum = blocknum-1;
                                else
                                    fprintf('Block %d (%s): %d auditory targets.\n',...
                                        blocknum,blockname,atargcount(subjidx,blocknum));
                                end
                            elseif strcmp(sesstype,'visual')
                                if vtargcount(subjidx,blocknum) < 5
                                    blocknum = blocknum-1;
                                else
                                    fprintf('Block %d (%s): %d visual targets.\n',...
                                        blocknum,blockname,vtargcount(subjidx,blocknum));
                                end
                            end
                            inblock = false;
                            
                        case 'DIST'
                            if ~inblock
                                blocknum = blocknum+1;
                                vtargcount(subjidx,blocknum) = 0;
                                inblock = true;
                            end
                            
                        case 'TARG'
                            vtargcount(subjidx,blocknum) = vtargcount(subjidx,blocknum)+1;
                            
                        otherwise
                            switch evtype(3:4)
                                case 'CL'
                                    if evtype(1) == 'G'
                                        blockname = evtype(1:4);
                                        if ~inblock
                                            blocknum = blocknum+1;
                                            atargcount(subjidx,blocknum) = 0;
                                            inblock = true;
                                        end
                                        
                                        atargcount(subjidx,blocknum) = atargcount(subjidx,blocknum)+1;
                                    end
                                    
                                otherwise
                                    stimtype = str2double(evtype(5));
                                    if ~isnan(stimtype)
                                        blockname = evtype(1:4);
                                        switch stimtype
                                            case {2,3}
                                                if evtype(1) == 'G'
                                                    if ~inblock
                                                        blocknum = blocknum+1;
                                                        atargcount(subjidx,blocknum) = 0;
                                                        inblock = true;
                                                    end

                                                    atargcount(subjidx,blocknum) = atargcount(subjidx,blocknum)+1;
                                                end
                                        end
                                    end
                            end
                    end
                end
            end
        end
    end
    save targcount.mat atargcount vtargcount
end

