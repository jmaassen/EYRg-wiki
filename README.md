EYRg-wiki
=========

This repository contains all information about the 
_Enlighten Your Reseach global_ (EYRg) part of the _eSalsa_ project.

What is the eSalsa Project?
---------------------------

The eSalsa Project is a cooperation between the 
[Netherlands eScience Center (NLeSC)](http://www.esciencecenter.nl/), 
the [Institute for Marine and Atmospheric Research (IMAU)](http://imau.nl/) 
at Utrecht University, and the [Vrije Universiteit Amsterdam (VU)](http://www.cs.vu.nl). 

The goal of the eSalsa project is to determine to what extent regional sea 
level in the eastern North Atlantic will be affected by changes in ocean 
circulation over the next decades.

During this project, we will use the [Parallel Ocean Program (POP)](http://climate.lanl.gov/Models/POP/)
and the [Community Earth System Model (CESM)](http://www2.cesm.ucar.edu/) to run climate simulations.

An additional goal of the eSalsa projects is to improve and extend POP with 
support for distributed computing techniques and accelerators (GPUs).

For more information on the eSalsa project see:
 
<http://www.esciencecenter.nl/projects/project-portfolio/climate-research>


What is Enlighten Your Reseach global ?
---------------------------------------

EYRg is a competition organized by five National Research and Education Networks (NRENS), 
ESnet, Funet, Internet2, Janet and SURFnet. The goal of EYRg is to promote the use of 
state-of-the-art networking resources in scientific research. Our proposal 
_"An Advanced Distributed Computing Approach to High-Resolution Climate Modeling"_ is one 
of the winner of this competition.

More information about EYRg can be found at:

<https://www.enlightenyourresearch.net>


What are we planning to do?
---------------------------

Our goal in EYRg, is to run a high-resolution climate simulation on a _combination_ of supercomputers. For 
this we will use CESM, a multi-model/multi-kernel simulation consisting of 5 components: atmosphere, ocean, 
land, ice and coupler, as shown in the figure below. The coupler is the component that is responsible for the 
necessary data conversion between the models.

![cesm-split](images/cesm.png "CESM submodels")

In its current form, the CESM is run on a single supercomputer, typically on ten thousand cores 
or more, although some experiments use up to 200,000 cores. When running a simulation, CESM internally 
divides the available cores over the 5 different models. It is up to the user of CESM to the assign cores to 
each model. Cores may be assigned to a single model, or shared by multiple models.

The amount of processing time required per model depends both on the resolution and the complexity of each 
model. For typical configurations, the ocean model requires by far the most processing time, followed by 
atmosphere and ice. Land only requires a small amount of processing due to its low complexity.

The coupling frequency is the number of times data is exchanged between models per simulated day. For typical 
configurations, data is exchanged between land, ice and atmosphere models every 30 simulated minutes, 
resulting in 48 couplings per simulated day. The ocean model only needs to exchange data with the other 
models one to four times every simulated day.

Due to data dependencies between the atmosphere model and the land and ice models, these models cannot be run 
concurrently. The resulting workflow for CESM is shown below. This workflow illustrates a single simulated 
day (left to right) for all cores (bottom to top).

![cesm-workflow](images/cesm-workflow.png "CESM workflow")

During the EYRg experiments, our goal is to increase the resolution of simulations from the current 
state-of-the-art 0.1 degree (10 km) ocean+sea ices and 0.5 degree (50 km) atmosphere+land to a currently 
unfeasible 0.02 degree ocean+sea ice and 0.5 degree atmosphere+land. This will require at least 25x more 
processing time for the ocean model, although more pessimistic estimates go up to an increase of 100x or even 
more.

When running climate simulations at such extreme resolutions, traditional supercomputers often do not have 
enough processing power available for the necessary computations. Fortunately, in CESM, the amount of 
communication between submodels is limited (at least compared to the amount of communication within each
submodel). This allows us to distibuted the models over multiple locations. Taking coupling frequencies 
and data dependencies into account, we can easily distribute the models as follows:

![cesm-distribution](images/cesm-distribution.png "CESM distribution")

Since the ocean model is relatively loosely coupled to the other models, it can be run on a separate 
supercomputer, provided the communication channel between the supercomputers is fast enough for the 
data exchanges that are required each model day. The black numbers between the models are an estimate of 
the amount of data that needs to be exchanged between models during a _single_ model coupling when using 
0.1/0.5 degree resolutions. The red numbers are an estimate for the amount of data exchanged when using 
the 0.02/0.5 degree resolution.






Additional information, HOWTOs, example, ...
-------------------------------------------

[Our EYRg proposal](https://github.com/jmaassen/EYRg-wiki/blob/master/documents/EYRG_Dijkstra_Final.pdf?raw=true)

[Initial network topology](https://github.com/jmaassen/EYRg-wiki/blob/master/documents/Network\ topology\ Dijkstra\ project\ EYR\ Global_v1.pdf?raw=true)

[Initial planning](https://github.com/jmaassen/EYRg-wiki/blob/master/documents/Planning.pdf)

[Howto install CESM](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM.md)

[Howto install eSalsa-MPI](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/eSalsaMPI.md)

[Howto use CESM with eSalsa-MPI](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM_eSalsaMPI.md)

[Results](https://github.com/jmaassen/EYRg-wiki/blob/master/results/results.md)
















