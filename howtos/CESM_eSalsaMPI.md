HOWTO: compiling CESM 1.04 with eSalsa-MPI
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

 













