#!/bin/bash -l
#$ -l h_rt=40:00:0
#$ -l mem=30G
#$ -l tmpfs=30G
#$ -N cocollel
#$ -wd /home/ucfnhbx/Scratch/coco2
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/coco2/cocollel.R > /home/ucfnhbx/Scratch/coco2/cocollel$JOB_ID.out