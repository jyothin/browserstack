#!/bin/bash
SERVER=http://localhost
PORT=4567
#URL_PATH=

RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

TEST_OUT="./test.out"
TEST_OUT_2="./test_2.out"

WAIT_UNBLOCK_KEY_TIMEOUT=20
WAIT_DEAD_KEY_TIMEOUT=45

# Remove temporary files
if [ -f $TEST_OUT ]; then
    rm -rf $TEST_OUT
fi
if [ -f $TEST_OUT_2 ]; then
    rm -rf $TEST_OUT_2
fi

#Helper function to validate status codes
function validateStatusCode {
    if [ $1 != $2 ]
    then
        echo -e "${RED}Fail${NO_COLOR}: $1"
    else
        echo -e "${GREEN}Pass${NO_COLOR}"
    fi
}

# Start tests

echo "Test end points"
# Generate key
echo "Running Test 1 (POST "/"): curl -s -o /dev/null -X POST $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
         $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 201

# Get key
echo "Running Test 2 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200

# Unblock key
while IFS='' read -r line || [[ -n "$line" ]]; do
    ID="$line"
    echo "Running Test 3 (GET "/:id"): curl -s -o /dev/null -X GET $SERVER:$PORT/$ID"
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET \
                    $SERVER:$PORT/$ID)
    validateStatusCode $STATUS_CODE 200
done < $TEST_OUT

# Delete key
while IFS='' read -r line || [[ -n "$line" ]]; do
    ID="$line"
    echo "Running Test 4 (DELETE "/:id"): curl -s -o /dev/null -X DELETE $SERVER:$PORT/$ID"
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
                    $SERVER:$PORT/$ID)
    validateStatusCode $STATUS_CODE 200
done < $TEST_OUT

# Keepalive key
while IFS='' read -r line || [[ -n "$line" ]]; do
    ID="$line"
    echo "Running Test 5 (PUT "/:id"): curl -s -o /dev/null -X PUT $SERVER:$PORT/$ID"
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
                    $SERVER:$PORT/$ID)
    validateStatusCode $STATUS_CODE 404
done < $TEST_OUT

read -p prompt

echo
echo "Test key dead timeout"
# Generate key
echo "Running Test 6 (POST "/"): curl -s -o /dev/null -X POST $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
         $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 201

# Get key
echo "Running Test 7 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200

echo "Sleeping for $WAIT_DEAD_KEY_TIMEOUT"
sleep $WAIT_DEAD_KEY_TIMEOUT

# Delete key
while IFS='' read -r line || [[ -n "$line" ]]; do
    ID="$line"
    echo "Running Test 8 (DELETE "/:id"): curl -s -o /dev/null -X DELETE $SERVER:$PORT/$ID"
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
                    $SERVER:$PORT/$ID)
    validateStatusCode $STATUS_CODE 400
done < $TEST_OUT

read -p prompt

echo
echo "Test key exhausted"
# Generate key
echo "Running Test 9 (POST "/"): curl -s -o /dev/null -X POST $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
         $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 201

# Get key
echo "Running Test 10 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200

# Get key
echo "Running Test 11 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 404

read -p prompt

echo
echo "Test keys unblocked"
# Generate key
echo "Running Test 9 (POST "/"): curl -s -o /dev/null -X POST $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
         $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 201

# Get key
echo "Running Test 10 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200

sleep 2

# Unblock key
while IFS='' read -r line || [[ -n "$line" ]]; do
    ID="$line"
    echo "Running Test 11 (GET "/:id"): curl -s -o /dev/null -X GET $SERVER:$PORT/$ID"
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET \
                    $SERVER:$PORT/$ID)
    validateStatusCode $STATUS_CODE 200
done < $TEST_OUT

sleep 3

# Get key
echo "Running Test 12 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT_2 -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200
NONE=$(comm -3 $TEST_OUT $TEST_OUT_2)
if [ ! -z $NONE ]; then
    validateStatusCode 0 1
fi

read -p prompt

echo
echo "Test keys unblocked after timeout"
# Generate key
echo "Running Test 13 (POST "/"): curl -s -o /dev/null -X POST $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
         $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 201

# Get key
echo "Running Test 14 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200

echo "Sleeping for $WAIT_UNBLOCK_KEY_TIMEOUT"
sleep $WAIT_UNBLOCK_KEY_TIMEOUT

# Get key
echo "Running Test 15 (GET "/"): curl -s -o /dev/null -X GET $SERVER:$PORT/"
STATUS_CODE=$(curl -s -o $TEST_OUT_2 -w "%{http_code}" -H "Accept:application/json" -X GET \
                $SERVER:$PORT/)
validateStatusCode $STATUS_CODE 200
NONE=$(comm -3 $TEST_OUT $TEST_OUT_2)
if [ ! -z $NONE ]; then
    validateStatusCode 0 1
fi

