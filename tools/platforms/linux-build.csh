#!/bin/csh -x                                                                                  
set platform = "theta-intel18_avx1"                                                           
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

###Sample compile line
##lscsky50-intel18up2_avx1.debug
#mpiifort -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/netcdf/4.6.1/INTEL/include -I/opt/intel/2018_up2/impi/2018.2.199/include64 -I/opt/netcdf/4.6.1/INTEL/include -I/opt/intel/2018_up2/impi/2018.2.199/include64 -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fp-stack-check -fstack-protector-all -fpe0 -debug -traceback -ftrapuv -I../../shared/debug  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework     ../../../../src/MOM6/src/core/MOM.F90
##
##theta-intel18_avx1.debug
#ftn -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fp-stack-check -fstack-protector-all -fpe0 -debug -traceback -ftrapuv -I../../shared/debug  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework  ../../../../src/MOM6/src/core/MOM.F90
#ifort: command line warning #10121: overriding '-xmic-avx512' with '-xCORE-AVX-I'

