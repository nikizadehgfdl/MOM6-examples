#!/bin/csh -x
set platform = "theta-intel_avx1"

#load modules
module unload PrgEnv-pgi PrgEnv-intel PrgEnv-gnu PrgEnv-cray darshan
module unload cray-netcdf cray-hdf5
module load PrgEnv-intel/6.0.4
module load cray-hdf5/1.10.1.1
module load cray-netcdf/4.4.1.1.6

set root = $cwd
mkdir -p build/$platform/shared/repro-openmp
pushd build/$platform/shared/repro-openmp  
rm -f path_names
../../../../src/mkmf/bin/list_paths ../../../../src/FMS
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names
make NETCDF=3 OPENMP=1 libfms.a
popd

mkdir -p build/$platform/ocean_only/repro-openmp
pushd build/$platform/ocean_only/repro-openmp
rm -f path_names
../../../../src/mkmf/bin/list_paths ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ 
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -o '-I../../shared/repro-openmp' -p MOM6 -l '-L../../shared/repro-openmp -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names 
make NETCDF=3 OPENMP=1 MOM6


exit 0

mkdir -p build/$platform/ocean_ice/repro-openmp

pushd build/$platform/ocean_ice/repro-openmp  
rm -f path_names
../../../../src/mkmf/bin/list_paths ./ ../../../../src/MOM6/config_src/{dynamic,coupled_driver} ../../../../src/MOM6/src/{*,*/*}/ ../../../../src/{atmos_null,coupler,land_null,ice_ocean_extras,icebergs,SIS2,FMS/coupler,FMS/include}/ 
../../../../src/mkmf/bin/mkmf -t ../../../../tools/platforms/$platform.mk -o '-I../../shared/repro-openmp' -p MOM6 -l '-L../../shared/repro-openmp -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names 
make NETCDF=3 OPENMP=1 MOM6
popd

###Sample compile lines
##theta-Intel18_avx1
#ftn -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -O2 -debug minimal -fp-model source -qoverride-limits -qopt-prefetch=3 -qopenmp -I../../shared/repro-openmp  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework        ../../../../src/MOM6/src/core/MOM.F90
#ifort: command line warning #10121: overriding '-xmic-avx512' with '-xCORE-AVX-I'

