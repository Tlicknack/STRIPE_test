#!/bin/bash

#PBS -N STRIPEseq_para_test
#PBS -k o
#PBS -l nodes=1:ppn=8,vmem=48gb
#PBS -l walltime=5:00:00

module load java
module load samtools
module load sra-toolkit
module load trimmomatic
module unload python
module load python/3.6.1 

WD=/N/dc2/scratch/tlicknac/STRIPE_Novaurelia/

cd $WD

time ./xdoit >& err

exit
