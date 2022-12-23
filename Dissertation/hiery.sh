#!/bin/bash -l
#$ -l h_rt=60:00:0
#$ -l mem=70G
#$ -l tmpfs=20G
#$ -N hiery
#$ -wd /home/ucfnhbx/Scratch/hiery2
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/hiery2/hierarchical_tree-europe.R >/home/ucfnhbx/Scratch/hiery2/hiery.out