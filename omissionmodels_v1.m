function model = omissionmodels(convec)

% location priors for dipoles
locs = {
    [-42 -22 7]   'lA1'
    [46 -14 8]    'rA1'
    [-61 -32 8]   'lSTG'
    [59 -25 8]    'rSTG'
    [46 20 8]     'rIFG'
    [-46 20 8]    'lIFG'
    [60 -62 35]   'rP'
    [-59 -56 42]  'lP'
    };

m=1;
model(m) = initmodel(locs(1:6,:),convec);

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
    model(m) = initmodel(locs(1:6,:),convec);
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

for m = 6:10
    model(m) = initmodel(locs(1:6,:),convec);
    model(m) = copymodel(model(5),model(m));
end

%setup inputs
model(5).C(1:2)    = 1; % Inputs into A1
model(6).C(3:4)    = 1; % Inputs into STG
model(7).C(5)      = 1; % Inputs into RIFG
model(8).C(6)      = 1; % Inputs into LIFG
model(9).C(5:6)    = 1; % Inputs into IFG
model(10).C(1:6)   = 1; % Inputs into all nodes

for m = 1:length(model)
    for c = 2:length(model(m).B)
        model(m).B{c} = model(m).B{1};
    end
end

function model = initmodel(locs,convec)

numlocs = size(locs,1);
model.Lpos = cell2mat(locs(:,1))';
model.Sname = locs(:,2)';
model.A{1} = zeros(numlocs,numlocs);             % forward connection
model.A{2} = zeros(numlocs,numlocs);             % backward connection
model.A{3} = zeros(numlocs,numlocs);             % lateral
for c = 1:size(convec,1)
    model.B{c} = zeros(numlocs,numlocs);             % modulations
end
model.C = zeros(numlocs,1);                      % inputs


function tomodel = copymodel(frommodel, tomodel)
fnumlocs = length(frommodel.Sname);

for i = 1:length(tomodel.A)
    tomodel.A{i}(1:fnumlocs,1:fnumlocs) = frommodel.A{i};
end

for i = 1:length(tomodel.B)
    tomodel.B{i}(1:fnumlocs,1:fnumlocs) = frommodel.B{i};
end

tomodel.C(1:fnumlocs) = frommodel.C;

