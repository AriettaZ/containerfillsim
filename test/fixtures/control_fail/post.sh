#PBS -N CFP_PostPro
#PBS -l nodes=1:ppn=12:gpus=2:vis
#PBS -q @oak-batch.osc.edu
#PBS -l walltime=0:15:00
#PBS -j oe
#PBS -S /bin/bash

cd $PBS_O_WORKDIR

module load turbovnc
module load virtualgl
#module load paraview-3.8.0

ONDEMAND=1 vncserver
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/qt/4.7.4/lib/
export DISPLAY=`ONDEMAND=1 vncserver |& grep "desktop" | sed 's/.*\.osc\.edu//'`
vglrun  /usr/local/paraview/ParaView-3.14.1-Linux-x86_64/bin/pvpython image.py
mkdir movies/
convert -delay 100 -loop 0 -background white images/*.png movies/filling.gif
vncserver -kill $DISPLAY
