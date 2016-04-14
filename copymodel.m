function tomodel = copymodel(frommodel, tomodel)
fnumlocs = length(frommodel.Sname);

for i = 1:length(tomodel.A)
    tomodel.A{i}(1:fnumlocs,1:fnumlocs) = frommodel.A{i};
end

for i = 1:length(tomodel.B)
    tomodel.B{i}(1:fnumlocs,1:fnumlocs) = frommodel.B{i};
end

tomodel.C(1:fnumlocs) = frommodel.C;