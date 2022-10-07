%% Info 
%compares 1 value to a distribution. If studying percentages use chi square
%test 
%use as [tval, degfreedom, pval] = CrawfordHowell(value, distribution)

function [tval,degfre,pval] = CrawfordHowell(expcond,control)
    niter = length(control);
    tval = (expcond - mean(control))./(std(control).*sqrt((niter+1)./niter));
    degfre = niter-1;
    pval = 2*(1-tcdf(abs(tval),degfre));
end