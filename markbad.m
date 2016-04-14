function markbad(subjname,modality)

loadpaths

subjname = lower(subjname);

modalities = {
    'EEG'       500 250
    'MEGMAG'    0.4 0.2
    'MEGPLANAR' 150 75
    'LFP'       500 250
    };

m = find(strcmp(modality,modalities(:,1)));
if isempty(m)
    error('Modality %s unknown!',modality);
end

fullfilepath = sprintf('%s%s.mat',filepath,subjname);
fprintf('\nReading %s.\n',fullfilepath);
D = spm_eeg_load(fullfilepath);

%     %% Artefact detection
%     S = [];
%     S.D = D;
%
%     S.methods(1).fun = 'flat';
%     S.methods(1).channels = 'MEG';
%     S.methods(1).settings.threshold = 0;
%     S.methods(1).settings.seqlength = 4;
%
%     S.methods(1).fun = 'flat';
%     S.methods(1).channels = 'EEG';
%     S.methods(1).settings.threshold = 0;
%     S.methods(1).settings.seqlength = 4;
%
%     S.methods(end+1).fun = 'threshchan';
%     S.methods(end).channels = 'EOG';
%     S.methods(end).settings.threshold = 150e-6;
%
%     S.methods(end+1).fun = 'threshchan';
%     S.methods(end).channels = 'EEG';
%     S.methods(end).settings.threshold = 125e-6;
%
%     S.methods(end+1).fun = 'threshchan';
%     S.methods(end).channels = 'MEG';
%     S.methods(end).settings.threshold = 5e-12;
%
%     S.methods(end+1).fun = 'threshchan';
%     S.methods(end).channels = 'MEGPLANAR';
%     S.methods(end).settings.threshold = 200e-12;
%
%     D = spm_eeg_artefact(S);
%
%     badchan = D.badchannels;
%     fprintf('\n%d/%d (%d%%) channels marked as bad: ',length(badchan),length(D.meegchannels), ...
%         round((length(badchan)/length(D.meegchannels)) * 100));
%     for c = 1:length(badchan)
%         fprintf('%s ',D.chanlabels{badchan(c)});
%     end
%     fprintf('\n');
%
%     fprintf('\n%d/%d (%d%%) trials marked as bad: ',sum(D.reject),length(D.reject), ...
%         round((sum(D.reject)/length(D.reject)) * 100));
%     fprintf('%d ', find(D.reject));
%     fprintf('\n');


%% visually identify bad trials and channels by variance
badchan = [];
badtrls = false(1,D.ntrials);
uiwait(markartifacts2(D,modalities{m,1},modalities{m,2},modalities{m,3}));

thisbadchan = evalin('base','badchan');
if ~isempty(thisbadchan)
    badchan = cat(1,badchan,thisbadchan);
end

thisbadtrials = evalin('base','badtrials');
if sum(thisbadtrials) > 0
    badtrls = badtrls | thisbadtrials;
end

evalin('base','clear badchan badtrials');

%% mark bad channels
if ~isempty(badchan)
    D = badchannels(D,badchan,1);
end
fprintf('\n%s: %d/%d (%d%%) channels marked as bad: ',subjname,length(badchan),D.nchannels, ...
    round((length(badchan)/D.nchannels) * 100));
for c = 1:length(badchan)
    fprintf('%s ',D.chanlabels{badchan(c)});
end
fprintf('\n');

%% mark bad trials
if sum(badtrls) > 0
    D = badtrials(D,find(badtrls),1);
end
fprintf('%s: %d/%d (%d%%) trials marked as bad.\n',subjname,sum(badtrls),length(badtrls), ...
    round((sum(badtrls)/length(badtrls)) * 100));
D.save;

