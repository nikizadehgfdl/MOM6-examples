#!/bin/csh -x                                                                                  
set platform = "lscsky50-intel18up2_avx1"                                                           
set target = "debug"                                                                           
#load modules                                                                                  
source tools/platforms/$platform.env

set makeflags = "NETCDF=3"

if( $target =~ *"openmp"* ) then 
   set makeflags = "$makeflags OPENMP=1" 
endif

if( $target =~ *"repro"* ) then
   set makeflags = "$makeflags REPRO=1"
endif

if( $target =~ *"debug"* ) then
   set makeflags = "$makeflags DEBUG=1"
endif

set root = $cwd
mkdir -p build/$platform/shared/$target
pushd build/$platform/shared/$target   
rm -f path_names                       
../../../../src/mkmf/bin/list_paths ../../../../src/FMS
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names

make $makeflags libfms.a         

popd

mkdir -p build/$platform/ocean_only/$target
pushd build/$platform/ocean_only/$target
rm -f path_names
../../../../src/mkmf/bin/list_paths ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -o "-I../../shared/$target" -p MOM6 -l "-L../../shared/$target -lfms" -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names

make $makeflags MOM6
exit 0


