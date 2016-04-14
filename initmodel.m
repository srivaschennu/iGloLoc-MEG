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
model.C = zeros(numlocs,1);                      % input