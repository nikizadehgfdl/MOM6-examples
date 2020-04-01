#!/bin/bash -x                                     
set -e
echo -n Started $0 in ; pwd
echo  Started at
date
# Modules
source $MODULESHOME/init/bash
module use -a /home/fms/local/modulefiles
module unload python nco netcdf
module load hdf5 netcdf/4.2 intel_compilers
module load nco/4.3.1
module load mpich2
module load git

# Run through the work flow
# module python/3.6.4 has a conflict with intel_compilers and if loaded does not let icc to compile
# So, first make all the compile jobs then load python 
#make fre_nctools/tools
# Generate some mask_tables
module unload python nco netcdf
module load hdf5
module load netcdf/4.2 intel_compilers
module load nco/4.3.1
module load mpich2
make mosaic_c192/mask_tables
make mosaic_c192/mosaic.nc
make mosaic_c192/river_data.tile1.nc
module load python/2.7.3_workstation
make local #This still cause trouble 
make mosaic_c192/basin_codes.nc
echo  Ended at
date
exit 0
