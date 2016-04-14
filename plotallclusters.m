%% figure 2
plotcluster({'global','global'},{'ld','ls'},'EEG','statwin',[50 200],'dir','neg','xlabel','on','ylabel','on','clim',[-1.5 1.5],'colorbar','on','legend','on','legendstrings',{'loc. dev.','loc. std.'},'legendlocation','NorthWest');
plotcluster({'global','global'},{'ld','ls'},'EEG','statwin',[150 300],'dir','pos','clim',[-1.5 1.5],'legendstrings',{'loc. dev.','loc. std.'});
plotcluster({'global','global'},{'od','oc'},'EEG','statwin',[50 200],'dir','neg','clim',[-1.5 1.5],'legend','on','legendstrings',{'omi.','ctrl.'},'legendlocation','Best','ylim',[-1.5 1.5]);

plotcluster({'visual','visual'},{'ld','ls'},'EEG','statwin',[50 200],'dir','neg','clim',[-1.5 1.5],'legendstrings',{'loc. dev.','loc. std.'});
plotcluster({'visual','visual'},{'ld','ls'},'EEG','statwin',[150 300],'dir','pos','clim',[-1.5 1.5],'legendstrings',{'loc. dev.','loc. std.'});
plotcluster({'visual','visual'},{'od','oc'},'EEG','statwin',[50 200],'dir','neg','clim',[-1.5 1.5],'legendstrings',{'omi.','ctrl.'},'ylim',[-1.5 1.5]);

%% figure S1
plotcluster({'global','global'},{'ld','ls'},'MEGMAG','statwin',[50 200],'dir','neg','xlabel','on','ylabel','on','clim',[-80 80],'colorbar','on','legendstrings',{'loc. dev.','loc. std.'},'ylim',[-200 200]);
plotcluster({'global','global'},{'ld','ls'},'MEGCOMB','statwin',[50 200],'clim',[-0.5 2],'colorbar','on','ylabel','on','legendstrings',{'loc. dev.','loc. std.'},'ylim',[-0.5 2.5]);

plotcluster({'global','global'},{'od','oc'},'MEGMAG','statwin',[100 200],'clim',[-80 80],'dir','neg','legendstrings',{'omi.','ctrl.'},'ylim',[-200 200]);
plotcluster({'global','global'},{'od','oc'},'MEGCOMB','statwin',[100 200],'clim',[-0.5 2],'legendstrings',{'omi.','ctrl.'},'ylim',[-0.5 2.5]);

plotcluster({'visual','visual'},{'ld','ls'},'MEGMAG','statwin',[50 200],'clim',[-80 80],'dir','neg','legendstrings',{'loc. dev.','loc. std.'});
plotcluster({'visual','visual'},{'ld','ls'},'MEGCOMB','statwin',[50 200],'clim',[-0.5 2],'legendstrings',{'loc. dev.','loc. std.'},'ylim',[-0.5 2.5]);

plotcluster({'visual','visual'},{'od','oc'},'MEGMAG','statwin',[150 200],'clim',[-80 80],'dir','neg','legendstrings',{'omi.','ctrl.'},'ylim',[-200 200]);
plotcluster({'visual','visual'},{'od','oc'},'MEGCOMB','statwin',[150 200],'clim',[-0.5 2],'dir','pos','legendstrings',{'omi.','ctrl.'},'ylim',[-0.5 2.5]);


%% global deviant - global standard
plotcluster({'global','global'},{'gd','gs'},'EEG','statwin',[250 650],'dir','pos','clim',[-1.5 1.5],'colorbar','on','xlabel','on','ylabel','on','legend','on','legendstrings',{'glo. dev.','glo. std.'},'legendlocation','SouthEast');
plotcluster({'global','global'},{'gd','gs'},'MEGMAG','statwin',[300 600],'dir','pos','ylabel','on','legendstrings',{'glo. dev.','glo. std.'},'ylim',[-150 150]);
% plotcluster({'global','global'},{'gd','gs'},'MEGPLANAR','statwin',[300 600],'dir','pos','ylabel','on','legendstrings',{'glo. dev.','glo. std.'},'ylim',[-1 1]);
plotcluster({'global','global'},{'gd','gs'},'MEGCOMB','statwin',[300 600],'ylabel','on','legendstrings',{'glo. dev.','glo. std.'},'ylim',[-0.5 2.5]);

plotcluster({'visual','visual'},{'gd','gs'},'EEG','statwin',[300 600],'dir','pos','legendstrings',{'glo. dev.','glo. std.'});
plotcluster({'visual','visual'},{'gd','gs'},'MEGMAG','statwin',[350 400],'dir','pos','legendstrings',{'glo. dev.','glo. std.'},'ylim',[-150 150]);
% plotcluster({'visual','visual'},{'gd','gs'},'MEGPLANAR','statwin',[500 520],'dir','pos','legendstrings',{'glo. dev.','glo. std.'},'ylim',[-1 1]);
plotcluster({'visual','visual'},{'gd','gs'},'MEGCOMB','statwin',[300 600],'legendstrings',{'glo. dev.','glo. std.'},'ylim',[-0.5 2.5]);

%% omission - omission control global
plotcluster({'global','global'},{'od','oc'},'EEG','statwin',[300 600],'dir','pos','xlabel','on','ylabel','on','legend','on','legendstrings',{'omi.','ctrl.'},'legendlocation','SouthWest','ylim',[-3 3]);
plotcluster({'global','global'},{'od','oc'},'MEGMAG','statwin',[300 600],'dir','pos','ylabel','on','legendstrings',{'omi.','ctrl.'},'ylim',[-60 60]);
% plotcluster({'global','global'},{'od','oc'},'MEGPLANAR','statwin',[300 600],'dir','pos','ylabel','on','legendstrings',{'omi.','ctrl.'},'ylim',[-2 2]);
plotcluster({'global','global'},{'od','oc'},'MEGCOMB','statwin',[300 600],'dir','pos','ylabel','on','legendstrings',{'omi.','ctrl.'},'ylim',[-0.5 2]);

plotcluster({'visual','visual'},{'od','oc'},'EEG','statwin',[400 600],'dir','pos','legendstrings',{'omi.','ctrl.'},'ylim',[-3 3]);
plotcluster({'visual','visual'},{'od','oc'},'MEGMAG','statwin',[400 600],'dir','pos','legendstrings',{'omi.','ctrl.'},'ylim',[-100 100]);
% plotcluster({'visual','visual'},{'od','oc'},'MEGPLANAR','statwin',[300 600],'dir','pos','legendstrings',{'omi.','ctrl.'},'ylim',[-2 2]);
plotcluster({'visual','visual'},{'od','oc'},'MEGCOMB','statwin',[300 600],'dir','pos','legendstrings',{'omi.','ctrl.'},'ylim',[-0.5 2]);

%% sources
plotcoord = plotsource({'global','global'},{'ld','ls'},'xlabel','on','ylabel','on','legend','on','legendstrings',{'loc. dev.','loc. std.'},'legendlocation','SouthEast');
plotsource({'visual','visual'},{'ld','ls'},'plotcoord',plotcoord,'legendstrings',{'loc. dev.','loc. std.'});

plotcoord = plotsource({'global','global'},{'gd','gs'},'ylim',[-0.5 0.8],'legend','on','legendstrings',{'glo. dev.','glo. std.'},'legendlocation','SouthEast');
plotsource({'visual','visual'},{'gd','gs'},'ylim',[-0.5 0.8],'plotcoord',plotcoord,'legendstrings',{'glo. dev.','glo. std.'});

plotcoord = plotsource({'global','global'},{'od','oc'},'plotcoord',[55.534 -51.806 28.942],'xlabel','on','ylabel','on','ylim',[-0.3 0.3],'legend','on','legendstrings',{'omi.','ctrl.'},'legendlocation','NorthEast');
plotsource({'visual','visual'},{'od','oc'},'plotcoord',plotcoord,'ylim',[-0.3 0.3],'legendstrings',{'omi.','ctrl.'});

