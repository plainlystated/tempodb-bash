# Note: This bash library is a toy client library. Some/all features may be missing or not working. The library also leaks your key and secret, which is a problem. Do not use this if you are concerned with the security of your data for the configured (key/secret) database

# Uncomment and provide values, or set elsewhere
#TEMPODB_API_KEY=yourkey
#TEMPODB_API_SECRET=yoursecret

TEMPODB_VERBOSE=false

function tempo-list-series {
  tempo-make-request "/series"
}

function tempo-create-series {
  tempo-make-request "/series" "{\"key\": \"$1\"}"
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
    curl_opts="$curl_opts -D -"
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

