#!/bin/bash -l
#$ -l h_rt=30:00:0
#$ -l mem=30G
#$ -l tmpfs=35G
#$ -N corrviz
#$ -wd /home/ucfnhbx/Scratch/coco2
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/coco2/corrviz.R > /home/ucfnhbx/Scratch/coco2/corrviz$JOB_ID.out