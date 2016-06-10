function runcon(modality)

spm('defaults','EEG');

loadpaths
loadcont

cur_wd = pwd;

if isnumeric(modality) %source
    modality_or_val = sprintf('%d',modality);
elseif ischar(modality) %sensor
    modality_or_val = modality;
end

load(sprintf('%sstats/%s/SPM.mat',filepath,modality_or_val));

%% specify parameters for running contrast
SPM.Im = 'none';

if isnumeric(modality) %source
    %multiple comparisons correction
    SPM.thresDesc = 'none';
    
    %cluster p-value threshold
    SPM.u = 0.001;
    %units
    SPM.units = {'mm' 'mm' 'mm'};
    
    %cluster extent threshold
    SPM.k = 10;

elseif ischar(modality) %sensor
    SPM.thresDesc = 'FWE';
    SPM.u = 0.05;
    SPM.units = {'mm' 'mm' 'ms'};

    %cluster extent threshold
    SPM.k = 10;
    
    stat.statwin = condlists{2};
end



for conidx = 2:length(SPM.xCon)
    fprintf('Running contrast %s.\n',SPM.xCon(conidx).name);
    SPM.Ic = conidx;
    assignin('base','SPM',SPM);

    %% run contrast
    evalin('base','[hReg,xSPM,SPM] = spm_results_ui(''Setup'',SPM)');
    xSPM = evalin('base','xSPM');
    hReg = evalin('base','hReg');
    stat.table = spm_list('List',xSPM,hReg);
    p_fwe = sort(cell2mat(stat.table.dat(:,3)));
    
    set(gcf,'PaperPositionMode','auto');
    print(gcf,sprintf('%s/figures/%s_%s.tif',cur_wd,SPM.xCon(conidx).name,modality_or_val),'-dtiff');
    
    %% identify clusters - taken from spm_results_ui:mysavespm
    Z       = xSPM.Z;
    XYZ       = xSPM.XYZ;
    Z       = spm_clusters(XYZ);
    num     = max(Z);
    [~, ni] = sort(histc(Z,1:num), 2, 'descend');
    n       = size(ni);
    n(ni)   = 1:num;
    Z       = n(Z);
    
    Vstat = spm_write_filtered(xSPM.Z, XYZ, xSPM.DIM, xSPM.M,...
        sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',xSPM.STAT,xSPM.u,xSPM.k),...
        sprintf('%s%s_stat_%s.nii',filepath,SPM.xCon(conidx).name,modality_or_val));
    stat.stat = spm_read_vols(Vstat);
    
    Vmask = spm_write_filtered(Z, XYZ, xSPM.DIM, xSPM.M,...
        sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',xSPM.STAT,xSPM.u,xSPM.k),...
        sprintf('%s%s_mask_%s.nii',filepath,SPM.xCon(conidx).name,modality_or_val));
    stat.mask = spm_read_vols(Vmask);
    
    clusters = unique(stat.mask);
    clusters = nonzeros(clusters);
    
    stat.clusters = [];
    for c = 1:length(clusters)
        clusterstat = stat.stat;
        clusterstat(stat.mask ~= clusters(c)) = 0;
        clustmax = squeeze(max(max(clusterstat,[],1),[],2));
        stat.clusters(c).clusternum = clusters(c);
        stat.clusters(c).clustersize = length(nonzeros(clusterstat(:)));
        stat.clusters(c).clusterpval = p_fwe(c);
        stat.clusters(c).tstart = find(clustmax,1,'first');
        stat.clusters(c).tstop = find(clustmax,1,'last');
        [maxval,stat.clusters(c).tmax] = max(clustmax);
        [stat.clusters(c).pmax(1), stat.clusters(c).pmax(2)] = find(clusterstat(:,:,stat.clusters(c).tmax) == maxval,1);        
    end

    contfile = sprintf('%s%s_stat_%s.mat',filepath,SPM.xCon(conidx).name,modality_or_val);
    fprintf('Saving contrast to %s.\n',contfile);
    save(contfile,'xSPM','stat');
end

cd(cur_wd);
