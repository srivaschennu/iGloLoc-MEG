function dicomtonifti

loadpaths

loadsubj

mridir = sprintf('%sMRI',filepath);
cur_wd = pwd;

for subjidx = 1:size(subjlist,1)
    subjname = subjlist{subjidx,1};
    subjdir = dir([mridir filesep subjname '*']);
    subjdir = subjdir.name;
    
    fprintf('Converting %s...\n',subjdir);
    
    datedir = dir([mridir filesep subjdir]);
    datedir = datedir(~(strncmp('.',{datedir.name},1)) & logical(cell2mat({datedir.isdir})));
    
    dicomdir = dir([mridir filesep subjdir filesep datedir.name]);
    dicomdir = dicomdir(~(strncmp('.',{dicomdir.name},1)));
    
    dicomfilepath = [mridir filesep subjdir filesep datedir.name filesep dicomdir.name];
    dicomfilelist = dir([dicomfilepath filesep '*.dcm']);
    for f = 1:length(dicomfilelist)
        dicomfilelist(f).name = [dicomfilepath filesep dicomfilelist(f).name];
    end
    
    dicomfilelist = char({dicomfilelist.name}');
    outfile = spm_dicom_convert(spm_dicom_headers(dicomfilelist),'all','flat','nii');
    niifile = [mridir filesep subjname '.nii'];
    fprintf('Saving to %s.\n',niifile);
    movefile(outfile.files{1},niifile);
end