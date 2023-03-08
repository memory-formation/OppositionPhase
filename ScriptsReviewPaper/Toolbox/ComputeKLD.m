function sym_DKL = ComputeKLD(bamp1, bamp2)
% this function was based on Nielsen et al. (2019), a paper that discusses
% the Kullback-Leibler Divergence and its asymetry. 
%For this reason I computer the KL distance in a symmetrical way following
%the paper. The paper states that KDL is not upper bounded and in cases 
%of high differences or of very low values it can raise numeric issues in 
%actual applications. 
%normally KL distance is computed as KL= sum(A.*(log(A/B))) but 
%KL(A|B) := KL(B|A) so we computed symmetrical KL computed as 
%(KL(A|B)+KL(B|A))/2
%there is the option in this function to compute the Jensen Shannon
%divergence that also takes into account the mean of the two distributions
%but in the case of normalized neurophysiological data the results between
%DKL and JSD do not diverge at all. 
%The main difference is that JD considers the mean of the two distributions
%as M=(A+B)/2 and sums the distance between A and M and then the distance
%between B and M which makes the following formula 
%JSD = (KL(A|M)+KL(B|M))/2
%in the case of looking for an opposition index it is better to look at the
%symmetrical KL distance instead of the Kullback Lieble Divergence alone


vec1 = bamp1./sum(bamp1);
vec2 = bamp2./sum(bamp2);


%one directional
KL1 = sum(vec1.* (log(vec1)-log(vec2)));
% KL2 = sum(vec2.* (log(vec2)-log(vec1)));
% sym_DKL = (KL1+KL2)/2;

sym_DKL = KL1;

end