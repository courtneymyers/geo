################################################################################
# $< = prerequisites list
# $@ = target
################################################################################

# https://www.census.gov/geo/maps-data/data/cbf/cbf_tracts.html
year := 2016
state_id := 51
state_name := virginia
shp_file := cb_$(year)_$(state_id)_tract_500k
url := https://www2.census.gov/geo/tiger/GENZ$(year)/shp/$(shp_file).zip

# convert projected GeoJSON to SVG file
data/$(state_name).svg: data/$(state_name)_projected.json
	npx --package d3-geo-projection \
	geo2svg -w 960 -h 960 < $< > $@

# apply a geometric projection to the GeoJSON data
# (https://github.com/veltman/d3-stateplane#nad83--virginia-south-epsg32147)
data/$(state_name)_projected.json: data/$(state_name).json
	npx --package d3-geo-projection \
	geoproject \
	'd3.geoConicConformal() \
	.parallels([36 + 46 / 60, 37 + 58 / 60]) \
	.rotate([78 + 30 / 60, 0]) \
	.fitSize([960, 960], d)' \
	< $< > $@

# convert the tract shapefile into GeoJSON
data/$(state_name).json: data/unzipped
	npx --package shapefile \
	shp2json $</$(shp_file).shp --out $@

# unzip the downloaded archive
data/unzipped: data/$(state_name).zip
	unzip $< -d $@
	touch $@/$(shp_file).shp

# download state census tract shapefile from US Census Bureau website
data/$(state_name).zip:
	mkdir $(dir $@)
	curl $(url) --output $@
