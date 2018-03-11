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

# convert the tract shapefile into GeoJSON
data/counties.json: data/unzipped
	npx --package shapefile shp2json $</$(shp_file).shp --out $@

# unzip the downloaded archive
data/unzipped: data/$(state_name).zip
	unzip $< -d $@
	touch $@/$(shp_file).shp

# download state census tract shapefile from US Census Bureau website
data/$(state_name).zip:
	mkdir $(dir $@)
	curl $(url) --output $@
