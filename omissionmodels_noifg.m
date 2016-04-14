function [model,family] = omissionmodels_noifg(convec)

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

m=1;
model(m) = initmodel(locs,convec);

% add intrinsic A1 connections
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself

% Add STG
model(m).A{1}(3,1) = 1; % LA1 forward connection on LSTG
model(m).A{1}(4,2) = 1; % RA1 forward connection on RSTG
model(m).A{2}(1,3) = 1; % LA1 backward connection on LSTG
model(m).A{2}(2,4) = 1; % RA1 backward connection on RSTG

model(m).B{1}(3,1) = 1; % LA1 modulation on LSTG forward
model(m).B{1}(4,2) = 1; % RA1 modulation on LSTG foward
model(m).B{1}(1,3) = 1; % LA1 modulation on LSTG Backward
model(m).B{1}(2,4) = 1; % RA1 modulation on RSTG backward

for m = 2:3
    model(m) = initmodel(locs,convec);
    model(m) = copymodel(model(1),model(m));
end

%models 1 has no inputs - null model
%setup inputs for the rest
model(2).C(1:2)    = 1; % Inputs into A1
model(3).C(3:4)    = 1; % Inputs into STG

% Add LIPC and RIPC to model 1
m=4;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(1),model(m));

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

for m = 5:7
    model(m) = initmodel(locs,convec);
    model(m) = copymodel(model(4),model(m));
end

%setup inputs
model(4).C(1:2)    = 1; % Inputs into A1
model(5).C(3:4)    = 1; % Inputs into STG
model(6).C(7:8)   = 1; % Inputs into IPC

model(7).C([1:4,7:8])   = 1; % Inputs into all

%copy over B matrix for each contrast
for m = 1:length(model)
    for c = 2:length(model(m).B)
        model(m).B{c} = model(m).B{1};
    end
end

%optionally specify model families
%optionally specify model families
family(1).family_name = 't';
family(1).family_models = 1:3;
family(1).family_order = 1;
family(2).family_name = 't-p';
family(2).family_models = 4:6;
family(2).family_order = 3;