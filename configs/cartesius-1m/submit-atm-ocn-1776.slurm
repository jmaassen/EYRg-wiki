#!/bin/tcsh -f
#
# Slurm job description that starts a run on 38 nodes.
#
# This run consists of 12+1 nodes running the ATM/LND/CICE and CPL, 
# and 24+1 nodes running the OCN model. In both cases the +1 is used 
# for the gateway nodes.  
#

#SBATCH --time=03:00:00 
#SBATCH -N 74
#SBATCH -p normal
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=eyrg4_74nodes

setenv EMPI_ATM_NODES 22
setenv EMPI_OCN_NODES 52

# ---------------------------------------- 
# PE LAYOUT: 
#   total number of tasks  = 864 
#   maximum threads per task = 1 
#   cpl ntasks=288  nthreads=1 rootpe=0 
#   cam ntasks=288  nthreads=1 rootpe=0 
#   clm ntasks=24  nthreads=1 rootpe=240 
#   cice ntasks=240  nthreads=1 rootpe=0 
#   pop2 ntasks=576  nthreads=1 rootpe=288 
#   sglc ntasks=1  nthreads=1 rootpe=0 
#   
#   total number of hw pes = 864 
#     cpl hw pe range ~ from 0 to 287 
#     cam hw pe range ~ from 0 to 287 
#     clm hw pe range ~ from 240 to 263 
#     cice hw pe range ~ from 0 to 239 
#     pop2 hw pe range ~ from 288 to 863 
#     sglc hw pe range ~ from 0 to 0 
# ---------------------------------------- 
#-----------------------------------------------------------------------
# Determine necessary environment variables
#-----------------------------------------------------------------------

cd /home/jason/CESM/experiments/eyrg_gcc1_new

./Tools/ccsm_check_lockedfiles || exit -1
source ./Tools/ccsm_getenv || exit -2

if ($BUILD_COMPLETE != "TRUE") then
  echo "BUILD_COMPLETE is not TRUE"
  echo "Please rebuild the model interactively via"
  echo "   ./${CASE}.${MACH}.build"
  exit -2
endif

setenv LBQUERY  TRUE
setenv LBSUBMIT TRUE

#-----------------------------------------------------------------------
# Determine time-stamp/file-ID string
# Clean up previous run timing files
#-----------------------------------------------------------------------

setenv LID "`date +%y%m%d-%H%M%S`"
env | egrep '(MP_|LOADL|XLS|FPE|DSM|OMP|MPC)' # document env vars

# -------------------------------------------------------------------------
# Build the namelists and check prestage
# -------------------------------------------------------------------------

cd $CASEROOT
source $CASETOOLS/ccsm_buildnml.csh || exit -3
cd $CASEROOT
source $CASETOOLS/ccsm_prestage.csh || exit -3

# -------------------------------------------------------------------------
# Create and cleanup the timing directories
# -------------------------------------------------------------------------

if (-d $RUNDIR/timing) rm -r -f $RUNDIR/timing
mkdir $RUNDIR/timing
mkdir $RUNDIR/timing/checkpoints

# -------------------------------------------------------------------------
# Create nodelists for both clusters
# -------------------------------------------------------------------------

cd $RUNDIR

echo "++++++++++++++++++++++++++++++++++++++++++++++++++="

nodeset -e "$SLURM_JOB_NODELIST"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++="

nodeset -e "$SLURM_JOB_NODELIST" | tr ' ' \\n | head -n "$EMPI_ATM_NODES" | awk  '{for(i=0;i<24;i++)printf "%s\n", $1}' > ccsm.ATM.proc.$LID
echo ATM TASKS:
cat ccsm.ATM.proc.$LID

echo "++++++++++++++++++++++++++++++++++++++++++++++++++="

nodeset -e "$SLURM_NODELIST" | tr ' ' \\n | tail -n "$EMPI_OCN_NODES" | awk  '{for(i=0;i<24;i++)printf "%s\n", $1}' > ccsm.OCN.proc.$LID
echo OCN TASKS:
cat ccsm.OCN.proc.$LID

echo "++++++++++++++++++++++++++++++++++++++++++++++++++="

setenv LD_LIBRARY_PATH /hpc/sw/cuda/5.5//lib64:/opt/intel/composer_xe_2013_sp1.2.144/compiler/lib/intel64:/opt/intel/composer_xe_2013_sp1.2.144/debugger/lib/intel64:/opt/intel/impi/4.1.0.024/lib64

set sdate = `date +"%Y-%m-%d %H:%M:%S"`
echo "run started $sdate" >>& $CASEROOT/CaseStatus

# -------------------------------------------------------------------------
# Run the model
# -------------------------------------------------------------------------

sleep 25
echo "`date` -- CSM EXECUTION BEGINS HERE" 

#===============================================================================
# GENERIC_USER
# Launch the job here.  Some samples are commented out below
#===============================================================================

# Start the ATM model
setenv EMPI_CONFIG /home/jason/eSalsa-MPI/hub/cluster-atm.config
setenv SLURM_HOSTFILE ccsm.ATM.proc.$LID
srun -v -v -t 2:58:00 -o ccsm.ATM.log.$LID.%t -n 528 --distribution=arbitrary ./start.sh >& ccsm.ATM.log.$LID &

# Start the OCN model
setenv EMPI_CONFIG /home/jason/eSalsa-MPI/hub/cluster-ocn.config 
setenv SLURM_HOSTFILE ccsm.OCN.proc.$LID
srun -v -v -t 2:58:00 -o ccsm.OCN.log.$LID.%t -n 1248 --distribution=arbitrary ./start.sh >& ccsm.OCN.log.$LID &

wait
echo "`date` -- CSM EXECUTION HAS FINISHED" 

cd $CASEROOT
./Tools/ccsm_postrun.csh || exit 1

