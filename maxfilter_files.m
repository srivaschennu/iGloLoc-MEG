
% Maxfilter 2.2 Matlab script for Tristan/Srivas/Valdes's Experiment (R Henson May 2012)
% Note matlab needs to be started on a 64bit machine (eg "spm eeg 8 highmemory")

dat_wd = '/imaging/vn01/predictive_MMN/Raw_data/';
new_wd = '/imaging/vn01/predictive_MMN/Processed_S_D/';  % Change!!!


cbu_codes = {'meg12_0222'};  % CBU subject code for each subject
exp_codes = {'Sub01'};       % Your experimental code for each subject (corresponding to above)

%----------------------

basestr = ' -ctc /neuro/databases/ctc/ct_sparse.fif -cal /neuro/databases/sss/sss_cal.dat';
basestr = [basestr ' -linefreq 50 -hpisubt amp'];
basestr = [basestr ' -force'];  % care!!!
%basestr = [basestr ' -ds 4'];
%maxfstr = '!/neuro/bin/util/x86_64-pc-linux-gnu/maxfilter-2.2 '
maxfstr = '!/imaging/local/linux/bin/elekta/maxfilter '

addpath /imaging/local/meg_misc
addpath /neuro/meg_pd_1.2/

for s = 1:length(cbu_codes)
    
    sub_wd = fullfile(new_wd,exp_codes{s});
    try eval(sprintf('!mkdir %s',sub_wd)); end
    
    raw_wd    = dir(fullfile(dat_wd,cbu_codes{s},'12*'));  
    raw_files = dir(fullfile(dat_wd,cbu_codes{s},raw_wd.name,'*raw*'));
    
    midrun = ceil(length(raw_files)/2); % middle run for trans "across runs within subject" below

    cd(sub_wd)
    movfile = 'trans_move.txt';
    eval(sprintf('!touch %s',movfile));
  
    for run = 1:length(raw_files)

        rawfile = fullfile(dat_wd,cbu_codes{s},raw_wd.name,raw_files(run).name);        
        
        if run == 1  % fit sphere doesn't change with run!
            incEEG = 1;
            try delete(fullfile(sub_wd,'fittmp.txt')); delete(fullfile(fwd,sprintf('run_%02d_hpi.txt',run))); end
            [orig(s,:),rad,fit] = meg_fit_sphere(rawfile,sub_wd,sprintf('ses_%02d_hpi.txt',run),incEEG);
            delete(fullfile(sub_wd,'fittmp.txt')); 
        end
        origstr = sprintf(' -origin %d %d %d -frame head',orig(s,1),orig(s,2),orig(s,3));
        
%% 1. Bad channel detection              
        outfile = fullfile(sub_wd,sprintf('run_%02d_bad',run));
        filestr = sprintf(' -f %s -o %s.fif',rawfile,outfile);
        finstr = [maxfstr filestr origstr basestr sprintf(' -autobad 2000 -v | tee %s.log',outfile)]       % 2000s should be 33mins - ie all data!
        eval(finstr);
        delete(sprintf('%s.fif',outfile));
        
        % Pull out bad channels from logfile:
        badfile = sprintf('%s.txt',outfile);
%        badstr  = sprintf('!cat %s.log | sed -n ''/Static/p'' | cut -f 5- -d '' '' > %s',outfile,badfile);
%         badstr  = sprintf('!cat %s.log | sed -n ''/Detected/p'' | cut -f 5- -d '' '' > %s',outfile,badfile);
        badstr  = sprintf('!cat %s.log | sed -n -e ''/Detected/p'' -e ''/Static/p'' | cut -f 5- -d '' '' > %s',outfile,badfile); %VN updated
        eval(badstr);

        tmp=dlmread(badfile,' ');
        tmp=reshape(tmp,1,prod(size(tmp)));
        tmp=tmp(tmp>0); % Omit zeros (padded by dlmread):

        % Get frequencies (number of buffers in which chan was bad):
        [frq,allbad] = hist(tmp,unique(tmp));

        % Mark bad based on threshold (currently ~10% of buffers (assuming 500 buffers)):
        badchans = allbad(frq>0.1*500);
        if isempty(badchans)
            badstr = '';
        else
            badstr = sprintf(' -bad %s',num2str(badchans))
        end
        
%% 2. 1-step SSS+trans
%         outfile = fullfile(sub_wd,sprintf('run_%02d_sss',run));
%         filestr = sprintf(' -f %s -o %s.fif',rawfile,outfile);
%              
%         tSSSstr = ' -st 10 -corr 0.98';
%         posfile = fullfile(sub_wd,sprintf('run_%02d_headpos.txt',run));
%         compstr = sprintf(' -movecomp inter -hpistep 10 -hp %s',posfile);
%       
%         transtr = sprintf(' -trans default -origin %d %d %d -frame head',orig(s,:)+[0 -13 6]);
% %        transtr = sprintf(' -trans %s -frame head',fullfile(dat_wd,cbu_codes{s},raw_wd.name,raw_files(ceil(length(raw_files)/2)).name));
% %        transtr = '';

%% 2-step SSS then trans
%
%% 2. tSSS and trans across runs within subject

        outfile = fullfile(sub_wd,sprintf('run_%02d_tsss',run));       
        tSSSstr = ' -st 10 -corr 0.98';
        posfile = fullfile(sub_wd,sprintf('run_%02d_headpos.txt',run));
        compstr = sprintf(' -movecomp inter -hpistep 10 -hp %s',posfile);
      
        if run == midrun % Middle run - no need to trans anywhere
            transtr = '';
        else
            transtr = sprintf(' -trans %s',fullfile(dat_wd,cbu_codes{s},raw_wd.name,raw_files(midrun).name));
        end
        
        filestr = sprintf(' -f %s -o %s.fif',rawfile,outfile);
        finstr = [maxfstr filestr basestr badstr tSSSstr compstr origstr transtr sprintf(' -v | tee %s.log',outfile)]       
        eval(finstr);
        
        if run == midrun % Middle run - no need to trans anywhere
            eval(sprintf('!echo ''0 mm'' >> %s',movfile));
        else
            eval(sprintf('!cat %s.log | sed -n ''/Position change/p'' | cut -f 7- -d '' '' >> %s',outfile,movfile));
        end
        
%% 3. trans to default helmet position (for across-subject)

        infile = outfile;
        outfile = fullfile(sub_wd,sprintf('run_%02d_tsss_transdef',run));       
      
        transtr = sprintf(' -trans default -origin %d %d %d -frame head -force',orig(s,:)+[0 -13 6]);
        
        filestr = sprintf(' -f %s.fif -o %s.fif',infile,outfile);
        finstr = [maxfstr filestr transtr sprintf(' -v | tee %s.log',outfile)]       
        eval(finstr);
        
        if run == length(raw_files)
           eval(sprintf('!echo ''Transd...'' >> %s',movfile));
           eval(sprintf('!cat %s.log | sed -n ''/Position change/p'' | cut -f 7- -d '' '' >> %s',outfile,movfile));       
        end
        
% Danny's approach to trans default first, then tSSS
%         transtr = sprintf(' -trans %s -origin %d %d %d -frame head',tmpfile,orig(s,:));
%         outfile = fullfile(sub_wd,sprintf('run_%02d_sss',run));       
%         tSSSstr = ' -st 10 -corr 0.98';
%         posfile = fullfile(sub_wd,sprintf('run_%02d_headpos.txt',run));
%         compstr = sprintf(' -movecomp inter -hpistep 10 -hp %s',posfile);
%       
%         transtr = sprintf(' -trans default -origin %d %d %d -frame head',orig(s,:)+[0 -13 6]);
% 
%         tmpfile = fullfile(sub_wd,sprintf('run_%02d_tmp.fif',run));
%         filestr = sprintf(' -f %s -o %s',rawfile,tmpfile);
%         finstr = [maxfstr filestr basestr tSSSstr compstr transtr sprintf(' -v | tee %s.log',outfile)]       
%         eval(finstr);
%         
%         transtr = sprintf(' -trans %s -origin %d %d %d -frame head',tmpfile,orig(s,:));
%         
%         filestr = sprintf(' -f %s -o %s.fif',rawfile,outfile);
%         finstr = [maxfstr filestr basestr tSSSstr compstr transtr sprintf(' -v | tee %s.log',outfile)]       
%         eval(finstr);
%        
%         delete(tmpfile); 
    end
end


