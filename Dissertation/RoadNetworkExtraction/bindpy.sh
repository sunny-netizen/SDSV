#!/bin/bash -l
#$ -l h_rt=70:00:0
#$ -l mem=80G
#$ -l tmpfs=15G
#$ -N bindpy
#$ -wd /home/ucfnhbx/Scratch/osm/gridfor
cd $TMPDIR
module unload compilers mpi
module load compilers/gnu/4.9.2
module load python3/recommended
export PYTHONPATH=/home/ucfnhbx/Scratch/lib/python3.9/site-packages:$PYTHONPATH
python3 </home/ucfnhbx/Scratch/osm/gridfor/bind.py >/home/ucfnhbx/Scratch/osm/gridfor/bindpy.out
