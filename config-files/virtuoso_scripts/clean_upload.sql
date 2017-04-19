# Virtuoso7 cleanup script

# first commit all outstanding
checkpoint;

# empty load list
delete from DB.DBA.LOAD_LIST ;

log_enable (2);

# remove old data
sparql drop silent graph <http://data.vlaanderen.be/id/dataset/vodap>;
sparql drop silent graph <http://data.vlaanderen.be/id/dataset/default>;


# schedule everything in the directory to be loaded
#  the last argument is a default value in case the .graph files are not present
ld_dir('/data/dumps', '*.ttl.gz', 'http://data.vlaanderen.be/id/dataset/default');
ld_dir('/data/dumps', '*.ttl', 'http://data.vlaanderen.be/id/dataset/default');
ld_dir('/data/dumps', '*.nt', 'http://data.vlaanderen.be/id/dataset/default');

# start loading
rdf_loader_run();

checkpoint;
