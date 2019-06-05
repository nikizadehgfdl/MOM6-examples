#!/bin/csh -fx

echo -n Started $0 in ; pwd

# Modules
source $MODULESHOME/init/csh
module use -a /home/fms/local/modulefiles
module unload python nco netcdf
module load netcdf/4.2 intel_compilers
module load nco/4.3.1
module load mpich2
module load git

# Run through the work flow
# module python/3.6.4 has a conflict with intel_compilers and if loaded does not let icc to compile
# So, first make all the compile jobs then load python 
make fre_nctools/tools/make_solo_mosaic/make_solo_mosaic
make fre_nctools/tools/make_quick_mosaic/make_quick_mosaic
# Generate grid using the new tools
#module unload python
module load python/3.4.3 
#python/3.6.4
make ocean_hgrid.nc
# Generate topography using the new tools (only works with python3)
make ocean_topog.nc
make mosaic_ocean/grid_spec.nc
make mosaic_ocean/salt_restore.nc
make mosaic_ocean/seawifs-clim-1997-2010.nc
make mosaic_ocean/geothermal_davies2013_v1.nc
make mosaic_ocean/runoff.daitren.iaf.v2011.02.10.nc
make mosaic_ocean/runoff.daitren.clim.v2011.02.10.nc
exit 0
# Installing these files from archive is a workaround for the firewall on the GFDL PAN cluster
cp -n /archive/gold/datasets/obs/tpxo7_atlas_netcdf.tar.Z .
cp -n /archive/gold/datasets/obs/WOA05_pottemp_salt.nc .
cp -n /archive/gold/datasets/CORE/PHC2_salx/PHC2_salx.2004_08_03.nc .
cp -n /archive/gold/datasets/CORE/NYF_v2.0/runoff.daitren.clim.v2011.02.10.nc .
cp -n /archive/gold/datasets/CORE/IAF_v2.0/runoff.daitren.iaf.v2011.02.10.nc .
# Work around for environment problem inside MIDAS
setenv PYTHONPATH $cwd/local/lib

# Regrid obs data with MIDAS tools which only work with python2
module unload python
module load python/2.7.3_workstation
make basin_codes.nc
make ocean_mosaic
make forcing
make obs
