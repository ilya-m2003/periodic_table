if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
  delete=$($PSQL "ALTER TABLE properties DROP COLUMN type")
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]]
  then
    ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$1'")
    if [[ -z $ELEMENT_NAME ]]
    then
      ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE name='$1'")
      ELEMENT_NAME=${ELEMENT_NAME:1}
    else
      ELEMENT_NAME=${ELEMENT_NAME:1}
    fi
  else
    ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number='$1'")
    ELEMENT_NAME=${ELEMENT_NAME:1}
  fi
  if [[ -z $ELEMENT_NAME ]]
  then
    echo "I could not find that element in the database."
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ELEMENT_NAME'")
    ATOMIC_NUMBER=$( printf '%d' $ATOMIC_NUMBER )
    ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number WHERE name='$ELEMENT_NAME'")
    ATOMIC_MASS=$( printf '%s' $ATOMIC_MASS )
    MELTING_POINT_CELSIUS=$($PSQL "SELECT melting_point_celsius FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number WHERE name='$ELEMENT_NAME'")
    MELTING_POINT_CELSIUS=$( printf '%s' $MELTING_POINT_CELSIUS )
    BOILING_POINT_CELSIUS=$($PSQL "SELECT boiling_point_celsius FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number WHERE name='$ELEMENT_NAME'")
    BOILING_POINT_CELSIUS=$( printf '%s' $BOILING_POINT_CELSIUS )
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$ELEMENT_NAME'")
    SYMBOL=${SYMBOL:1}
    TYPE=$($PSQL "SELECT types.type FROM properties FULL JOIN types ON properties.type_id = types.type_id WHERE atomic_number=$ATOMIC_NUMBER")
    TYPE=${TYPE:1}
    echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
  delete=$($PSQL "DELETE FROM properties WHERE atomic_number=1000")
  delete=$($PSQL "DELETE FROM elements WHERE atomic_number=1000")
fi