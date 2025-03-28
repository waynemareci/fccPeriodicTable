#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"
unset ATOMIC_NUMBER
unset SYMBOL
unset NAME

PROCESS_INPUT(){
  echo "in process_input(); processing $1"
  if [[ ! -z $ATOMIC_NUMBER ]]
  then
    RESPONSE=$($PSQL "SELECT atomic_number,symbol,name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    echo "Here's the atomic_number response: $RESPONSE"
  elif [[ ! -z $NAME ]]; then
    NAME_FORMATTED=$(echo $NAME | sed -E 's/^ *| *$//g')
    RESPONSE=$($PSQL "SELECT atomic_number,symbol,name FROM elements WHERE name='$NAME_FORMATTED'")
    echo "Here's the name response: $RESPONSE"
  elif [[ ! -z $SYMBOL ]]; then
    SYMBOL_FORMATTED=$(echo $SYMBOL | sed -E 's/^ *| *$//g')
    RESPONSE=$($PSQL "SELECT atomic_number,symbol,name FROM elements WHERE symbol='$SYMBOL_FORMATTED'")
    echo "Here's the symbol response: $RESPONSE"
  else
    echo "serious error - you shouldn't be here"
    exit  
  fi
  echo "$RESPONSE" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL)." 
  done
  }

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi
re='^[0-9]+$'
if [[ $1 =~ $re ]]
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1") 
  if  [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
    exit
  else
    PROCESS_INPUT $ATOMIC_NUMBER
    exit
  fi
else
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
    if [[ ! -z $SYMBOL ]]
    then

     PROCESS_INPUT $SYMBOL
     exit
    else
     NAME=$($PSQL "SELECT name FROM elements WHERE name='$1'")
     if [[ ! -z $NAME ]]
     then
      PROCESS_INPUT $NAME
      exit
     else
        echo "I could not find that element in the database."
        exit
    fi
  fi
fi

