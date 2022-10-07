function [] = MOVI_help()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Assumptions and explanation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1.0
% The assumption is that if the two conditions have average opposite angles
% the resultant A-B will be non uniform and unimodal and will therefore be
% detected by the measure of MVL that calculates the absolute mean vector
% length and tests for uniform directionality driven by amplitude, or in
% this case, by a difference in amplitude and angle of preference. When MVL
% is applied to Binned data it calculates the mean vector for each bin.
% Then the complex vectors are averaged and if the data has a unimodal
% direction the resultant average vector will have both angle and
% magnitude. The absolute value of this resultant vector will give the
% modulation index, on in this case the Mean Vector Opposition Index.
% If two binned distributions are high but with the same angle, the
% subsraction of those two distributions will give a flat distribution that
% averaged in vectorial space will give a very short vector close to 0, and
% a very low MI. On the other hand opposed distributions with opposed angles
% will give a binned distribution of amplitudes that is higher than either
% of the original distributions A and B, and in vectorial space this will
% translate in a mean vector that will be longer because of an increased
% difference in amplitude at that angle. The resultant MI or MOIV will be
% stronger. In this case we are only interested in unimodal distributions:
% Distributions that will only be stronger at 1 angle. MVL of Canolty et
% al. 2006 permits this, while the Modulation index (MI)of Tort et al. 2009
% using the KL distance fomula,  mainly tests of non uniform distributions 
% that can be multimodal (have several angles of preference). 
% In the case of the measure of an opposition index we prefer to test for
% resultant differences in angles and amplitude that go only in one 
% direction, showing inequivocably opposition and not solely non-uniformity 
% of resultant distribution A-B.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Difference between MOIV and PACOI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% -1 Computation: PACOI is computed for each patient using trials and a
% permutation test across conditions to test opposition of angles of unit
% normalized vectors. MOIV averages over trials and tests the difference of
% angles and amplitude between two averaged distributions. The shuflfing
% and surrogates are created within condition to avoid different number of 
% trials being a limiting factor and then the averaged distributions are 
% tested against each other for a number of times equal to the desired 
% number of surrogates. (explained in Coding steps and logic)
%
% -2 PACOI uses unit normalized vectors, meaning that it tests mainly for a
% difference in angles even though the amplitude difference might not be
% significant enough to justify a PAC in either condition. PACOI and PAC
% measure are intrinsically disconnected while PAC and MOIV can overlap due
% to the usage of amplitude. 
%
% -3 PACOI gives an output of p-values for each patient and the 2d level
% analysis must be done by combining p-values with the combine_pvalues
% function that limits the exploration across patients, not necessarily
% concentrating on common directionality of distributions but rather on
% individual changes. MOIV does a cluster based permutation test at the
% second level against a surrogate distribution of MI(A-B) that tests for
% consistent and stable increase of MI(A-B) over the frequency map. 
%
% -4 PACOI uses single trials to test for opposition or difference in
% angles which is incredible for tasks that have two clear and opposite
% conditions but can introduce a bias when working with sequential items
% where two assumption and theories can drive the result. For example in
% the context of our memory task we are testing for the Hasselmo model that
% states difference of preferred phase of theta during encoding and
% retrieval, but also phase precession mechanisms that shows difference in
% phase preference for different items along a sequence during encoding. in
% the case of testing all items at encoding for accurate vs non accurate
% conditions we are introducing a bias of phase precession if the measure
% is done trial by trial, because if there is a phase coding mechanism it
% might drive the results of the opposition of phase more than accuracy and
% therefore significant results in PACOI in that case might be significant
% but irrelevant scienteifically because their variance can be explained by
% more than 1 variable and it is complicated ot distinguish between them. 
% MOIV offers an alternative where it will test only for common mechanisms
% across all 4 images, making it useful and relevant for sequencies and
% multi-item comparisons. In our case averaging over trials and therefore
% images will show a binned distributions that is specific to encoding only
% without relying on single image or single trial variability. 
% This encoding distribution can therefore be tested against a Recall
% distribution with the certainty that the mean opposition index vector 
% (MOIV) will show opposition between common encoding mechanisms and common
% recall mechanisms without the confounding variables of image order or in
% this assumption of phase coding mechanisms. 
% 
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Explanation of the script and step by step pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%in this framework we are doing the following steps to ensure rigorous
%phase opposition measurement:
% 1- Filtering amplitude and phase with a window of 0.3*low frequency
% centered on the low frequency and of 0.7*high frequency centered on high
% frequency as per the paper of Aru et al. 2015 to avoid bias towards lower
% frequencies and ensuring that delta(HF) > 2*low-freq at any moment. 
%
% 2- Binning data in 18 bins in order to mean amplitude per phase bin for
% each condition (A and B) and average over trials to have a mean angle
% and increase the statistical solidity of the results. 
%
% 3 - Normalization of Binned data between 0 and 1 to avoid number of
% trials being a limitant factor where lower trials might explain a higher
% mean amplitude per phase bin. 
%
% 4 - Substract the mean normalized binned data B from the mean normalized
% binned data A and have a resultant binned distribution of A-B that shows
% the mean difference. 
%
% 5- Normalize MeanAmp(A-B) between 0 and 1 to avoid having negative values
% in binned data
%
% 6- Calculate MVL as per Canolty et al. 2006 of the binned distribution
% A-B and obtain an Mean Vector of the Opposition. it will be the Mean
% Vector Opposition Index. 
%
% 7- Create surrogate trials with the following steps that are to be
% repeated a number of times equal to config.n_iter (number of surrogates
% desired):
%       a- Shuffle trials in amplitude for each condition before binning
%       the data and pairing it with phase. inter trial shuffling was done
%       following the advice on surrogate ditributions of Tort et al. 2010.
%       b- Obtain two shuffled binned distributions for each condition,
%       normalize each of them between 0 and 1 to avoid number of trials
%       adding noise or increasing amplitude for either condition 
%       c- Substract the two normalized shuffled distributions obtaining a
%       surrogate A-B distribution. 
%       d- Normalize the Surr(A-B) distribution between 0 and 1 to avoid
%       having negative values, for MVL measure needs only positive values.
%       e- Calculate the MOIV of each surrogate for each pair of
%       frequencies obtaining a value of MOIV for each pair of frequencies
%       and number of surrogate. 
%       f- Average the surrogate comodulogram over number of iterations to
%       obtain a surrogate distribution for each participant that will 
%       correspond to the null hypothesis against which we are going to
%       test our experimental condition MOIV(A-B).
%
% 8- After the surrogate distribution of MOIV has been obtained for each
% participant we run a cluster based permutation test of MOIV(A-B) against
% MOIV_surr(A-B) to test the experimental condition against the surrogate
% distribution of MOIV. 
% 9- We extract significant clusters that may arise and look at the
% distributions of both A and B for the significant pairs of frequencies 
% of the cluster or clusters. 
% 10- All subsequent data shown and figures already have a significant MOIV
% score showing significant opposition between two conditions. 
% 11- Figures: 
%           
%
%           a - Figure for each indivisual patient: 
%               1a) The comodulogram is the resultant of the difference of 
%               the MOIV score of each patient minus the surrogate 
%               comodulogram of each patient. A contour was added to show
%               the common significant cluster of opposition.
%               The std of all patients was not used here. 
%               2a) The binned distributions were extracted for the common
%               significant cluster of all patients and the distribution is
%               the individual distribution of binned amplitude per phase
%               for each patient and for both conditions. For facilitating
%               view all distributions were realigned to phase 0 for the
%               highest amplitude of condition 1 and condition 2 was
%               realigned as a function of condition 1 for each patient.
%               (See realign2phases in the OppositionFigures.m script)
%
%           b - Figure for 2d level analysis. 
%               1b) The comodulogram was the result of the normalized mean
%               of MOIV(A-B) for our experimental conditions by the
%               MOIV_surr(A-B) inthe following way: 
%               MOIV_norm = (mean(MOIV)- mean(MOIV_surr))/std(MOIV_surr)
%               where MOIV is the comodulogram of MOIV values for out
%               experimental conditions and for each patient and pair of
%               frequencies organized like this: 
%               MOIV(subj, high_freqs, low_freqs). 
%               The mean of the MOIV is over patients for both MOIV and
%               MOIV_surr. 
%               MOIV_surr is the average of MOIV surrogate values over
%               surrogate iterations for each patients and the mean in the
%               normalization is over patients. MOIV_surr is organized in
%               the same way as MOIV. 
%               2b) The average amplitude per phase bin figure is created
%               by binning phase and amp data and zscoring it for each 
%               experimental condition within the significant cluster of 
%               opposition found with the cluster based permutation test.
%               The distributions of each patients are averaged over pairs
%               of frequencies and then over patients to obtain an average
%               Ampplitude by phase bins distributions with error bars
%               corresponding to the standard error calculated with the
%               standard deviation of the mean amplitude per phase bin of 
%               all patients over the square root of the number of patients.
%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
%                               References used 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - MVL calculation:
% Canolty RT, Edwards E, Dalal SS, et al. High gamma power is phase-locked
% to theta oscillations in human neocortex. Science. 
% 2006;313(5793):1626-1628. doi:10.1126/science.1128115
%
%
% - PACOI: 
% Aversive memory formation in humans is determined by an 
% amygdala-hippocampus phase code
% Manuela Costa, Diego Lozano-Soldevilla, Antonio Gil-Nagel, Rafael Toledano, 
% Carina Oehrn, Lukas Kunz, Mar Yebra, Costantino Mendez-Bertolo, Lennart 
% Stieglitz, Johannes Sarnthein, Nikolai Axmacher, Stephan Moratti, 
% Bryan A. Strange
%
%
% - Filtering and PAC settings
% Tort, Adriano B L et al. “Measuring phase-amplitude coupling between 
% neuronal oscillations of different frequencies.” Journal of 
% neurophysiology vol. 104,2 (2010): 1195-210. doi:10.1152/jn.00106.2010
%
% Aru J, Aru J, Priesemann V, Wibral M, Lana L, Pipa G, Singer W, 
% Vicente R. Untangling cross-frequency coupling in neuroscience. 
% Curr Opin Neurobiol. 2015 Apr;31:51-61. doi: 10.1016/j.conb.2014.08.002. 
% Epub 2014 Sep 15. PMID: 25212583.
%
% Tort AB, Komorowski RW, Manns JR, Kopell NJ, Eichenbaum H. Theta-gamma 
% coupling increases during the learning of item-context associations. 
% Proc Natl Acad Sci U S A. 2009 Dec 8;106(49):20942-7. doi: 10.1073/pnas.
% 0911331106. Epub 2009 Nov 23. PMID: 19934062; PMCID: PMC2791641.
%
end