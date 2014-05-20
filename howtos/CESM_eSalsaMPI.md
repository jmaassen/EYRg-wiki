HOWTO: Compiling CESM 1.04 with eSalsa-MPI
==========================================

We will now give a brief description on how to compile CESM with eSalsa-MPI. 
We assume you already have compiled and run a "regular" CESM and have compiled
eSalsa-MPI and run some test. If not, go thought these howtos first:

- Short HOWTO: [Installing CESM](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM.md)

- Short HOWTO: [Installing eSalsa-MPI](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/eSalsaMPI.md)

### Create an eSalsa-MPI machine configuration for CESM.

Assuming the CESM is installed in `$HOME/cesm1_0_4` and eSalsa-MPI is installed in `$HOME/eSalsa-MPI`, 
you need to create a machine description in the directory:

     $HOME/cesm1_0_4/scripts/ccsm_utils/Machines

### Create a Macros file

First create a `$HOME/cesm1_0_4/scripts/ccsm_utils/Machines/Macros.abc_eyrg` file based on the `Macros.abc` file, where `abc` is the 
name of your machine.

In this file, set the MPI library to eSalsa-MPI:

     MPI_LIB_NAME := empi-frontend

And make sure to include all eSalsa MPI libs when linking:

     LDFLAGS := -lempi-backend -lempi-logging -L/opt/intel/impi/4.1.0.024/lib64 -lmpi

Note that the `-L/opt/intel/impi/4.1.0.024/lib64 -lmpi` at the end of LDFLAGS includes the 'real' 
MPI library (in this case intel-mpi). Please set this to the correct path for you machine.

Set the compiles to empi_icc and empi_ifort:

     ifeq ($(USE_MPISERIAL),TRUE)
        FC := $HOME/eSalsa-MPI/scripts/empifort
        CC := $HOME/eSalsa-MPI/scripts/empicc
     else
        FC := $HOME/eSalsa-MPI/scripts/empifort
        CC := $HOME/eSalsa-MPI/scripts/empicc
     endif

and make sure that the compiler configuration is correctly passed to the MCT and PIO configure scripts:

     ifeq ($(MODEL),mct)
       #add arguments for mct configure here
       CONFIG_ARGS += CC="$(CC)" FC="$(FC)" F90="$(FC)" INCLUDEPATH="-I$(INC_MPI)"   
     endif

     ifeq ($(MODEL),pio)
       ifneq ($(strip $(PIO_CONFIG_OPTS)),)
         CONFIG_ARGS += $(PIO_CONFIG_OPTS)
       endif
       CONFIG_ARGS += CC="$(CC)" F90="$(FC)" FC="$(FC)" MPICC="$(CC)" MPIF90="$(FC)" NETCDF_PATH="$(NETCDF_PATH)" MPI_INC="-I$(INC_MPI)" FFLAGS="$(FFLAGS)" CFLAGS="$(CFLAGS)"
     endif

Here is the 
[Macros.cartesius_gcc_eyrg](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/Macros.cartesius_gcc_eyrg) 
file we use on Cartesius.

### Create a machine specific "env_machopts" file.

Create a `$HOME/cesm1_0_4/scripts/ccsm_utils/Machines/env_machopts.abc_eyrg` file based on the `env_machopts.abc` file, where `abc` is the name of 
your machine. In this file, set the MPI location to eSalsa-MPI:

     setenv MPICH_PATH $HOME/eSalsa-MPI
 
Here is the 
[env_machopts.cartesius_gcc_eyrg](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/env_machopts.cartesius_gcc_eyrg)
file we use on Cartesius.

### Create a __DUMMY__ "mkbatch" file.

Create a `$HOME/cesm1_0_4/scripts/ccsm_utils/Machines/mkbatch.abc_eSalsaMPI` file based on the `mkbatch.abc` file, where `abc` is the name of 
your machine. In this file, set the correct machine name:

     set mach = abc_eyrg

__NOTE: This is a dummy mkbatch file!__ Since we will use the eSalsa-MPI version of CESM to run on a 
combination of machines, it is a bit hard to generate the correct submission files. Therefore, for the time 
being we assume that the user will create these files manually using the generated script as a starting point.
	
Here is the 
[mkbatch.cartesius_gcc_eyrg](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/mkbatch.cartesius_gcc_eyrg)
file we use on Cartesius.

### Add the machine description.

Add a `abc_eyrg` machine description to the 
`$HOME/cesm1_0_4/scripts/ccsm_utils/Machines/config_machines.xml`. Here's an example:

     <machine MACH="cartesius_gcc_eygr"
              DESC="SurfSara Bull, os is GNU/Linux, 24 pes/node, batch system is SLURM - EYRG setup" 
              EXEROOT="/home/$CCSMUSER/experiments/$CASE/build"
              OBJROOT="$EXEROOT"
              LIBROOT="$EXEROOT/lib"
              INCROOT="$EXEROOT/lib/include" 
              DIN_LOC_ROOT_CSMDATA="/projects/esalsa/inputdata"
              DIN_LOC_ROOT_CLMQIAN="/cgd/tss/atm_forcing.datm7.Qian.T62.c080727"   
              DOUT_S_ROOT="/home/$CCSMUSER/archive/$CASE"
              DOUT_L_HTAR="FALSE"
              DOUT_L_MSROOT="csm/$CASE"
              CCSM_BASELINE="/fis/cgd/cseg/csm/ccsm_baselines"
              CCSM_CPRNC="/fis/cgd/cseg/csm/tools/cprnc/cprnc"
              ESMF_LIBDIR="/ptmp/svasquez/esmf_install/ESMF_5_2_0-O/lib/"
              OS="Linux" 
              BATCHQUERY="squeue"
              BATCHSUBMIT="sbatch &lt;" 
              GMAKE_J="24" 
              MAX_TASKS_PER_NODE="24"
              MPISERIAL_SUPPORT="FALSE"
              PES_PER_NODE="24" />

In this machine description, the experiment dirs will be created in `$HOME/CESM/experiments` 
(see EXEROOT), the output archive is located in `$HOME/CESM/archive` (see DOUT_S_ROOT), and the input
is located in `/projects/esalsa/inputdata` (see DIN_LOC_ROOT_CSMDATA). 

The EXEROOT directory will be used to create temporary output files such as logs and checkpoint. 
This may be a lot of data! Once a CESM run has completed succesfully, al these logs and data will
be copied to the output archive specified in DOUT_S_ROOT.

The variables DIN_LOC_ROOT_CLMQIAN, CCSM_BASELINE, CCSM_CPRNC and ESMF_LIBDIR are NOT set correctly,
but it seems that these are not used in our experiments.

Here is the 
[config_machines.xml](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/config_machines.xml) we use 
in our experiments. This file already contains the machine description for "cartesius_gcc_eyrg".

# Create an experiment

__Next, we will create and compile an experiment using CESM with eSalsa-MPI.__ Note that the experiment setup 
is almost identical to a "normal" CESM run (as described 
[here](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM.md)), only the name of the test and 
machine configuration are different.

### Create the appropriate experiment directories

Make sure all experiment directories that CESM needs exist:

     mkdir -p $HOME/CESM/experiments
     mkdir -p $HOME/CESM/archive

### Create an experiment

To setup a CESM experiment you must use the "create_newcase" script:

     cd $HOME/CESM/experiments
     $HOME/cesm1_0_4/scripts/create_newcase -case test_eyrg -mach cartesius_gcc_eyrg -compset B -res f05_t12

This creates a "test_eyrg" directory in `$HOME/CESM/experiments` that contains a CESM instance configuration 
for a simulation using compset "B" (all active models) for resolution "f05_t12" (0.5 degree atmosphere
and land and 0.1 degree ocean and sea ice) using the configuration for "cartesius_gcc_eyrg".

This configuration is only __PARTLY__ configured.

To complete the configuration of the experiment do the following:
   
     cd $HOME/CESM/experiments/test_eyrg

- Edit the "env_mach_pes.xml" to set the core configuration for this experiment. 
- Edit the "env_conv.xml" file to set the correct run type and start date.  
- Edit the "env_run.xml" file to set the desired experiment length.

We have also prepared these test configurations for Cartesius:

- [env_mach_pes.xml](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/cartesius-1m/env_mach_pes.xml)
- [env_conv.xml](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/cartesius-1m/env_conf.xml)
- [env_run.xml](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/cartesius-1m/env_run.xml)

This configuration used the following setup:

- CESM is run on 1728 cores (72 nodes x 24 cores).
- Atmosphere runs on 504 cores (21 nodes) shared with coupler (504), land (24) and sea ice (480).
- Ocean runs concurrently on an additional 1224 cores (51 nodes)
- 4 coupling per model day between ocean and others. 
- The simulation runs for 31 model days. 

### Build the experiment

Next, build the experiment like this:

     cd $HOME/CESM/experiments/test_eyrg
     ./configure -case
     ./test_eyrg.cartesius_gcc_eygr.build 

The `configure -case` generates the necessary scripts and configuration files for this 
particular experiment with this particular configuration. In general any changes to one of 
the configuration files will require CESM to be recompiled.

# Prepare the eSalsa-MPI configuration

Once the experiment has compiled succesfully we need to create the necessary eSalsa-MPI configuration files 
to run it. We assume the 1728 core configuration descibed above is used, and that CESM will be split in two jobs:

- 504 cores running the atmosphere, land, sea ice and coupler
- 1224 cores running the ocean. 

In addition, we will use 2 gateway nodes of 24 cores each.

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

Both configuratio files contain only a single line consisting of the name of the job and the location and 
port of the server.

### Prepare the submit scripts

Next, we need to create a submit script 



 



















