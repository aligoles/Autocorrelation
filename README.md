# Single-Voxel Autocorrelation
This repository consists of the codes related to the following paper:

Bouffard NR, Golestani A, Brunec IK, Bellana B, Park JY, Barense MD, Moscovitch M. 
Single voxel autocorrelation uncovers gradients of temporal dynamics in the hippocampus and entorhinal cortex during rest and navigation. 
Cereb Cortex. 2023 Mar 10;33(6):3265-3283. doi: 10.1093/cercor/bhac480. PMID: 36573396; PMCID: PMC10388386.

https://academic.oup.com/cercor/article/33/6/3265/6959310


## Abstract

During navigation, information at multiple scales needs to be integrated. Single-unit recordings in rodents suggest that gradients of temporal dynamics in the hippocampus and entorhinal cortex support this integration. 
In humans, gradients of representation are observed, such that granularity of information represented increases along the long axis of the hippocampus. 
The neural underpinnings of this gradient in humans, however, are still unknown. 
Current research is limited by coarse fMRI analysis techniques that obscure the activity of individual voxels, preventing investigation of how moment-to-moment changes in brain signal are organized and how they are related to behavior. 
Here, we measured the signal stability of single voxels over time to uncover previously unappreciated gradients of temporal dynamics in the hippocampus and entorhinal cortex. 
Using our novel, single voxel autocorrelation technique, we show a medial-lateral hippocampal gradient, as well as a continuous autocorrelation gradient along the anterolateral-posteromedial entorhinal extent. 
Importantly, we show that autocorrelation in the anterior-medial hippocampus was modulated by navigational difficulty, providing
the first evidence that changes in signal stability in single voxels are relevant for behavior. 
This work opens the door for future research on how temporal gradients within these structures support the integration of information for goal-directed behavior.

![Fig1](https://user-images.githubusercontent.com/6662964/189467830-e33a9137-1de6-45a0-90ff-f39aefda8242.png)

## Software implementation

All source code used to generate the results in the paper are in the repository. The codes are run inside MATLAB. You need a working MATLAB software to run the codes. Moreover, several functions (MRIread, MRIwrite, etc.) are used to read and write MRI images, which can be dounloaded from the following link:
https://github.com/fieldtrip/fieldtrip/tree/master/external/freesurfer  

Below is the detail discription of each file.  
#### AC_generator.m:
This functuion calculate voxel-wise autocorrelation (AC) of fMRI data within a mask and generate a 4D map of AC values and a 3D map of clusters.  
####  Jaccard.m: 
This function gets two 3D maps and calculate the Jaccard coefficient that shows the overlap between the two input maps.  
#### community_louvain.m: 
This function is used to perform clustering. This code is borrowed from Mika Rubinov, U Cambridge 2015-2016. https://github.com/neuro-data-science/neuro_data_science/blob/master/matlab/basset_connectivity/community_louvain.m
#### Individual_Runner.m: 
This code is a template to create AC value and cluster maps from the fMRI data for each individual dataset. This code should be modified based on the location of the data. 
#### GroupAverage_Runner.m:
This code is a template to create a group average AC values and cluster, using individual AC value maps generated with Individual_runner.m. This code should be modified based on the location of the data. Please note that the individual AC value maps should be in a common space (e.g. MNI).  
#### Jaccard_runner.m: 
This code is a template that calculates Jaccard coefficient of the ROIs. It calculates Jaccard coefficient between the group-average clusters and individual clusters, as well as Jaccard coefficent between different subjects. This code should be modified based on the location of the data. Please notb that all the clusters should be in a common space (e.g. MNI).  

## License

You can freely use and modify the code, without warranty, so long as you provide attribution to the authors and reference the manuscript.
The authors reserve the rights to the article content, which is publication in the Cerebral Cortex.
