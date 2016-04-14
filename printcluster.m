function printcluster(conname,modality,varargin)

loadpaths

param = finputcheck(varargin, { ...
    'dir', 'string', {'pos','neg','both'}, 'both'; ...
    'alpha', 'real', [], 0.05; ...
    'statwin', 'real', [], [-200 700]; ...
    });

%sampling period of data
samptime = 5;

if isnumeric(modality)
    %source
    modality_or_val = sprintf('%d',modality);
elseif ischar(modality)
    %sensor
    modality_or_val = modality;
end
    
%% load contrast and identify clusters

load(sprintf('%s%s_stat_%s.mat',filepath,conname,modality_or_val),'stat');

if ischar(modality) && ~isempty(stat.clusters)
    timeline = stat.statwin(1):samptime:stat.statwin(2);
    statwinidx = intersect(find(timeline>=stat.statwin(1)),find(timeline<=stat.statwin(2)));
    
    %select clusters within specified time window
    selectclusters = timeline(statwinidx(1) + cell2mat({stat.clusters.tstart}) - 1) >= param.statwin(1) & ...
        timeline(statwinidx(1) + cell2mat({stat.clusters.tstop}) - 1) <= param.statwin(2);
    stat.clusters = stat.clusters(selectclusters);
    
%     %select clusters in specified direction (positive/negative clusters)
%     selectclusters = false(1,length(stat.clusters));
%     for c = 1:length(stat.clusters)
%         plottimeidx = statwinidx(1) + stat.clusters(c).tmax -1;
%         clustpeak = diffcond(:,:,plottimeidx);
%         clustsum = sum(clustpeak(stat.mask(:,:,stat.clusters(c).tmax) == stat.clusters(c).clusternum));
%         if (strcmp(param.dir,'both') || strcmp(param.dir,'pos')) && clustsum > 0
%             selectclusters(c) = true;
%         elseif (strcmp(param.dir,'both') || strcmp(param.dir,'neg')) && clustsum < 0
%             selectclusters(c) = true;
%         end
%     end
%     stat.clusters = stat.clusters(selectclusters);
end

if ~isempty(stat.clusters)
    [~,maxclustidx] = max(cell2mat({stat.clusters.clustersize}));
else
    warning('No clusters found!');
    maxclustidx = [];
end

if ~isempty(maxclustidx)
    if stat.clusters(maxclustidx).clusterpval < param.alpha
        if stat.clusters(maxclustidx).clusterpval >= 0.00001
            fprintf('Cluster %d: %d-%dms, peak %dms, p = %.5f.\n',...
                stat.clusters(maxclustidx).clusternum,...
                timeline(statwinidx(1) + stat.clusters(maxclustidx).tstart - 1),...
                timeline(statwinidx(1) + stat.clusters(maxclustidx).tstop - 1),...
                timeline(statwinidx(1) + stat.clusters(maxclustidx).tmax - 1),...
                stat.clusters(maxclustidx).clusterpval);
        else
            fprintf('Cluster %d: %d-%dms, peak %dms, p = %.1e.\n',...
                stat.clusters(maxclustidx).clusternum,...
                timeline(statwinidx(1) + stat.clusters(maxclustidx).tstart - 1),...
                timeline(statwinidx(1) + stat.clusters(maxclustidx).tstop - 1),...
                timeline(statwinidx(1) + stat.clusters(maxclustidx).tmax - 1),...
                stat.clusters(maxclustidx).clusterpval);
        end
    else
        warning('No significant clusters found!');
    end
end