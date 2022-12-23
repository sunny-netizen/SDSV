#!/bin/bash -l
#$ -l h_rt=10:00:0
#$ -l mem=80G
#$ -l tmpfs=15G
#$ -N allnodes
#$ -wd /home/ucfnhbx/Scratch/osm/gridfor
cd $TMPDIR
module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R --no-save </home/ucfnhbx/Scratch/osm/gridfor/allnodes.R >/home/ucfnhbx/Scratch/osm/gridfor/allnodes$JOB_ID.out