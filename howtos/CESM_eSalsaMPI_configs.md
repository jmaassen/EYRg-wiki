\HOWTO: Running CESM with eSalsa-MPI
===================================

We will now give a description of how to run CESM using eSalsa-MPI. 
We assume you already have compiled a CESM using eSalsa-MPI. 
If not, go though this howto first:

<https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM_eSalsaMPI.md>

# Prepare the eSalsa-MPI configuration

Once the experiment has compiled succesfully we need to create the necessary eSalsa-MPI configuration files 
to run it. We assume the 1728 core configuration descibed 
[here](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM_eSalsaMPI.md) is used, and that CESM 
will be split in two jobs:

- 504 cores running the atmosphere, land, sea ice and coupler
- 1224 cores running the ocean.

In addition, we will use 2 gateway nodes of 24 cores each. This give us the configuration shown below:

![cesm-split](https://github.com/jmaassen/EYRg-wiki/blob/master/images/CESM-empi-24gw.png "CESM example split")

### Prepare the eSalsa-MPI server config

We will now prepare an eSalsa server config as descibed [here](). In this config we descibe the setup
of the server and both CESM jobs:

     # Name of this experiment
     EYRg experiment 1

     # Port at which the server should listnen.
     6677

     # Number of cluster used in this experiment
     2

     # Number of gateways used per cluster
     24

     # Number of streams used to connect gateways
     1

     ##########################################
     # Next, we configure each of the CESM jobs.

     # ATM partition
     job-ATM
     504
     12000
     10.200.0.0/16

     # OCN partition
     job-OCN
     1224
     14000
     10.200.0.0/16

The server is configured to listnen on port 6677. The machine that the server is running on should be
accessible to the gateway nodes of both jobs. The jobs are called "job-ATM" and "job-OCN" and are configured
to use 24 gateways (1 node) per job. For "job-ATM" the gateways will use the network interface with address
`10.200.0.0/16` and port range `12000...12023`. For "job-OCN" the gateways will use the network interface
with address `10.200.0.0/16` and port range `14000...14023`.
Next, two configuration files are needed to configure each CESM job:

The configuration for "job-ATM":

     job-ATM 10.200.200.15 6677

The configuration for "job-OCN":

     job-OCN 10.200.200.15 6677

Both configuration files contain only a single line consisting of the name of the job and the location and
port of the server.

### Prepare the submit scripts

Next, we need to create a submit script






 





