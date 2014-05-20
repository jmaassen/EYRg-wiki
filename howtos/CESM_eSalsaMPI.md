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

First create a `Macros.abc_eSalsaMPI` file based on the `Macros.abc` file, where `abc` is the 
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


### Create a machine specific "env_machopts" file.

Create a `env_machopts.abc_eSalsaMPI` file based on the `env_machopts.abc` file, where `abc` is the name of 
your machine. In this file, set the MPI location to eSalsa-MPI:

     setenv MPICH_PATH $HOME/eSalsa-MPI
 
### Create a __DUMMY__ "mkbatch" file.

Create a `mkbatch.abc_eSalsaMPI` file based on the `mkbatch.abc` file, where `abc` is the name of 
your machine. In this file, set the correct machine name:

     set mach = abc_eSalsaMPI

__NOTE: This is a dummy mkbatch file!__ Since we will use the eSalsa-MPI version of CESM to run on a 
combination of machines, it is a bit hard to generate the correct submission files. Therefore, for the time 
being we assume that the user will create these files manually. 
	











