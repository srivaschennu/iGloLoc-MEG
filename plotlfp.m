function plotlfp(subjinfo,condlist,varargin)

loadpaths

load conds.mat

timeshift = 600; %milliseconds

param = finputcheck(varargin, { 'ylim', 'real', [], [0 15]; ...
    'subcond', 'string', {'on','off'}, 'on'; ...
    'legendstrings', 'cell', {}, condlist; ...
    'plotchan','cell', {}, {}; ...
    'zscore', 'string', {'on','off'}, 'on'; ...
    'topowin', 'real', [], []; ...    
    });

gridinfo = {
    'Gri' [
    64:-1:57
    56:-1:49
    48:-1:41
    40:-1:33
    32:-1:25
    24:-1:17
    16:-1:9
    8:-1:1
    ]
    
    'GTO' [
    1:8
    9:16
    ]
    
    'GPI' [
    1:8
    9:16
    ]
    
    };

%% SELECTION OF SUBJECTS AND LOADING OF DATA

loadsubj;

if ischar(subjinfo)
    %%%% perform single-trial statistics
    subjlist = {subjinfo};
    subjcond = condlist;
    statmode = 'trial';
    
elseif isnumeric(subjinfo) && length(subjinfo) == 1
    %%%% perform within-subject statistics
    subjlist = subjlists{subjinfo};
    subjcond = repmat(condlist,length(subjlist),1);
    statmode = 'cond';
    
elseif isnumeric(subjinfo) && length(subjinfo) == 2
    %%%% perform across-subject statistics
    subjlist1 = subjlists{subjinfo(1)};
    subjlist2 = subjlists{subjinfo(2)};
    statmode = 'subj';
    
    numsubj1 = length(subjlist1);
    numsubj2 = length(subjlist2);
    subjlist = cat(1,subjlist1,subjlist2);
    subjcond = cat(1,repmat(condlist(1),numsubj1,1),repmat(condlist(2),numsubj2,1));
    if length(condlist) == 3
        subjcond = cat(2,subjcond,repmat(condlist(3),numsubj1+numsubj2,1));
    end
end

numsubj = length(subjlist);
numcond = size(subjcond,2);

conddata = cell(numsubj,numcond);

%% load and prepare individual subject datasets

for s = 1:numsubj
    EEG = pop_loadset('filename', sprintf('%s.set', subjlist{s}), 'filepath', filepath);
    EEG = sortchan(EEG);
    
    % %     rereference
    %     EEG = rereference(EEG,1);
    
    %%%%% baseline correction relative to 5th tone
    bcwin = [-200 0];
    bcwin = bcwin+timeshift;
    EEG = pop_rmbase(EEG,bcwin);
    %%%%%
    
    % THIS ASSUMES THAT ALL DATASETS HAVE SAME NUMBER OF ELECTRODES
    if s == 1
        chanlocs = EEG.chanlocs;
        erpdata = zeros(EEG.nbchan,EEG.pnts,numcond,numsubj);
    end
    
    for c = 1:numcond
        selectevents = conds.(subjcond{s,c}).events;
        selectsnum = conds.(subjcond{s,c}).snum;
        selectpred = conds.(subjcond{s,c}).pred;
        
        typematches = false(1,length(EEG.epoch));
        snummatches = false(1,length(EEG.epoch));
        predmatches = false(1,length(EEG.epoch));
        for ep = 1:length(EEG.epoch)
            
            epochtype = EEG.epoch(ep).eventtype;
            if iscell(epochtype)
                epochtype = epochtype{cell2mat(EEG.epoch(ep).eventlatency) == 0};
            end
            if sum(strcmp(epochtype,selectevents)) > 0
                typematches(ep) = true;
            end
            
            epochcodes = EEG.epoch(ep).eventcodes;
            if iscell(epochcodes{1,1})
                epochcodes = epochcodes{cell2mat(EEG.epoch(ep).eventlatency) == 0};
            end
            
            snumidx = strcmp('SNUM',epochcodes(:,1)');
            if exist('selectsnum','var') && ~isempty(selectsnum) && sum(snumidx) > 0
                if sum(epochcodes{snumidx,2} == selectsnum) > 0
                    snummatches(ep) = true;
                end
            else
                snummatches(ep) = true;
            end
            
            predidx = strcmp('PRED',epochcodes(:,1)');
            if exist('selectpred','var') && ~isempty(selectpred) && sum(predidx) > 0
                if sum(epochcodes{predidx,2} == selectpred) > 0
                    predmatches(ep) = true;
                end
            else
                predmatches(ep) = true;
            end
        end
        
        selectepochs = find(typematches & snummatches & predmatches);
        fprintf('\nCondition %s: found %d matching epochs.\n',subjcond{s,c},length(selectepochs));
        
        if length(selectepochs) == 0
            fprintf('Skipping %s...\n',subjlist{s});
            continue;
        end
        
        conddata{s,c} = pop_select(EEG,'trial',selectepochs);
        
                if c > 1 && c == numcond
                    if conddata{s,1}.trials > conddata{s,2}.trials
                        fprintf('Equalising trials in condition %s.\n',subjcond{s,1});
                        conddata{s,1} = pop_select(conddata{s,1},'trial',1:conddata{s,2}.trials);
                    elseif conddata{s,2}.trials > conddata{s,1}.trials
                        fprintf('Equalising trials in condition %s.\n',subjcond{s,2});
                        conddata{s,2} = pop_select(conddata{s,2},'trial',1:conddata{s,1}.trials);
                    end
                end
        
        erpdata(:,:,c,s) = mean(conddata{s,c}.data,3);
    end
end

if strcmp(statmode,'subj')
    if numcond == 2
        erpdata = erpdata(:,:,1,:) - erpdata(:,:,2,:);
        condlist = {sprintf('%s-%s',condlist{1},condlist{3}),sprintf('%s-%s',condlist{2},condlist{3})};
    end
    if strcmp(param.subcond,'on')
        erpdata = mean(erpdata(:,:,:,1:numsubj1),4) - mean(erpdata(:,:,:,numsubj1+1:end),4);
        condlist = {sprintf('%s-%s',condlist{1},condlist{2})};
    else
        erpdata = cat(3, mean(erpdata(:,:,:,1:numsubj1),4), mean(erpdata(:,:,:,numsubj1+1:end),4));
    end
else
    if strcmp(statmode,'cond') && numcond == 3
        erpdata(:,:,1,:) = erpdata(:,:,1,:) - erpdata(:,:,3,:);
        erpdata(:,:,2,:) = erpdata(:,:,2,:) - erpdata(:,:,3,:);
        erpdata = erpdata(:,:,[1 2],:);
        numcond = 2;
        condlist = {sprintf('%s-%s',condlist{1},condlist{3}),sprintf('%s-%s',condlist{2},condlist{3})};
    end
    
    if numcond == 2 && strcmp(param.subcond,'on')
        for s = 1:size(erpdata,4)
            erpdata(:,:,3,s) = erpdata(:,:,1,s) - erpdata(:,:,2,s);
        end
        condlist = cat(2,condlist,{sprintf('%s-%s',condlist{1},condlist{2})});
        
        erpdata = erpdata(:,:,3,:);
        condlist = condlist(3);
    end
    erpdata = mean(erpdata,4);
end

%% PLOTTING

if isempty(param.plotchan)
    plotchan = 1:EEG.nbchan;
else
    plotchan = [];
    for chan = 1:length(param.plotchan)
        plotchan = cat(1,plotchan,find(strcmp(param.plotchan{chan},{EEG.chanlocs.labels})));
    end
end

if isempty(plotchan)
    fprintf('No channels selected for plotting!\n');
    return;
end

linewidth = 2;
fontsize = 20;

times = (EEG.times-timeshift)/1000;
blidx = 1:(find(EEG.times == 0)-1);

for c = 1:size(erpdata,3)
    plotdata = erpdata(plotchan,:,c);
    
    if isempty(param.topowin)
        param.topowin = [0 EEG.times(end)-timeshift];
    end
    latpnt = find(EEG.times-timeshift >= param.topowin(1) & EEG.times-timeshift <= param.topowin(2));
    [~, maxidx] = max(abs(plotdata(:,latpnt)),[],2);
    plotidx = latpnt(1)-1+maxidx;

    if strcmp(param.zscore,'on')
        %calculate absolute z-score
        for chan = 1:size(plotdata,1)
            plotdata(chan,:) = abs((plotdata(chan,:) - mean(plotdata(chan,blidx)))/std(plotdata(chan,blidx)));
        end
        param.ylabel = 'LFP z-score';
    else
        param.ylabel = 'LFP (uV)';
    end

    %plot LFP data
    figure('Name',condlist{c});
    subplot(2,1,1);
    grididx = find(strncmp(param.plotchan{1}(1:3),{EEG.chanlocs.labels},3));
    gridlayout = gridinfo{strcmp(param.plotchan{1}(1:3),gridinfo(:,1)),2};

    datavals = zeros(size(gridlayout));
    gridchan = {EEG.chanlocs(grididx).labels};
    for g = 1:length(gridchan)
        datavals(gridlayout == str2double(gridchan{g}(4:end))) = erpdata(grididx(g),plotidx);
    end
    
    [xvals,yvals] = meshgrid(1:0.05:size(datavals,2),1:0.05:size(datavals,1));
    gdatavals = griddata(1:size(datavals,2),1:size(datavals,1),datavals,xvals,yvals,'v4');
    imagesc(1:size(datavals,2),1:size(datavals,1),gdatavals);
    axespos = get(gca,'Position');
    set(gca,'XTick',[],'YTick',[],...
    'Position',[axespos(1)+(axespos(3)-axespos(4))/2 axespos(2) axespos(4) axespos(4)]);
    title(sprintf('%.3f sec',times(plotidx)),'FontSize',fontsize);
    colorbar
    caxis(param.ylim);
    for row = 1:size(gridlayout,1)
        for col = 1:size(gridlayout,2)
            text(col,row,num2str(gridlayout(row,col)));
        end
    end
    
    subplot(2,1,2);
    plot(times,plotdata','LineWidth',linewidth*1.5);
    set(gca,'YLim',param.ylim,'XLim',[times(1) times(end)],'XTick',times(1):0.2:times(end),...
        'FontSize',fontsize);
    xlabel('Time relative to 5th tone (sec)','FontSize',fontsize);
    ylabel(param.ylabel,'FontSize',fontsize);
    legend({EEG.chanlocs(plotchan).labels});
    
    line([times(plotidx) times(plotidx)],ylim,'LineWidth',linewidth,'Color','red','LineStyle','--');
    line([times(1) times(end)],[0 0],'LineWidth',linewidth,'Color','black','LineStyle',':');
    line([-0.60 -0.60],ylim,'LineWidth',linewidth,'Color','black','LineStyle',':');
    line([-0.45 -0.45],ylim,'LineWidth',linewidth,'Color','black','LineStyle',':');
    line([-0.30 -0.30],ylim,'LineWidth',linewidth,'Color','black','LineStyle',':');
    line([-0.15 -0.15],ylim,'LineWidth',linewidth,'Color','black','LineStyle',':');
    line([    0     0],ylim,'LineWidth',linewidth,'Color','black','LineStyle',':');
    set(gcf,'Color','white');
end