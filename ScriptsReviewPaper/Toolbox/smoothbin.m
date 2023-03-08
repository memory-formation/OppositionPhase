function smBIN = smoothbin(ampbin, win)
nbins = length(ampbin);

allvals = [ampbin(nbins-floor(win/2)+1:nbins) ampbin ampbin(1:floor(win/2))];
for bin= 1:nbins
    smBIN(bin) = mean(allvals(bin:bin+(win-1)));
end
end