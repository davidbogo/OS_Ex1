#!/bin/bash
#David Bogoslavsky

DIRECTORY=""
RECURSIVE=""
WORD=""

process_cl_params()
{
  ALL_PARAMS_OK="1"
  DIRECTORY="$1"
  WORD="$2"
  shift
  shift
  while [ "$1" != "" ]
  do
    case $1 in
      -r)
        RECURSIVE="-r"
        ;;
      *)
        echo -e "$1: unrecognized parameter"
        ALL_PARAMS_OK="0"
        ;;
    esac
    shift
  done
  return $ALL_PARAMS_OK
}

get_first_element()
{
  echo $1
}

compile_files()
{
  while [ "$1" != "" ]
  do
    FILENAME_PARTS=`echo $1 | tr '.' ' '`
    OUTPUT_NAME=$(get_first_element $FILENAME_PARTS)
    OUTPUT_NAME=$OUTPUT_NAME".out"
    gcc -c -o $OUTPUT_NAME $1
    shift
  done
}

process_cl_params "$@"
cd $DIRECTORY
if [ "$RECURSIVE" = "-r" ]
then
find . -name "*.out" -type f -delete
fi
if [ "$RECURSIVE" = "" ]
then
rm *.out $RECURSIVE
fi

FILE_LIST=`grep -li $RECURSIVE --include \*.c $WORD $DIRECTORY | tr '\n' ' '`
compile_files $FILE_LIST


