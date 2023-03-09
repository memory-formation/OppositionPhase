function elec = elec_find(elecraw, elecname)

idx = strfind(elecname, '-');

elecint{1} = elecname(1:idx-1);
elecint{2} = elecname(idx+1:end);

idx(1) = find(strcmp(elecraw.label, elecint{1}));
idx(2) = find(strcmp(elecraw.label, elecint{2}));

elec.unit = elecraw.unit;
elec.coordsys = elecraw.coordsys;
elec.label = elecraw.label(idx);
elec.elecpos = elecraw.elecpos(idx, :, :, :);
elec.chanpos = elecraw.chanpos(idx, :, :, :);
elec.tra = elecraw.tra(idx, idx);
elec.cfg = elecraw.cfg;
end