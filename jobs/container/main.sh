#PBS -N ContainerFill
#PBS -l nodes=8:ppn=12
#PBS -l walltime=65:00:00
#PBS -q @oak-batch.osc.edu
#PBS -j oe
#PBS -S /bin/bash

echo "---Job started at:" 
date

#Initialize OpenFOAM-2.1.0
. /usr/local/OpenFOAM/OpenFOAM-2.1.0/etc/bashrc

#Move to the case directory, where the 0, constant and system directories reside
cd $PBS_O_WORKDIR

export MV2_ON_DEMAND_THRESHOLD=96 

surfaceCheck -blockMesh ./constant/triSurface/walls.stl >> LOG-surfaceCheck

python boundingbox.py

sed -e '/vertices/, +10 d' <constant/polyMesh/blockMeshDict>newfile2

sed -e '/convertToMeters 1;/ r newfile' <newfile2>constant/polyMesh/blockMeshDict

rm newfile newfile2

blockMesh < /dev/null >>  LOG-bM

snappyHexMesh -overwrite < /dev/null >>  LOG-sHM

createPatch -overwrite > LOG-createPatch

changeDictionary  < /dev/null >>  LOG-cD

# command below scales mesh (i.e. "(1e-3 1e-3 1e-3)" to convert mm to m)
transformPoints -scale "(1.0 1.0 1.0)" > LOG-scale

cp 0_orig/* 0/


decomposePar < /dev/null >>  LOG-decomp

mpiexec -n 96 interFoam -parallel < /dev/null >>  LOG-iF

#reconstructPar < /dev/null >> LOG-rP
 
touch test.foam

echo "---Job finished at:" 
date
