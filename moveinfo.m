function moveinfo(subjidx)


loadpaths
loadsubj

subjname = subjlist{subjidx,1};
sub_wd = fullfile(srcpath,subjname);
if ~exist(sub_wd,'dir')
    error('Could not access source directory.');
end

runidx = 1;
for sessidx = 1:size(subjlist{subjidx,2},1)
    sesstype = subjlist{subjidx,2}{sessidx,1};
    runlist = subjlist{subjidx,2}{sessidx,2};

    for run = runlist
        headposfile = fullfile(sub_wd,sprintf('run_%02d_headpos.txt',run));
        if ~exist(headposfile,'file')
            warning('Unable to open %s.',headposfile);
            continue;
        end
        fprintf('%s: processing run_%02d_headpos.txt\n',subjname,run);
        headposdata = readheadpos(headposfile);
        headpos(runidx,1:6) = mean(headposdata(:,2:7),1);
        runidx = runidx+1;
        
        tssslogfile = fullfile(sub_wd,sprintf('run_%02d_tsss.log',run));
        if ~exist(headposfile,'file')
            warning('Unable to open %s.',tssslogfile);
            continue;
        end
        fprintf('%s: processing run_%02d_tsss.log\n',subjname,run);
        check_movecomp(tssslogfile);
        figname = sprintf('%s_run%02d_movecomp',lower(subjname),run);
        set(gcf,'Name',figname);
        export_fig(gcf,['figures/' figname '.jpg']);
        close(gcf);
    end
end

transmovefile = fullfile(sub_wd,'trans_move.txt');
if ~exist(transmovefile,'file')
    warning('Unable to open %s.',transmovefile);
end

transmovedata = readtransmove(transmovefile,size(headpos,1));
headpos = cat(2,headpos,transmovedata);
dlmwrite(sprintf('%smoveinfo.txt',filepath),headpos,'-append','delimiter','\t','roffset',1,'precision','%4.4f');

function headposdata = readheadpos(filename, startRow, endRow)
%IMPORTFILE1 Import numeric data from a text file as a matrix.
%   RUN01HEADPOS = IMPORTFILE1(FILENAME) Reads data from text file FILENAME
%   for the default selection.
%
%   RUN01HEADPOS = IMPORTFILE1(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   run01headpos = importfile1('run_01_headpos.txt', 2, 75);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2014/04/20 23:09:16

%% Initialize variables.
delimiter = ' ';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
headposdata = [dataArray{1:end-1}];


function transmove = readtransmove(filename, numruns)
%IMPORTFILE1 Import numeric data from a text file as a matrix.
%   TRANSMOVE = IMPORTFILE1(FILENAME) Reads data from text file FILENAME
%   for the default selection.
%
%   TRANSMOVE = IMPORTFILE1(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   transmove = importfile1('trans_move.txt', 1, 8);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2014/04/20 23:16:32

%% Initialize variables.
delimiter = ' ';
startRow = 1;
endRow = numruns;

%% Format string for each line of text:
%   column1: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);s
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    dataArray{1} = [dataArray{1};dataArrayBlock{1}];
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
transmove = [dataArray{1:end-1}];
