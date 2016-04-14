function checkconvergence(joblist)

loadpaths

for j = joblist
    [~,result1] = system(sprintf('cat %s/Jobs/Job%d/Task1.diary.txt | grep convergence | wc -l',filepath,j));
    [~,result2] = system(sprintf('cat %s/Jobs/Job%d/Task1.diary.txt | grep minutes | wc -l',filepath,j));
    if result1 == result2
        fprintf('Job %d: %d of %d models converged.\n',j,str2double(result1),str2double(result2));
    else
        warning('Job %d: %d of %d models converged.',j,str2double(result1),str2double(result2));
    end
end
