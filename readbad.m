function readbad(subjname)

subjname = lower(subjname);

loadpaths

%% load and check data
D = spm_eeg_load([filepath subjname '.mat']);
baddata = load([filepath subjname '_bad.mat']);

if baddata.numchan ~= D.nchannels
    error('Number of channels do not match!');
end

if baddata.numtrials ~= D.ntrials
    error('Number of trials do not match!');
end

%% copy over bad channels
fprintf('\n%s:\n%d/%d (%d%%) channels read as bad: ',subjname,length(baddata.badchan),D.nchannels, ...
    round((length(baddata.badchan)/D.nchannels) * 100));
for c = 1:length(baddata.badchan)
    fprintf('%s ',baddata.badchan{c});
end
fprintf('\n');

baddata.badchan = find(ismember(D.chanlabels,baddata.badchan));
if ~isempty(baddata.badchan)
    D = badchannels(D,baddata.badchan,1);
else
    fprintf('No channels marked as bad.\n');
end

%% copy over bad trials
fprintf('%d/%d (%d%%) trials read as bad.\n',length(baddata.badtrials),D.ntrials,...
    round((length(baddata.badtrials)/D.ntrials) * 100));

if ~isempty(baddata.badtrials)
    D = badtrials(D,baddata.badtrials,1);
else
    fprintf('No trials marked as bad.\n');
end

D.save;
