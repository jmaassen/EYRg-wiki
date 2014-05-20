#!/bin/tcsh -f
#
# Slurm job description that starts a job on 21+1 nodes.
#
# This run consists of 21 nodes running the ATM/LND/CICE and CPL, 
# and 1 node running the gateways.
#

#SBATCH --time=03:00:00 
#SBATCH -N 22
#SBATCH -p normal
#SBATCH --ntasks-per-node=24
#SBATCH --job-name=job-atm

#-----------------------------------------------------------------------
# Determine necessary environment variables
#-----------------------------------------------------------------------

cd /home/jason/CESM/experiments/test_eyrg

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

set sdate = `date +"%Y-%m-%d %H:%M:%S"`
echo "run started $sdate" >>& $CASEROOT/CaseStatus

# -------------------------------------------------------------------------
# Run the model
# -------------------------------------------------------------------------

sleep 25
cd $RUNDIR
echo "`date` -- CSM EXECUTION BEGINS HERE" 

#===============================================================================
# GENERIC_USER
# Launch the job here.  Some samples are commented out below
#===============================================================================

# Start the job-ATM
setenv EMPI_CONFIG /home/jason/CESM/experiments/test_eyrg/job-atm.config
srun ./ccsm.exe >& ccsm.ATM.log.$LID

wait
echo "`date` -- CSM EXECUTION HAS FINISHED" 

cd $CASEROOT
./Tools/ccsm_postrun.csh || exit 1

