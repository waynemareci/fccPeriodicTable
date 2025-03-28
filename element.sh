#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"
unset ATOMIC_NUMBER
unset SYMBOL
unset NAME

PROCESS_INPUT(){
  if [[ ! -z $ATOMIC_NUMBER ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
  elif [[ ! -z $NAME ]]; then
    NAME_FORMATTED=$(echo $NAME | sed -E 's/^ *| *$//g')
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME_FORMATTED'")
    #echo "Here's the name response: $RESPONSE"
  elif [[ ! -z $SYMBOL ]]; then
    SYMBOL_FORMATTED=$(echo $SYMBOL | sed -E 's/^ *| *$//g')
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL_FORMATTED'")
  else
    echo "serious error - you shouldn't be here"
    exit  
  fi
  PROPERTIES_RESPONSE=$($PSQL "select elements.atomic_number,symbol,name,type,atomic_mass,melting_point_celsius,boiling_point_celsius from elements full join properties on elements.atomic_number=properties.atomic_number full join types on properties.type_id = types.type_id WHERE elements.atomic_number=$ATOMIC_NUMBER")
  echo "$PROPERTIES_RESPONSE" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR TYPE BAR MASS BAR MELT BAR BOIL
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius." 
 
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

