#!/bin/bash -l
#$ -l h_rt=60:00:0
#$ -l mem=20G
#$ -l tmpfs=20G
#$ -N queentree
#$ -wd /home/ucfnhbx/Scratch/hiery2
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/hiery2/queentree.R >/home/ucfnhbx/Scratch/hiery2/queentree$JOBID.out