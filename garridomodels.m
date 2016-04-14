function [model,family] = garridomodels(convec)


% location priors for dipoles
locs = {
    [-42 -22 7]   'lA1'
    [46 -14 8]    'rA1'
    [-61 -32 8]   'lSTG'
    [59 -25 8]    'rSTG'
    [46 20 8]     'rIFG'
    [-46 20 8]    'lIFG'
    [-49 -38 38]  'lIPC'    
    [57 -38 42]   'rIPC'
    };

% Bilateral inputs into A1
m=1;
model(m) = initmodel(locs,convec);
model(m).C(1:2) = 1;

% and intrinsic connections
m = 2;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(1),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself



% Add STG
m = 3;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(1),model(m));
model(m).A{1}(3,1) = 1; % LA1 forward connection on LSTG
model(m).A{1}(4,2) = 1; % RA1 forward connection on RSTG
model(m).A{2}(1,3) = 1; % LA1 backward connection on LSTG
model(m).A{2}(2,4) = 1; % RA1 backward connection on RSTG

model(m).B{1}(3,1) = 1; % LA1 modulation on LSTG forward
model(m).B{1}(4,2) = 1; % RA1 modulation on LSTG foward
model(m).B{1}(1,3) = 1; % LA1 modulation on LSTG Backward
model(m).B{1}(2,4) = 1; % RA1 modulation on RSTG backward

% and intrinsic connections
m = 4;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(3),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself



% Add RIFG
m = 5;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(3),model(m));
model(m).A{1}(5,4) = 1; % RSTG forward connection on RIFG
model(m).A{2}(4,5) = 1; % RIFG backward connection on RSTG
model(m).B{1}(5,4) = 1; % RSTG forward modulation on RIFG
model(m).B{1}(4,5) = 1; % RIFG backward modulation on RSTG

% and intrinsic connections
m = 6;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(5),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself



% Add LIFG
m = 7;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(5),model(m));
model(m).A{1}(6,3) = 1; % LSTG forward connection on LIFG
model(m).A{2}(3,6) = 1; % LIFG backward connection on LSTG
model(m).B{1}(6,3) = 1; % LSTG forward modulation on LIFG
model(m).B{1}(3,6) = 1; % LIFG backward modulation on LSTG

% Add A1 with intrinsic connections
m = 8;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(7),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself


% Add LIPC and RIPC to model 3
m = 9;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(3),model(m));

model(m).A{1}(8,4) = 1; % RSTG forward connection on RIPC
model(m).A{2}(4,8) = 1; % RIPC backward connection on RSTG
model(m).B{1}(8,4) = 1; % RSTG forward modulation on RIPC
model(m).B{1}(4,8) = 1; % RIPC backward modulation on RSTG

model(m).A{1}(7,3) = 1; % LSTG forward connection on LIPC
model(m).A{2}(3,7) = 1; % LIPC backward connection on LSTG
model(m).B{1}(7,3) = 1; % LSTG forward modulation on LIPC
model(m).B{1}(3,7) = 1; % LIPC backward modulation on LSTG

model(m).A{3}(8,7) = 1; % LIPC lateral connection on RIPC
model(m).A{3}(7,8) = 1; % RIPC lateral connection on LIPC
model(m).B{1}(8,7) = 1; % LIPC lateral modulation on RIPC
model(m).B{1}(7,8) = 1; % RIPC lateral modulation on LIPC


% Add A1 with intrinsic connections
m = 10;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(9),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself


% Add LIPC and RIPC to model 5
m = 11;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(5),model(m));

model(m).A{1}(8,5) = 1; % RIFG forward connection on RIPC
model(m).A{2}(5,8) = 1; % RIPC backward connection on RIFG
model(m).B{1}(8,5) = 1; % RIFG forward modulation on RIPC
model(m).B{1}(5,8) = 1; % RIPC backward modulation on RIFG

model(m).A{3}(8,7) = 1; % LIPC lateral connection on RIPC
model(m).A{3}(7,8) = 1; % RIPC lateral connection on LIPC
model(m).B{1}(8,7) = 1; % LIPC lateral modulation on RIPC
model(m).B{1}(7,8) = 1; % RIPC lateral modulation on LIPC


% Add A1 with intrinsic connections
m = 12;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(11),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself

% Add LIFG
m = 13;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(11),model(m));
model(m).A{1}(6,3) = 1; % LSTG forward connection on LIFG
model(m).A{2}(3,6) = 1; % LIFG backward connection on LSTG
model(m).B{1}(6,3) = 1; % LSTG forward modulation on LIFG
model(m).B{1}(3,6) = 1; % LIFG backward modulation on LSTG

model(m).A{1}(7,6) = 1; % LIFG forward connection on LIPC
model(m).A{2}(6,7) = 1; % LIPC backward connection on LIFG
model(m).B{1}(7,6) = 1; % LIFG forward modulation on LIPC
model(m).B{1}(6,7) = 1; % LIPC backward modulation on LIFG

% Add A1 with intrinsic connections
m = 14;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(13),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself


%copy over B matrix for each contrast
for m = 1:length(model)
    for c = 2:length(model(m).B)
        model(m).B{c} = model(m).B{1};
    end
end

%optionally specify model families
family(1).family_name = 't';
family(1).family_models = 1:4;
family(1).family_order = 1;

family(2).family_name = 't-f';
family(2).family_models = 5:8;
family(2).family_order = 2;

family(3).family_name = 't-p';
family(3).family_models = 9:10;
family(3).family_order = 3;

family(4).family_name = 't-f-p';
family(4).family_models = 11:14;
family(4).family_order = 4;
