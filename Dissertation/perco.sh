#!/bin/bash -l
#$ -l h_rt=10:00:0
#$ -l mem=10G
#$ -l tmpfs=15G
#$ -N perco
#$ -pe smp 8
#$ -wd /home/ucfnhbx/Scratch/perco
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/perco/percolation_network-modified.R > /home/ucfnhbx/Scratch/perco/perco$JOB_ID.out