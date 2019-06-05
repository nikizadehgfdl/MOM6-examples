# Makefile to create supergrid.nc and interpolated_topog.nc
# To use:
#   module load python
#   setenv PYTHONPATH $cwd/MIDAS
#
# then
#   make all
# or
#   make supergrid.nc
#   make interpolated_topog.nc

SHELL=tcsh -f
NP=8
FRE_NCTOOLS = fre_nctools/tools

all: ocean_grid ocean_mosaic c96_mosaic c192_mosaic forcing obs
	md5sum -c md5sums.txt

showenv:
	env
	-set
	-module list
	which python
	-python --version

forcing: mosaic_ocean/salt_restore.nc mosaic_ocean/seawifs-clim-1997-2010.nc mosaic_ocean/tidal_amplitude.nc mosaic_ocean/runoff.daitren.clim.v2011.02.10.nc mosaic_ocean/runoff.daitren.iaf.v2011.02.10.nc mosaic_ocean/geothermal_davies2013_v1.nc

obs: WOA05_ptemp_salt_monthly.nc WOA05_ptemp_salt_annual.nc

# Grids
.PHONY: ocean_grid
ocean_grid: ocean_hgrid.nc

ocean_hgrid.nc: pytools/grid_generation
	pytools/grid_generation/ocean_grid_generator.py --write_subgrid_files -f $(@F) -r 8 

pytools/grid_generation: 
	echo $@
	mkdir -p $(@D) 
	cd $(@D); git clone --recursive -b correct_joins https://github.com/nikizadehgfdl/grid_generation.git

check:
	nccmp -d $(OCN_GRID_DIR)/ocean_hgrid.nc /archive/gold/datasets/OM4_05/mosaic_ocean.v20180227.unpacked/ocean_hgrid.nc

# Topography
pytools/thin-wall-topography:
	echo $@
	mkdir -p $(@D) 
	cd $(@D); git clone -b dev https://github.com/nikizadehgfdl/thin-wall-topography.git

topog: topog_MERC.nc topog_SO.nc topog_BP.nc topog_SC.nc

topog_MERC.nc: pytools/thin-wall-topography ocean_hgrid.ncMerc.nc 
	pytools/thin-wall-topography/python/create_topog_refinedSampling.py --hgridfilename ./ocean_hgrid.ncMerc.nc --outputfilename $(@F) 

topog_SO.nc: pytools/thin-wall-topography ocean_hgrid.ncSO.nc 
	pytools/thin-wall-topography/python/create_topog_refinedSampling.py --hgridfilename ./ocean_hgrid.ncSO.nc --outputfilename $(@F)

topog_SC.nc: pytools/thin-wall-topography ocean_hgrid.ncSC.nc 
	pytools/thin-wall-topography/python/create_topog_refinedSampling.py --hgridfilename ./ocean_hgrid.ncSC.nc --outputfilename $(@F)

topog_BP.nc: pytools/thin-wall-topography ocean_hgrid.ncBP.nc
	pytools/thin-wall-topography/python/create_topog_refinedSampling.py --hgridfilename ./ocean_hgrid.ncBP.nc --outputfilename $(@F)

topog_merged.nc: pytools/thin-wall-topography topog_SC.nc topog_SO.nc topog_MERC.nc topog_BP.nc
	pytools/thin-wall-topography/python/merge_topog_tiles.py --tilefiles topog_SC.nc,topog_SO.nc,topog_MERC.nc,topog_BP.nc  --outputfilename $(@F)

topog_editted.nc: pytools/thin-wall-topography topog_merged.nc
	cp topog_merged.nc tmp.nc 
#	pytools/thin-wall-topography/python/apply_topog_edits.py topo_edits_020718.nc tmp.nc --variable 'height'
	cp tmp.nc $(@F)

topog_ice9ed.nc: pytools/thin-wall-topography topog_editted.nc
	pytools/thin-wall-topography/python/ice9.py topog_editted.nc --variable 'height' --iseed 10 --jseed 600 --output $(@F)

ocean_topog.nc: topog_ice9ed.nc
	cp topog_ice9ed.nc topog.nc
	ln -s topog.nc ocean_topog.nc

mosaic_ocean/ocean_mosaic.nc: ocean_hgrid.nc ocean_topog.nc $(FRE_NCTOOLS)/make_solo_mosaic/make_solo_mosaic
	mkdir -p $(@D)
	(cd $(@D); cp ../ocean_hgrid.nc ../ocean_topog.nc .)
	(cd $(@D); ../$(FRE_NCTOOLS)/make_solo_mosaic/make_solo_mosaic --num_tiles 1 --dir . --mosaic_name ocean_mosaic --tile_file ocean_hgrid.nc --periodx 360.)

mosaic_ocean/grid_spec.nc: mosaic_ocean/ocean_mosaic.nc $(FRE_NCTOOLS)/make_quick_mosaic/make_quick_mosaic
	(cd $(@D); ../$(FRE_NCTOOLS)/make_quick_mosaic/make_quick_mosaic --reproduce_siena --input_mosaic ocean_mosaic.nc --mosaic_name grid_spec --ocean_topog ocean_topog.nc )

mosaic_ocean/ocean_mask.nc: mosaic_ocean/ocean_mosaic.nc

pytools/regrid_runoff:
	echo $@
	mkdir -p $(@D) 
	cd $(@D); git clone -b nikizadehgfdl/use_netcdf4_deflation https://github.com/nikizadehgfdl/regrid_runoff.git

mosaic_ocean/runoff.daitren.clim.nc: mosaic_ocean/ocean_mosaic.nc mosaic_ocean/ocean_mask.nc
#This needs python 3 + numba
#	(cd $(@D); time /net2/nnz/adcroft/regrid_runoff/regrid_runoff.py ocean_hgrid.nc ocean_mask.nc ../runoff.daitren.clim.v2011.02.10.nc --fms runoff_tmp.nc
#This needs python 3 
	cd $(@D); time ../pytools/regrid_runoff/regrid_runoff_nonumba.py ocean_hgrid.nc ocean_mask.nc /archive/gold/datasets/CORE/NYF_v2.0/runoff.daitren.clim.v2011.02.10.nc --fms $(@F)

mosaic_ocean/runoff.daitren.clim.v2011.02.10.nc: mosaic_ocean/runoff.daitren.clim.nc
	(cd $(@D); ncks -h -3 runoff.daitren.clim.nc $(@F))
	(cd $(@D); ncatted -h -O -a 'modulo,time,c,c, ' $(@F))

mosaic_ocean/runoff.daitren.iaf.nc: mosaic_ocean/ocean_mosaic.nc mosaic_ocean/ocean_mask.nc pytools/regrid_runoff
	cd $(@D); time ../pytools/regrid_runoff/regrid_runoff_nonumba.py ocean_hgrid.nc ocean_mask.nc /archive/gold/datasets/CORE/IAF_v2.0/runoff.daitren.iaf.v2011.02.10.nc --fms $(@F)

mosaic_ocean/runoff.daitren.iaf.v2011.02.10.nc: mosaic_ocean/runoff.daitren.iaf.nc
	(cd $(@D); ncks -h -3 runoff.daitren.iaf.nc $(@F))
	(cd $(@D); ncatted -h -O -a 'modulo,time,c,c, ' $(@F))
	(cd $(@D); ncatted -h -O -a modulo_beg,time,a,c,"1948-01-01 00:00:00" $(@F))
	(cd $(@D); ncatted -h -O -a modulo_end,time,a,c,"2008-01-01 00:00:00" $(@F))

basin_codes.nc: ocean_topog.nc
	unlimit stacksize; setenv PYTHONPATH ./local/lib/python; python make_basin_mask.py
	ncatted -h -a flag_meanings,basin,c,c,'1:Southern Ocean, 2:Atlantic Ocean, 3:Pacific Ocean, 4:Arctic Ocean, 5:Indian Ocean, 6:Mediterranean Sea, 7:Black Sea, 8:Hudson Bay, 9:Baltic Sea, 10:Red Sea, 11:Persian Gulf' basin_codes.nc
	ncatted -h -a flag_values,basin,c,c,'1,2,3,4,5,6,7,8,9,10,11' basin_codes.nc

WOA05_ptemp_salt_annual.nc: WOA05_ptemp_salt_monthly.nc
	ncra -h -O $< $@

WOA05_ptemp_salt_monthly.nc: ocean_hgrid.nc ocean_topog.nc  interpWOA05.py local
	unlimit stacksize; setenv PYTHONPATH ./local/lib/python; python interpWOA05.py
	ncatted -h -a modulo,TIME,c,c,' ' WOA05_ptemp_salt_monthly.nc

pytools/interp_and_fill:
	echo $@
	mkdir -p $(@D) 
	cd $(@D); git clone https://github.com/adcroft/interp_and_fill.git; cd interp_and_fill; git checkout 45908a8cbe4

mosaic_ocean/salt_restore.nc: mosaic_ocean/ocean_hgrid.nc mosaic_ocean/ocean_mosaic.nc PHC2_salx.2004_08_03.corrected.nc pytools/interp_and_fill
	cd $(@D); ../pytools/interp_and_fill/interp_and_fill.py  ocean_hgrid.nc ocean_mask.nc ../PHC2_salx.2004_08_03.corrected.nc SALT --fms --closest salt_restore.nc
	cd $(@D); ncatted -h -a modulo,time,c,c,' ' salt_restore.nc
	cd $(@D); ncatted -h -a units,time,m,c,'days since 0001-01-01 00:00:00' salt_restore.nc

seawifs-clim-1997-2010.nc: 
	dmget /archive/gold/datasets/obs/SeaWiFS/fill_ocean_color/seawifs-clim-1997-2010.nc
	ln -s /archive/gold/datasets/obs/SeaWiFS/fill_ocean_color/seawifs-clim-1997-2010.nc .

mosaic_ocean/seawifs-clim-1997-2010.nc: ocean_hgrid.nc ocean_topog.nc seawifs-clim-1997-2010.nc pytools/interp_and_fill
	cd $(@D); ../pytools/interp_and_fill/interp_and_fill.py ocean_hgrid.nc ocean_mask.nc ../seawifs-clim-1997-2010.nc  chlor_a --fms $(@F)
#	cd $(@D); ncatted -h -a modulo,TIME,c,c,' ' $(@F)

#regrid geothermal_davies2013
mosaic_ocean/geothermal_davies2013_v1.nc: preprocessing_geothermal/geothermal_davies2013_v1.nc
	cp $^ $@
preprocessing_geothermal/geothermal_davies2013_v1.nc: preprocessing_geothermal/Makefile
	cp ocean_hgrid.nc $(@D)/
	cd $(@D); make geothermal_davies2013_v1.nc
preprocessing_geothermal/Makefile:
	git clone https://github.com/adcroft/OM4_05_preprocessing_geothermal.git $(@D)

mosaic_ocean/tidal_amplitude.nc: DATA ocean_topog.nc local
	unlimit stacksize; setenv PYTHONPATH local/lib/python; python interpTides.py
	mv tidal_amplitude.nc $@

DATA: tpxo7_atlas_netcdf.tar.Z
	tar xzvf tpxo7_atlas_netcdf.tar.Z
	touch DATA

tpxo7_atlas_netcdf.tar.Z:
	wget ftp://ftp.oce.orst.edu/dist/tides/Global/tpxo7_atlas_netcdf.tar.Z

PHC2_salx.2004_08_03.corrected.nc: PHC2_salx.2004_08_03.nc
	ncap2 -h -O -s 'time(:)={15,45,76,106,136,168,198,228,258,288,320,350}' PHC2_salx.2004_08_03.nc PHC2_salx.2004_08_03.corrected.nc
	ncatted -h -O -a units,time,o,c,'days since 1900-01-01 00:00:00' PHC2_salx.2004_08_03.corrected.nc
	ncatted -h -O -a long_name,time,o,c,'Day of year' PHC2_salx.2004_08_03.corrected.nc
	ncatted -h -O -a calendar,time,c,c,'julian' PHC2_salx.2004_08_03.corrected.nc
	ncatted -h -O -a modulo,time,c,c,' ' PHC2_salx.2004_08_03.corrected.nc
	ncatted -h -O -a calendar_type,time,c,c,'julian' PHC2_salx.2004_08_03.corrected.nc

PHC2_salx.2004_08_03.nc:
	wget http://data1.gfdl.noaa.gov/~nnz/mom4/COREv1/support_data/PHC2_salx.2004_08_03.nc

MIDAS:
	git clone https://github.com/mjharriso/MIDAS.git
	(cd MIDAS; git checkout a067a11693d97d7993c2c6522e118490666eeae0)

local: MIDAS
	-rm -rf $</build/*
	mkdir -p $@
	cd $<; make -f Makefile_GFDL INSTALL_PATH=../local
	touch $@

mosaic_ocean/mask_tables: fre_nctools/tools/check_mask/check_mask
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 120,112
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 72,40
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 64,64
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 72,72
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 90,72
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 90,90
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 100,90
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 100,100
	cd $(@D); ../$(FRE_NCTOOLS)/check_mask/check_mask --grid_file ocean_mosaic.nc --ocean_topog ocean_topog.nc --layout 120,120


fre_nctools:
	echo $@
	git clone http://gitlab.gfdl.noaa.gov/fre/fre-nctools.git $@
	(cd $@; git checkout 168f6a5a2717bc80961da6ba751509cd8c7ace0d)
#	(cd $@; git checkout user/z1l/dev)
fre_nctools/tools: fre_nctools
fre_nctools/tools/make_solo_mosaic/make_solo_mosaic fre_nctools/tools/make_quick_mosaic/make_quick_mosaic \
fre_nctools/tools/make_coupler_mosaic/make_coupler_mosaic fre_nctools/tools/make_coupler_mosaic/make_coupler_mosaic_parallel fre_nctools/tools/check_mask/check_mask\
fre_nctools/tools/runoff_regrid/runoff_regrid fre_nctools/tools/runoff_regrid/runoff_regrid_parallel: fre_nctools/tools
	(cd $(@D); make SITE=pan -f fre-nctools.mk $(@F))

OCN_MOSAIC = $(foreach f,atmos_mosaic_tile1Xland_mosaic_tile1.cdl atmos_mosaic_tile1Xocean_mosaic_tile1.cdl grid_spec.cdl land_mask.cdl\
                         land_mosaic_tile1Xocean_mosaic_tile1.cdl ocean_mask.cdl ocean_mosaic.cdl runoff.daitren.clim.v2011.02.10.720x576.nc runoff.daitren.iaf.v2011.02.10.720x576.nc,mosaic_ocean.720x576/$f)
C96_MOSAIC = $(foreach f,C96_grid.tile1.nc C96_grid.tile2.nc C96_grid.tile3.nc C96_grid.tile4.nc C96_grid.tile5.nc C96_grid.tile6.nc C96_mosaic.nc\
                         C96_mosaic_tile1XC96_mosaic_tile1.cdl C96_mosaic_tile1Xocean_mosaic_tile1.cdl C96_mosaic_tile2XC96_mosaic_tile2.cdl C96_mosaic_tile2Xocean_mosaic_tile1.cdl\
                         C96_mosaic_tile3XC96_mosaic_tile3.cdl C96_mosaic_tile3Xocean_mosaic_tile1.cdl C96_mosaic_tile4XC96_mosaic_tile4.cdl C96_mosaic_tile4Xocean_mosaic_tile1.cdl\
                         C96_mosaic_tile5XC96_mosaic_tile5.cdl C96_mosaic_tile5Xocean_mosaic_tile1.cdl C96_mosaic_tile6XC96_mosaic_tile6.cdl C96_mosaic_tile6Xocean_mosaic_tile1.cdl\
                         land_mask_tile1.cdl land_mask_tile2.cdl land_mask_tile3.cdl land_mask_tile4.cdl land_mask_tile5.cdl land_mask_tile6.cdl\
                         mosaic.cdl ocean_mask.cdl,mosaic_c96.720x576/$f)
C192_MOSAIC = $(foreach f,C192_grid.tile1.nc C192_grid.tile2.nc C192_grid.tile3.nc C192_grid.tile4.nc C192_grid.tile5.nc C192_grid.tile6.nc C192_mosaic.nc\
                          C192_mosaic_tile1XC192_mosaic_tile1.cdl C192_mosaic_tile1Xocean_mosaic_tile1.cdl C192_mosaic_tile2XC192_mosaic_tile2.cdl C192_mosaic_tile2Xocean_mosaic_tile1.cdl\
                          C192_mosaic_tile3XC192_mosaic_tile3.cdl C192_mosaic_tile3Xocean_mosaic_tile1.cdl C192_mosaic_tile4XC192_mosaic_tile4.cdl C192_mosaic_tile4Xocean_mosaic_tile1.cdl\
                          C192_mosaic_tile5XC192_mosaic_tile5.cdl C192_mosaic_tile5Xocean_mosaic_tile1.cdl C192_mosaic_tile6XC192_mosaic_tile6.cdl C192_mosaic_tile6Xocean_mosaic_tile1.cdl\
                          land_mask_tile1.cdl land_mask_tile2.cdl land_mask_tile3.cdl land_mask_tile4.cdl land_mask_tile5.cdl land_mask_tile6.cdl\
                          mosaic.cdl ocean_mask.cdl,mosaic_c192.720x576/$f)
ocean_mosaic: $(OCN_MOSAIC) basin_codes.nc
c96_mosaic: $(C96_MOSAIC)
c192_mosaic: $(C192_MOSAIC)

$(filter-out mosaic_ocean/grid_spec.nc mosaic_ocean/ocean_mosaic.nc,$(OCN_MOSAIC:.cdl=.nc)): mosaic_ocean/grid_spec.nc
$(filter-out mosaic_c96/mosaic.nc,$(C96_MOSAIC:.cdl=.nc)): mosaic_c96/mosaic.nc
mosaic_c96/mosaic.nc: mosaic_ocean/ocean_mosaic.nc ocean_topog.nc $(FRE_NCTOOLS)/make_coupler_mosaic/make_coupler_mosaic_parallel
	mkdir -p $(@D)
	(cd $(@D); ln -sf ../ocean_hgrid.nc ../ocean_topog.nc .)
	(cd $(@D); ln -sf ../mosaic_ocean/ocean_mosaic.nc .)
	(cd $(@D); tar xf /archive/cjg/awg/input/grid/C96_CM2G_grid.tar C96_grid.\* C96_mosaic.nc)
	(cd $(@D); time mpirun -np $(NP) ../$(FRE_NCTOOLS)/make_coupler_mosaic/make_coupler_mosaic_parallel --reproduce_siena --atmos_mosaic C96_mosaic.nc --ocean_mosaic ocean_mosaic.nc --mosaic_name mosaic --ocean_topog ocean_topog.nc)

$(filter-out mosaic_c192/mosaic.nc,$(C192_MOSAIC:.cdl=.nc)): mosaic_c192/mosaic.nc
mosaic_c192/mosaic.nc: mosaic_ocean/ocean_mosaic.nc ocean_topog.nc $(FRE_NCTOOLS)/make_coupler_mosaic/make_coupler_mosaic_parallel
	mkdir -p $(@D)
	(cd $(@D); ln -sf ../ocean_hgrid.nc ../ocean_topog.nc .)
	(cd $(@D); ln -sf ../mosaic_ocean/ocean_mosaic.nc .)
	(cd $(@D); tar xf /archive/cjg/awg/input/grid/c192_CM2_grid_20130423.tar C192_grid.\* C192_mosaic.nc)
	(cd $(@D); time mpirun -np $(NP) ../$(FRE_NCTOOLS)/make_coupler_mosaic/make_coupler_mosaic_parallel --reproduce_siena --atmos_mosaic C192_mosaic.nc --ocean_mosaic ocean_mosaic.nc --mosaic_name mosaic --ocean_topog ocean_topog.nc)

%.cdl: %.nc
	ncdump $< | egrep -v 'code_version|history' > $@

clean:
	-rm -rf fre_nctools local MIDAS OM4_05_* DATA mosaic_* preprocessing_geothermal pytools
	-rm -f *.nc *grid.nc salt*.nc seaw*.nc tidal_*.nc WOA*.nc geoth*.nc *topog*.nc PHC*.nc basin*.nc logfile* input.nml runoff*.nc

md5sums.txt: ocean_hgrid.nc antarctic_spherical_supergrid.nc mercator_supergrid.nc ncap_supergrid.nc supergrid.nc interpolated_topog.nc mercator_topog_gebco.nc ncap_topog_gebco.nc ncap_topog.nc so_topog_gebco.nc ocean_topog.nc $(OCN_MOSAIC) $(C96_MOSAIC) $(C192_MOSAIC) basin_codes.nc salt_restore.nc seawifs_1998-2006_smoothed_2X.nc tidal_amplitude.nc WOA05_ptemp_salt_monthly.nc WOA05_ptemp_salt_annual.nc geothermal_davies2013_v1.nc mosaic_ocean/runoff.daitren.iaf.v2011.02.10.nc mosaic_ocean/runoff.daitren.clim.v2011.02.10.nc
	echo Grids > $@
	md5sum *supergrid.nc ocean_hgrid.nc >> $@
	echo >> $@
	echo Topography >> $@
	md5sum *topog*.nc >> $@
	md5sum basin_codes.nc >> $@
	echo >> $@
	echo Mosaics >> $@
	md5sum $(OCN_MOSAIC) >> $@
	md5sum $(C96_MOSAIC) >> $@
	md5sum $(C192_MOSAIC) >> $@
	echo >> $@
	echo Data >> $@
	md5sum salt_restore.nc seawifs_1998-2006_smoothed_2X.nc tidal_amplitude.nc >> $@
	md5sum geothermal_davies2013_v1.nc >> $@
	echo >> $@
	echo Obs >> $@
	md5sum WOA05_ptemp_salt_{monthly,annual}.nc >> $@
