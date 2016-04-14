plotdcmfit('global_ld-global_ls',[50 150],'EEG',6,'dir','neg','legend','on','legendstrings',{'loc. dev.','loc. std.'},'legendlocation','NorthWest','xlabel','on','ylabel','on','clim',[-0.02 0.02],'colorbar','on','ylim',[-0.05 0.05]);
plotdcmfit('global_ld-global_ls',[150 250],'EEG',6,'dir','pos','legendstrings',{'loc. dev.','loc. std.'},'clim',[-0.02 0.02],'ylim',[-0.05 0.05]);

plotdcmfit('visual_ld-visual_ls',[50 150],'EEG',6,'dir','neg','legendstrings',{'loc. dev.','loc. std.'},'clim',[-0.02 0.02],'ylim',[-0.05 0.05]);
plotdcmfit('visual_ld-visual_ls',[150 250],'EEG',6,'dir','pos','legendstrings',{'loc. dev.','loc. std.'},'clim',[-0.02 0.02],'ylim',[-0.05 0.05]);

plotdcmfit('global_od-global_oc',[100 200],'EEG',18,'dir','neg','legend','on','legendstrings',{'omi.','ctrl.'},'legendlocation','NorthWest','clim',[-0.02 0.02],'ylim',[-0.03 0.03]);
plotdcmfit('visual_od-visual_oc',[100 200],'EEG',18,'dir','neg','legendstrings',{'omi.','ctrl.'},'plotchan','EEG048','clim',[-0.02 0.02],'ylim',[-0.03 0.03]);

% 
% plotdcmfit('global_ld-global_ls',[50 150],'EEG',6,'plotchan','EEG015','dir','neg','legend','on','legendstrings',{'loc. dev.','loc. std.'},'legendlocation','SouthEast','xlabel','on','ylabel','on');
% plotdcmfit('global_ld-global_ls',[150 250],'EEG',6,'plotchan','EEG034','dir','pos','legendstrings',{'loc. dev.','loc. std.'});
% 
% plotdcmfit('visual_ld-visual_ls',[50 150],'EEG',6,'plotchan','EEG021','dir','neg','legendstrings',{'loc. dev.','loc. std.'});
% plotdcmfit('visual_ld-visual_ls',[150 250],'EEG',6,'plotchan','EEG023','dir','pos','legendstrings',{'loc. dev.','loc. std.'});
% 
% plotdcmfit('global_od-global_oc',[170 175],'EEG',18,'plotchan','EEG037','dir','neg','legend','on','legendstrings',{'omi.','ctrl.'},'legendlocation','NorthWest');
% plotdcmfit('visual_od-visual_oc',[170 175],'EEG',18,'plotchan','EEG037','dir','neg','legendstrings',{'omi.','ctrl.'});
