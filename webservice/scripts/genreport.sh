#!/bin/bash
###############################################################################
source ./log.sh

#RESULTSFILE=genreports.csv
RESULTSFILE=$1
#OUTPUTFILE=report.org
OUTPUTFILE=$2
BASICRESULT=$3
ORIGURL=$4
DATESTAMP=$5
MAXLINES=30
RULESET=$6

URLDATESTAMP=$(echo $DATESTAMP | sed -e 's^:^%3A^g')
TERRORS=`egrep ",\"error\"," ${RESULTSFILE} | wc -l`
TWARNINGS=`egrep ",\"warning\"," ${RESULTSFILE} | wc -l`
PID=$$

###############################################################################

genstatistics() {
    echo "|" "| Number |"
    echo "|" errors "|" $TERRORS "|"
    echo "|" warnings "|" $TWARNINGS "|"
}

###############################################################################

includestats() {
    # change the out separator for org-mode
    cat $BASICRESULT \
	| tr -d "\"" \
	| while IFS=, read -r cl ins; do
	if [ "$cl" == "Class" ] ; then
	    echo "| Class | Instances | Errors | Warnings |"
	else
	    errors=$(get_number "error" $cl)
	    warnings=$(get_number "warning" $cl)
	    echo "|" $cl "|" $ins "|" $errors "|" $warnings "|"
	fi
    done
    echo "| | |" $TERRORS "|" $TWARNINGS "|"
}

###############################################################################

get_number() {
    count=$(egrep ",\"$1\"," ${RESULTSFILE} \
		   | tr -d "\"" \
		   | awk -F, -v class=$2 '{gsub(/\ /,"",$1); if (index(class,$1) != 0) { print $1;}}' \
		   | wc -l)
    log get_number ${RESULTSFILE} $1 $2 $count
    echo $count
}

###############################################################################
# Recover the instances

get_instances() { # Label
    l=$(cat $BASICRESULT | awk -F, -v label=$1 '$1 ~ label {print $2;}')
    if [ "$l" == "" ]; then
	out="with no instances"
    else
	if [ "$l" == "1" ]; then
	    out="for the 1 instance"
	else
	    out="across the $l instances"
	fi
    fi;
    echo $out
}

###############################################################################
# simply could the errors/warnings found in the files passed into the command

get_flag() {
    awk -F, 'BEGIN{error=0; warning=0;} $3 == "error" {error++ } $3 == "warning" {warning++} END { print error","warning; }' $1
}

###############################################################################
# Output a single section (labels and counts coming from the outside)

add_properties() {
    local IFILENAME=$1
    local LABEL=$2
    local NNR=$3
    local TOTAL=$4
    local AUX=$5
    if [ "${NNR}" != "0" ]; then
	echo "  :PROPERTIES:"
	echo "  :HTML_CONTAINER_CLASS: ${LABEL} ${AUX}"
	echo "  :END:"
	echo ""
	AUXLINK=""
	if [ "${AUX}" != "" ] ; then
	    AUXLINK="[[https://data.vlaanderen.be/doc/applicatieprofiel/DCAT-AP-VL/][DCAT-AP VL]]"
	    echo "#+ATTR_HTML: :target _blank :class help-links"
	    echo "${AUXLINK}"
	elif [ "${LABEL}" == "errors" ] ; then 
	    REDLINK="[[https://joinup.ec.europa.eu/release/dcat-ap/121][DCAT-AP]]"
	    echo "#+ATTR_HTML: :target _blank :class help-links"
	    echo "${REDLINK}"
	else
	    true
	fi
	# The $i needs fixing here (misuse of the calling form)
	echo "#+ATTR_HTML: :target _blank :class help-links"
	echo "[[https://github.com/tenforce/vodap-dcatap-validation/blob/master/webservice/rules/dcat/rule-$i.rq][Sparql]]"
	
	echo ""
    fi
}

add_properties_simple() {
    local IFILENAME=$1
    local LABEL=$2
    local NNR=$3
    local TOTAL=$4
    if [ "${NNR}" != "0" ]; then
	echo "  :PROPERTIES:"
	echo "  :HTML_CONTAINER_CLASS: ${LABEL}"
	echo "  :END:"
	echo ""
	# The $i needs fixing here (misuse of the calling form)
	echo "#+ATTR_HTML: :target _blank :class help-links"
	genruleset_ruleurl $i
	
	echo ""
    fi
}
    
output_form() {
    local IFILENAME=$1
    local LABEL=$2
    local NNR=$3
    local TOTAL=$4

    if [ "${NNR}" != "0" ]; then
	# create a list of groups (must be exact match for the following operation)
	awk -F, '{print $1","$2","$3","$4};' ${IFILENAME}\
	    | sort -u -\
	    | while read line ; do
	    # for each grouping dump the corresponding errors and warnings as a table
            echo $line | awk -F, '{ print "   " $1 " - " $3 " -  " $4 ; }'
	    echo "     | Description | Instance | "
	    echo "     |-------------+----------| "
	    cat ${IFILENAME} \
		| egrep "$line" \
		| awk -F, '{ print "    |" $5 "|" $6 "|"; }'
	done
    fi
}

###############################################################################
create_label() {
    errors=""
    warnings=""
    padding=""
    instances=$(get_instances $5)
    first=""
    if [ "$1" == "${MAXLINES}" -o "$3" == "${MAXLINES}" ] ; then
	first="first "
    fi
    if [ "$1" != "0" ] ; then
	errors=$(echo "errors: $first$1")
    fi
    if [ "$3" != "0" ] ; then
	warnings=$(echo "warnings: $first$3")
    fi
    if [ "$1" != "0" -a "$3" != "0" ] ; then
	padding=","
    fi    
    echo "(" ${errors} ${padding} ${warnings} ${instances} ")"
}

###############################################################################
genruleresults() {
  for i in {0..500} #nb is number of the rule
  do
    IFILENAME=/tmp/items${PID}.txt
    egrep ",$i," ${RESULTSFILE} | tr -d "\"" | head -${MAXLINES} > ${IFILENAME}
    if [ ! -z "$(cat ${IFILENAME})" ] ; then
	msg=$(get_flag ${IFILENAME})
	nrerrors=$(echo $msg | cut -d, -f1)
	nrwarnings=$(echo $msg | cut -d, -f2)
	class=$(cat ${IFILENAME} | cut -d, -f1 | uniq) ## was "Agent" XXX needs recovering from the IFILENAME list
	auxilary=$(cat ${IFILENAME} | cut -d, -f9 | uniq)
	echo "** Rule $i $(create_label ${nrerrors} ${TERRORS} ${nrwarnings} ${TWARNINGS} ${class})"
	add_properties_simple ${IFILENAME} "errors" "${nrerrors}" ${TERRORS} ${auxilary}
	add_properties_simple ${IFILENAME} "warnings" "${nrwarnings}" ${TWARNINGS} ${auxilary}
	output_form ${IFILENAME} "errors" "${nrerrors}" ${TERRORS}
	output_form ${IFILENAME} "warnings" "${nrwarnings}" ${TWARNINGS}
    fi
    rm -rf ${IFILENAME}
  done
}
###############################################################################
genruleset() {
   case $RULESET in
     1) echo "The used ruleset is DCAT-AP-VL obligations and recommendations."
     ;;
     2) echo "The used ruleset is DCAT-AP mandatory and recommended properties."
     ;;
     *)
     ;;
   esac
}

genruleset_ruleurl() {
   case $RULESET in
     1) 
	echo "[[https://github.com/tenforce/vodap-dcatap-validation/raw/master/webservice/rules/dcatapvl_mandatory/rule-$1.rq][Sparql]]"
     ;;
     2) 
	echo "[[https://github.com/tenforce/vodap-dcatap-validation/raw/master/webservice/rules/dcatapvl_recommended/rule-$1.rq][Sparql]]"
     ;;
     *)
     ;;
   esac
}

###############################################################################
genreport() {
    echo "#+TITLE: DCAT Validation Report"
    echo "#+SUBTITLE: ${dcat_url}"
    echo "#+DATE: `date`"
    echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"https://www.pirilampo.org/styles/readtheorg/css/htmlize.css\"/>"
    echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"https://www.pirilampo.org/styles/readtheorg/css/readtheorg.css\"/>"
    echo "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"/ENV_VALIDATOR_LOCATION_PATH/css/highlight.css\" />"   
    echo "#+HTML_HEAD: <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>"
    echo "#+HTML_HEAD: <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>"
    echo "#+HTML_HEAD: <script type=\"text/javascript\" src=\"https://www.pirilampo.org/styles/lib/js/jquery.stickytableheaders.min.js\"></script>"
    echo "* Introduction"
    echo "Original source link: $ORIGURL"
    genruleset
    echo "** Processing File Links"
    echo "The following reports and log files are being created during the validation process. "
    echo "Only if the RDF parsing is successfull (see first report) the content validation whether the data is aligned with the DCAT-AP-VL profile."
    echo "  - [[file:feed.$URLDATESTAMP.report][~feed.$DATESTAMP.report - the download & RDF parsing report~]]"
    echo "  - [[file:feed.$URLDATESTAMP][~feed.$DATESTAMP - the downloaded RDF file in turtle~]]"
    echo "  - [[file:load_feed.log][~load_feed.log - loading of the DCAT feed into the RDF store~]]"
    echo "  - [[file:basic.csv][~basic.csv - csv output of the statistics~]]"
    echo "  - [[file:vodapreport.csv][~CSV Detail - csv output of the validation rules~]]"
    if [ -f "publishers.csv" ]
    then
       echo "  - [[file:publishers.csv][~publishers.csv - the list of publishers in the catalog~]]"
    fi
    echo "** Overview"
    includestats
    # merged into overview table
    # echo "** Statistics"
    # genstatistics
    echo "* Individual Rule Results"
    genruleresults
}

genreport > $OUTPUTFILE

###############################################################################
###############################################################################
