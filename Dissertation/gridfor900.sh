#!/bin/bash -l
#$ -l h_rt=70:00:0
#$ -l mem=50G
#$ -l tmpfs=30G
#$ -N gridfor_900
#$ -wd /home/ucfnhbx/Scratch/osm/gridfor/i900
cd $TMPDIR
module unload compilers mpi
module load compilers/gnu/4.9.2
module load python3/recommended
export PYTHONPATH=/home/ucfnhbx/Scratch/lib/python3.9/site-packages:$PYTHONPATH
python < /home/ucfnhbx/Scratch/osm/gridfor/i900/gridfor900.py > /home/ucfnhbx/Scratch/osm/gridfor/i900/gridfor_900.out