HOWTO: installing CESM 1.04
============================

In our EYRg experiments we will use CESM version 1.04. Although this is not the latest version, we also use 
it in other projects, and therefore we have configuration files and results available. 

We will now give a _very short_ description of how to install CESM on Cartesius or Stampede. For a more detailed 
description on installing CESM have a look at the official documentation:

<http://www.cesm.ucar.edu/models/cesm1.0/cesm>

Note that this page describes how to perform a __standard__ installation, __without__ support for wide area 
communication You will need to do this __before__ adding support for wide area communication (which can be 
found [here](https://github.com/jmaassen/EYRg-wiki/blob/master/howtos/CESM_eSalsaMPI.md)).

### Retrieve CESM from SVN:

First retrieve CESM from SVN at ucar: 

     svn co --username <user> --password <password> https://svn-ccsm-release.cgd.ucar.edu/model_versions/cesm1_0_4

To get access to SVN you will need a username and password for which you need to register here:

<http://www.cesm.ucar.edu/models/register/register_cesm.cgi>

### Create the appropriate machine configuration for CESM.

Assuming the CESM is installed in `$HOME/cesm1_0_4` you need to create a machine
description in the directory:

     $HOME/cesm1_0_4/scripts/ccsm_utils/Machines

In this directory you will find a collection of files looking something like this:

- `Macros.abc` contains the compile macros for machine `abc`.
- `env_machopts.abc` contains the environment for machine `abc`.
- `mkbatch.abc` generates a submission script for machine `abc`.
- `config_machines.xml` contains all machine configurations. 

To use CESM you need to creates a Macros, env_machopts and mkbatch files for your 
specirfic machine and environment. The easiest approach is to copy an existing 
configuration of a machine similar to your own, and adapt that until it works. 

Once the configuration is created, you must add a section to the `config_machines.xml`
file so CESM can find your configuration.

For Cartesisus and Stampede we have prepared the following files:

Stampede:

- [Macros.stampede](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/Macros.stampede)
- [env_machopts.stampede](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/env_machopts.stampede)
- [mkbatch.stampede](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/mkbatch.stampede)

Cartesius (using GCC 4.8.0): 

- [Macros.cartesius_gcc](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/Macros.cartesius_gcc)
- [env_machopts.cartesius_gcc](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/env_machopts.cartesius_gcc)
- [mkbatch.cartesius_gcc](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/mkbatch.cartesius_gcc)

This config file contains descriptions for both the Stampede and Cartesius machines.

- [config_machines.xml](https://github.com/jmaassen/EYRg-wiki/blob/master/configs/config_machines.xml)

Please download these files and copy them to:

     $HOME/cesm1_0_4/scripts/ccsm_utils/Machines

If necessary you can edit the `config_machines.xml` file to change the locations of the input and output 
directries. For example, in the "cartesius_gcc" section, the following paths are set:

     EXEROOT="/home/$CCSMUSER/CESM/experiments/$CASE/build"
     DIN_LOC_ROOT_CSMDATA="/projects/esalsa/inputdata"
     DOUT_S_ROOT="/home/$CCSMUSER/CESM/archive/$CASE"

In this machine description, the experiment dirs will be created in `$HOME/CESM/experiments` 
(see EXEROOT), the output archive is located in `$HOME/CESM/archive` (see DOUT_S_ROOT), and the input
is located in `/projects/esalsa/inputdata` (see DIN_LOC_ROOT_CSMDATA). 

The EXEROOT directory will be used to create temporary output files such as logs and checkpoint. 
This may be a lot of data! Once a CESM run has completed succesfully, al these logs and data will
be copied to the output archive specified in DOUT_S_ROOT.

### Create the appropriate experiment directories

As explained above, CESM uses certain experiment directories, so make sure they exist:

     mkdir -p $HOME/CESM/experiments
     mkdir -p $HOME/CESM/archive

### Create an experiment

To setup a CESM experiment you must use the "create_newcase" script:

     cd $HOME/CESM/experiments
     $HOME/cesm1_0_4/scripts/create_newcase -case test1 -mach cartesius_gcc -compset B -res f05_t12

This creates a "test1" directory in `$HOME/CESM/experiments` that contains a CESM instance configuration 
for a simulation using compset "B" (all active models) for resolution "f05_t12" (0.5 degree atmosphere
and land and 0.1 degree ocean and sea ice) using the configuration for "cartesius_gcc".

This configuration is only __PARTLY__ configured for running on Cartesius.

To complete the configuration of the experiment do the following:
   
     cd $HOME/CESM/experiments/test1

- Edit the "env_mach_pes.xml" to set the core configuration for this experiment. 
- Edit the "env_conv.xml" file to set the correct run type and start date. or use 
- Edit the "env_run.xml" file to set the desired experiment length.

We have also prepared these test configurations for Cartesius:

- [env_mach_pes.xml]()
- [env_conv.xml]()
- [env_run.xml]()

These configurations are setup as follows:

- CESM is run on 1728 cores (72 nodes x 24 cores) of Cartesius
- Atmosphere runs on 504 cores (21 nodes) shared with coupler (504), land (24) and sea ice (480).
- Ocean runs concurrently on an additional 1225 cores (51 nodes)
- 4 coupling per model day between ocean and others. 
- The simulation runs for 31 model days. 


### Build the experiment

Next, build the experiment like this:

     cd $HOME/CESM/experiments/test1
     ./configure -case
     ./test1.cartesius_gcc.build 

The `configure -case` generates the necessary scripts and configuration files for this 
particular experiment with this particular configuration. In general any changes to one of 
the configuration files will require CESM to be recompiled.


### Start CESM 

After a succesfull build, start CESM using the generates script:

     cd $HOME/CESM/experiments/test1
     sbatch test.cartesius_gcc.run

CESM will now run on in the `$HOME/CESM/experiments/test1/build` directory. All output and 
logging files will be written there. After a successfull run, all output will be copied to 
`$HOME/CESM/archive/test1/`.













