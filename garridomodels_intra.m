function model = garridomodels_intra(convec)


% location priors for dipoles
locs = {
    [-42 -22 7]   'lA1'
%     [46 -14 8]    'rA1'
    [-61 -32 8]   'lSTG'
%     [59 -25 8]    'rSTG'
%     [46 20 8]     'rIFG'
    [-46 20 8]    'lIFG'
%     [60 -62 35]   'rP'
%     [-59 -56 42]  'lP'
    };

% Bilateral inputs into A1
m=1;
model(m) = initmodel(locs(1:3,:),convec);
model(m).C(1) = 1;

% and intrinsic connections
m = 2;
model(m) = initmodel(locs(1:3,:),convec);
model(m) = copymodel(model(1),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself

% Add STG
m = 3;
model(m) = initmodel(locs(1:3,:),convec);
model(m) = copymodel(model(1),model(m));
model(m).A{1}(2,1) = 1; % LA1 forward connection on LSTG
model(m).A{2}(1,2) = 1; % LA1 backward connection on LSTG

model(m).B{1}(2,1) = 1; % LA1 modulation on LSTG forward
model(m).B{1}(1,2) = 1; % LA1 modulation on LSTG Backward

% and intrinsic connections
m = 4;
model(m) = initmodel(locs(1:3,:),convec);
model(m) = copymodel(model(3),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself

% Add LIFG
m = 5;
model(m) = initmodel(locs(1:3,:),convec);
model(m) = copymodel(model(3),model(m));
model(m).A{1}(3,2) = 1; % LSTG forward connection on LIFG
model(m).A{2}(2,3) = 1; % LIFG backward connection on LSTG

model(m).B{1}(3,2) = 1; % LSTG forward modulation on LIFG
model(m).B{1}(2,3) = 1; % LIFG backward modulation on LSTG

% Add A1 with intrinsic connections
m = 6;
model(m) = initmodel(locs(1:3,:),convec);
model(m) = copymodel(model(5),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself

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

