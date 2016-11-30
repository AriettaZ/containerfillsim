#PBS -N container
#PBS -l nodes=1:ppn=12
#PBS -l walltime=01:00:00
#PBS -j oe
#PBS -S /bin/bash

echo "---Job started at:"
date

echo "Doing post processing..."

sleep 30

echo "---Job finished at:"
date
