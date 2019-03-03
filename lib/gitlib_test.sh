#!/bin/bash
#
# gitlib.sh unit tests
#
source $(dirname $(readlink -ne $BASH_SOURCE))/common.sh
source $TOOL_LIB_PATH/gitlib.sh
source $TOOL_LIB_PATH/releaselib.sh

readonly TESTDATA="$( cd "$(dirname "$0")" && pwd )/testdata"

TEST_ver_regex() {
  echo "Testing VER_REGEX:"
  echo

  # Ex. v1.5.0-alpha.2.435+8c67d08e3a535d
  local DOTZERO="v1.4.0"
  local SHORT="v1.4.5"
  local LONG="v1.4.5-alpha.0"
  local SHA="v1.4.5-alpha.0.435+8c67d08e3a535d"
  local RC="v1.4.5-rc.1"

  printf "%-40s" "$DOTZERO : "
  if [[ $DOTZERO =~ ${VER_REGEX[dotzero]} ]]; then
    echo "$PASSED Value: ${BASH_REMATCH[0]}"
  else
    echo "$FAILED"
  fi

  printf "%-40s" "$SHORT : "
  if [[ $SHORT =~ ${VER_REGEX[release]} ]]; then
    echo "$PASSED Value: ${BASH_REMATCH[0]}"
  else
    echo "$FAILED"
  fi

  printf "%-40s" "$LONG : "
  if [[ $LONG =~ ${VER_REGEX[release]} ]]; then
    echo "$PASSED Value: ${BASH_REMATCH[0]}"
  else
    echo "$FAILED"
  fi

  printf "%-40s" "$SHA : "
  if [[ $SHA =~ ${VER_REGEX[release]}\.${VER_REGEX[build]} ]]; then
    echo "$PASSED Value: ${BASH_REMATCH[0]}"
  else
    echo "$FAILED"
  fi

  printf "%-40s" "$RC : "
  if [[ $RC =~ ${VER_REGEX[release]} ]]; then
    echo "$PASSED Value: ${BASH_REMATCH[0]}"
  else
    echo "$FAILED"
  fi
}

TEST_create_issue() {
  echo "Testing gitlib::create_issue"
  echo

  local repo='some/repo'
  local title='the title'
  local body='and the body with some "strange" stuff
          and even new lines'

  # shellcheck disable=SC2034
  local GHCURL='echo'

  assertEqualContent \
    <( gitlib::create_issue "$repo" "$title" "$body" ) \
    "${TESTDATA}/gitlib/create_issue.txt" \
    'creating an issue'

  assertEqualContent \
    <( gitlib::create_issue "$repo" "$title" "$body" 12345 ) \
    "${TESTDATA}/gitlib/create_issue_milestone.txt" \
    'creating an issue with milestone'
}

assertEqualContent() {
  local actual_file="$1"
  local expected_file="$2"
  local message="${3:-files do not match content}"
  local rc=0

  diff="$( diff -Naur "$expected_file" "$actual_file" )" || rc=$?

  if [ "$rc" -ne 0 ]; then
    echo "${FAILED}: ${message}"
    echo "${diff}"
  else
    echo "${PASSED}: ${message}"
  fi

  return $rc
}

main() {
  local tests=( "$@" )
  local t

  if [ "$#" -lt 1 ]
  then
    # if no functions are given as arguments, find all functions
    # named 'TEST_...' and run those
    mapfile tests <<< "$( declare -F | awk '$3 ~ "^TEST_" { print $3 }' )"
  fi

  for t in "${tests[@]}"
  do
    $t ; echo
  done
}

main "$@"
