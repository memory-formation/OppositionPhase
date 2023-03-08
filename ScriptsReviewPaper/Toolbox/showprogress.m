function []=showprogress(currval, totval)

perc = currval/totval*100;
if currval == 1
    fprintf(1, 'Progress is at \f      ')
end
fprintf(1,'\b\b\b\b\b\b\f%03.1f%% ',perc)
if currval == totval
    fprintf('completed! \n')
end
end