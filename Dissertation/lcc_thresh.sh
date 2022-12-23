#!/bin/bash -l
#$ -l h_rt=10:00:0
#$ -l mem=50G
#$ -l tmpfs=15G
#$ -N lccthresh
#$ -wd /home/ucfnhbx/Scratch/perco
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/perco/lcc_thresh.R >/home/ucfnhbx/Scratch/perco/lccthresh$JOB_ID.out