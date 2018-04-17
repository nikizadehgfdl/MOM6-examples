#!/bin/csh -x                                                                                  
set platform = "theta-intel17_avx1"                                                           
set target = "repro"                                                                           
#load modules                                                                                  
source tools/platforms/$platform.env

set root = $cwd
mkdir -p build/$platform/shared/$target
pushd build/$platform/shared/$target   
rm -f path_names                       
../../../../src/mkmf/bin/list_paths ../../../../src/FMS
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names

if( $target =~ *"openmp"* ) then 
   make NETCDF=3 OPENMP=1 libfms.a
else                              
   make NETCDF=3 libfms.a         
endif                             

popd

mkdir -p build/$platform/ocean_only/$target
pushd build/$platform/ocean_only/$target
rm -f path_names
../../../../src/mkmf/bin/list_paths ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -o "-I../../shared/$target" -p MOM6 -l "-L../../shared/$target -lfms" -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names

if( $target =~ *"openmp"* ) then
   make NETCDF=3 OPENMP=1 MOM6
else
   make NETCDF=3 MOM6
endif


exit 0


