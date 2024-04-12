
# Opposition Phase

README for instruction and settings of functions. 

## Path

All paths and addpath were set for the experimenter computer, if 
you need to use the function, change the paths and the addpaths according
to your own machine and relevant paths. 

## Explanation of events: 

Events are determined by their trigger value which is the following: 

- 10 = image 1
- 11 = image 2
- 12 = image 3
- 13 = image 4
- 20 = fixation cross 
- 24 = Offset 
- 50 = Image onset of Recall 

Image offset of recall has 50 as trigger on both day 1 and day 2, 
so precising the day is important

Events are in the header of each script as for example;
`event = \[10 11 12 13\]` This would be images 1, 2, 3 and 4. 

## Config

All functions exhibit a structure of configuration with a config struct. 
Usually the required settings are specified in the function header or help 
sometimes config take the value of another variable for a subfunction
config will work for all functions and scripts. 

## Organisation of scripts and functions

All scripts have the settings parameters at the top of the script. Only 
changing those is sufficient to modify most paramenters of the scripts 
and subfunctions and subscripts that are associated. 
Core scripts are in the folders corresponding to each figure, and their 
dependencies and subfunctions necessary to the script are in the Toolbox 
folder. 

## Accuracy

To change accuracy simlpy change the variable 'acc' or 'byacc' in most
scripts. to have all `trials = 'all'`
to have only accurate `trials = 'acc'`
to have only non accurate `trials = 'nacc'`

## Supplementary Material

All figures of the supplementary material can be obtained with the scripts 
provided for Figures 1, 2 and 3 just by changing the settings provided 
in the header of each script. 
For example to obtain TFA of images 1 and 2 simply change 
`event = [10 11]`.
