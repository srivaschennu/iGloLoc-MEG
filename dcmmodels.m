function [model,family] = dcmmodels(convec)


% location priors for dipoles
locs = {
    [-42 -22 7]   'lA1'
    [46 -14 8]    'rA1'
    [-61 -32 8]   'lSTG'
    [59 -25 8]    'rSTG'
    [46 20 8]     'rIFG'
    [-46 20 8]    'lIFG'
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

m = 9;
model(m) = initmodel(locs,convec);
% Add STG
model(m).A{1}(3,1) = 1; % LA1 forward connection on LSTG
model(m).A{1}(4,2) = 1; % RA1 forward connection on RSTG
model(m).A{2}(1,3) = 1; % LA1 backward connection on LSTG
model(m).A{2}(2,4) = 1; % RA1 backward connection on RSTG

model(m).B{1}(3,1) = 1; % LA1 modulation on LSTG forward
model(m).B{1}(4,2) = 1; % RA1 modulation on LSTG foward
model(m).B{1}(1,3) = 1; % LA1 modulation on LSTG Backward
model(m).B{1}(2,4) = 1; % RA1 modulation on RSTG backward
model(9).C(3:4) = 1;

% and intrinsic connections
m = 10;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(9),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself

model(10).C(3:4) = 1;

m = 11;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(5),model(m));
model(11).C(:) = 0;
model(11).C(3:4) = 1;

% and intrinsic connections
m = 12;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(11),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself
model(12).C(3:4) = 1;

m = 13;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(5),model(m));
model(13).C(:) = 0;
model(13).C(5) = 1;

% and intrinsic connections
m = 14;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(13),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself
model(14).C(5) = 1;

m = 15;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(7),model(m));
model(15).C(:) = 0;
model(15).C(3:4) = 1;

% and intrinsic connections
m = 16;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(15),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself
model(16).C(3:4) = 1;

m = 17;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(7),model(m));
model(17).C(:) = 0;
model(17).C(5:6) = 1;

% and intrinsic connections
m = 18;
model(m) = initmodel(locs,convec);
model(m) = copymodel(model(17),model(m));
model(m).B{1}(1,1)=1; %A1 modulation on itself
model(m).B{1}(2,2)=1; %A1 modulation on itself
model(18).C(5:6) = 1;


%copy over B matrix for each contrast
for m = 1:length(model)
    for c = 2:length(model(m).B)
        model(m).B{c} = model(m).B{1};
    end
end

%optionally specify model families
family(1).family_name = 't';
family(1).family_models = [1:4 9 10];
family(1).family_order = 1;

family(2).family_name = 't-f';
family(2).family_models = [5:8 11:18];
family(2).family_order = 2;