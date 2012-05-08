# Note: This bash library is a toy client library. Some/all features may be missing or not working. The library also leaks your key and secret, which is a problem. Do not use this if you are concerned with the security of your data for the configured (key/secret) database

# Uncomment and provide values, or set elsewhere
#TEMPODB_API_KEY=yourkey
#TEMPODB_API_SECRET=yoursecret

#TEMPODB_VERBOSE=true

# List available series
function tempo-list-series {
  tempo-make-request "/series"
}

# Create a new series.
# Args:
# - name (key) of the series [OPTIONAL]
function tempo-create-series {
  tempo-make-request "/series" "{\"key\": \"$1\"}"
}

# Write a record to a series
# Args:
# - id of series
# - value
# Note: values get the current timestamp
function tempo-write-to-id {
  timestamp=$(date "+%Y-%m-%dT%H:%M:%S.000%z")
  tempo-make-request "/series/id/$1/data/" "[{\"t\": \"$timestamp\", \"v\": \"$2\"}"
}

# Write a record to a series
# Args:
# - name (key) of series
# - value
# Note: values get the current timestamp
function tempo-write-to-key {
  timestamp=$(date "+%Y-%m-%dT%H:%M:%S.000%z")
  tempo-make-request "/series/key/$1/data/" "[{\"t\": \"$timestamp\", \"v\": \"$2\"}"
}

# Read the last <n> minutes of a series
# Args:
# - id of series
# - number of minutes to look back
function tempo-read-from-id {
  past_timestamp=$(date -v-$2M "+%Y-%m-%dT%H:%M:%S.000%z")
  current_timestamp=$(date "+%Y-%m-%dT%H:%M:%S.000%z")
  tempo-make-request "/series/id/$1/data/?start=$past_timestamp&end=$current_timestamp"
}

# Read the last <n> minutes of a series
# Args:
# - key of series
# - number of minutes to look back
function tempo-read-from-key {
  past_timestamp=$(date -v-$2M "+%Y-%m-%dT%H:%M:%S.000%z")
  current_timestamp=$(date "+%Y-%m-%dT%H:%M:%S.000%z")
  tempo-make-request "/series/key/$1/data/?start=$past_timestamp&end=$current_timestamp"
}

function tempo-make-request {
  curl_opts="-g -u $TEMPODB_API_KEY:$TEMPODB_API_SECRET"
  if [ "$2" ]
  then
    data=$2
  else
    data=
  fi

  if $TEMPODB_VERBOSE
  then
    curl_opts="$curl_opts -D - -v"
  fi

  if [ "$data" ]
  then
    echo $data > /tmp/tempodb.data
    curl $curl_opts -d @/tmp/tempodb.data https://api.tempo-db.com/v1$1
  else
    curl $curl_opts https://api.tempo-db.com/v1$1
  fi

  echo
}

