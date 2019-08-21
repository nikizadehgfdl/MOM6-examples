#!/bin/csh -fx

echo -n Started $0 in ; pwd
echo  Started at
date
# Modules
source $MODULESHOME/init/csh
module use -a /home/fms/local/modulefiles
module unload python nco netcdf
module load hdf5 netcdf/4.2 intel_compilers
module load nco/4.3.1
module load mpich2
module load git
module load python/2.7.3_workstation

# Run through the work flow
# module python/3.6.4 has a conflict with intel_compilers and if loaded does not let icc to compile
# So, first make all the compile jobs then load python 
#make fre_nctools/tools/make_solo_mosaic/make_solo_mosaic
#make fre_nctools/tools/make_quick_mosaic/make_quick_mosaic
# Generate grid using the new tools
make ocean_hgrid.nc
# Generate topography using the new tools (only works with python3)
module unload python
module load python/3.6.4 
#make ocean_topog.nc
make mosaic_ocean/grid_spec.nc
make mosaic_ocean/salt_restore.nc
make mosaic_ocean/seawifs-clim-1997-2010.nc
make mosaic_ocean/geothermal_davies2013_v1.nc
make mosaic_ocean/runoff.daitren.iaf.v2011.02.10.nc
make mosaic_ocean/runoff.daitren.clim.v2011.02.10.nc
# MIDAS tools work only with python2
module swap python/2.7.3_workstation
setenv PYTHONPATH $cwd/MIDAS:local/lib/python/
make mosaic_ocean/tidal_amplitude.nc
make mosaic_ocean/basin_codes.nc
#WOA regrid is needed only for PP, no need to bundle it with the mosaic tar
make WOA05_ptemp_salt_annual.nc
# Generate some mask_tables
module unload python nco netcdf
module load hdf5
module load netcdf/4.2 intel_compilers
module load nco/4.3.1
module load mpich2
make mosaic_ocean/mask_tables
echo  Ended at
date
exit 0
# Regrid obs data with MIDAS tools which only work with python2
module unload python
module load python/2.7.3_workstation
make forcing
make obs
