#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
SALON_NAME="ANDY'S"

echo -e "\n~~~~~ $SALON_NAME SALON ~~~~~\n"

echo -e "Welcome. How can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # List available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # get input for selected service
  read SERVICE_ID_SELECTED

  # validate input before querying
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # display error message in case input is not valid
    MAIN_MENU "This is not a valid number."

  else
    SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SELECTED_SERVICE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      BOOK_A_SERVICE "$SERVICE_ID_SELECTED" "$SELECTED_SERVICE"
    fi
  fi
}


BOOK_A_SERVICE() {
  # get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # # if not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # insert a new customer
    echo -e "\nI don't have record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get customer id
  CUSTOMER_ID_NO=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $(echo $SELECTED_SERVICE | sed -r 's/^ *| *$//g'), $CUSTOMER_NAME?"
  read SERVICE_TIME
  BOOK_APPOINTMENT "$SERVICE_ID_SELECTED" "$CUSTOMER_ID_NO" "$SERVICE_TIME" "$CUSTOMER_NAME"
}


BOOK_APPOINTMENT(){
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($1, $2, '$3')")
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$1")

  if [[ $APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $3, $(echo $4 | sed -r 's/^ *| *$//g')."
  fi
}


MAIN_MENU
