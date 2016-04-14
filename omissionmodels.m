function [model,family] = omissionmodels(convec)

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

% Add RIFG
model(m).A{1}(5,4) = 1; % RSTG forward connection on RIFG
model(m).A{2}(4,5) = 1; % RIFG backward connection on RSTG

model(m).B{1}(5,4) = 1; % RSTG forward modulation on RIFG
model(m).B{1}(4,5) = 1; % RIFG backward modulation on RSTG


for m = 2:5
    model(m) = initmodel(locs,convec);
    model(m) = copymodel(model(1),model(m));
end

%models 1 has no inputs - null model
%setup inputs for the rest
model(2).C(1:2)    = 1; % Inputs into A1
model(3).C(3:4)    = 1; % Inputs into STG
model(4).C(5)      = 1; % Inputs into RIFG

% Add LIFG to model 5
m=5;
model(m).A{1}(6,3) = 1; % LSTG forward connection on LIFG
model(m).A{2}(3,6) = 1; % LIFG backward connection on LSTG
model(m).B{1}(6,3) = 1; % LSTG forward modulation on LIFG
model(m).B{1}(3,6) = 1; % LIFG backward modulation on LSTG

for m = 6:7
    model(m) = initmodel(locs,convec);
    model(m) = copymodel(model(5),model(m));
end

%setup inputs
model(5).C(1:2)    = 1; % Inputs into A1
model(6).C(3:4)    = 1; % Inputs into STG
model(7).C(5:6)    = 1; % Inputs into IFG


% Add LIPC and RIPC to model 1
m=8;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(1),model(m));

model(m).A{1}(8,5) = 1; % RIFG forward connection on RIPC
model(m).A{2}(5,8) = 1; % RIPC backward connection on RIFG
model(m).B{1}(8,5) = 1; % RIFG forward modulation on RIPC
model(m).B{1}(5,8) = 1; % RIPC backward modulation on RIFG

model(m).A{3}(8,7) = 1; % LIPC lateral connection on RIPC
model(m).A{3}(7,8) = 1; % RIPC lateral connection on LIPC
model(m).B{1}(8,7) = 1; % LIPC lateral modulation on RIPC
model(m).B{1}(7,8) = 1; % RIPC lateral modulation on LIPC

for m = 9:12
    model(m) = initmodel(locs,convec);
    model(m) = copymodel(model(8),model(m));
end

%setup inputs
model(8).C(1:2)    = 1; % Inputs into A1
model(9).C(3:4)    = 1; % Inputs into STG
model(10).C(5)     = 1; % Inputs into IFG
model(11).C(7:8)   = 1; % Inputs into IPC


% Add LIFG to model 8
m=12;
model(m).A{1}(6,3) = 1; % LSTG forward connection on LIFG
model(m).A{2}(3,6) = 1; % LIFG backward connection on LSTG
model(m).B{1}(6,3) = 1; % LSTG forward modulation on LIFG
model(m).B{1}(3,6) = 1; % LIFG backward modulation on LSTG

model(m).A{1}(7,6) = 1; % LIFG forward connection on LIPC
model(m).A{2}(6,7) = 1; % LIPC backward connection on LIFG
model(m).B{1}(7,6) = 1; % LIFG forward modulation on LIPC
model(m).B{1}(6,7) = 1; % LIPC backward modulation on LIFG

for m = 13:16
    model(m) = initmodel(locs,convec);
    model(m) = copymodel(model(12),model(m));
end

%setup inputs
model(12).C(1:2)   = 1; % Inputs into A1
model(13).C(3:4)   = 1; % Inputs into STG
model(14).C(5:6)   = 1; % Inputs into IFG
model(15).C(7:8)   = 1; % Inputs into IPC

model(16).C(1:8)   = 1; % Inputs into all

%copy over B matrix for each contrast
for m = 1:length(model)
    for c = 2:length(model(m).B)
        model(m).B{c} = model(m).B{1};
    end
end

%optionally specify model families
family(1).family_name = 't-f';
family(1).family_models = 1:7;
family(1).family_order = 2;
family(2).family_name = 't-f-p';
family(2).family_models = 8:15;
family(2).family_order = 4;
