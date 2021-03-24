#!/usr/bin/env bash
# Copyright 2021  Seasalt AI, Inc (Author: Guoguo Chen)


while true; do
  [ -z "${1:-}" ] && break;  # break if there are no arguments
  case "$1" in
    --*) name=`echo "$1" | sed s/^--// | sed s/-/_/g`;
      eval '[ -z "${'$name'+xxx}" ]' &&\
        echo "$0: invalid option $1" 1>&2 && exit 1;

      oldval="`eval echo \\$$name`";
      if [ "$oldval" == "true" ] || [ "$oldval" == "false" ]; then
        was_bool=true;
      else
        was_bool=false;
      fi
      eval $name=\"$2\";
      if $was_bool && [[ "$2" != "true" && "$2" != "false" ]]; then
        echo "$0: expected \"true\" or \"false\": $1 $2" 1>&2
        exit 1;
      fi
      shift 2;
      ;;
  *) break;
  esac
done

true;
