#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

PROCESS_INPUT(){
  echo "processing $1"
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi
re='^[0-9]+$'
if [[ $1 =~ $re ]]
then
  echo "$1 is a number"
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1") 

  if [[ -z ATOMIC_NUMBER ]]
  then
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol=$1")
    if [[ -z SYMBOL ]]
    then
     NAME=$($PSQL "SELECT name FROM elements WHERE name=$1")
     if [[ -z $NAME ]]
     then
      echo "I could not find that element in the database."
      exit 
     fi
    fi
  else
    echo "found atomic number $1"
    PROCESS_INPUT $1
    exit
  fi
fi
echo "I could not find that element in the database."
exit

