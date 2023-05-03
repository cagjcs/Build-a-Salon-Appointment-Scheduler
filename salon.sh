#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nSalon Appointment\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
	
  echo -e "\nBienvenido, ¿en que podemos ayudarte?:\n"

	# Consulta de servicios
	AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # pintar los servicios
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
   # preguntar por el servicio deseado
  read SERVICE_ID_SELECTED

  # si no es un numero
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # volver al menu principal
    MAIN_MENU "No es un numero de servicio valido."
  else
    # comprobar si existe el servicio
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # si no existe el servicio
    if [[ -z $SERVICE_NAME ]]
    then
      # volver al menu principal
      MAIN_MENU "No existe el servicio solicitado."
    else
      # pedir el numero de telefono
      echo -e "\n¿Cual es su numero de teléfono?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # Si no está creado el cliente
      if [[ -z $CUSTOMER_NAME ]]
      then
        # solicitar el nombre del cliente
        echo -e "\n¿Cual es su nombre?"
        read CUSTOMER_NAME

        # insertar el cliente
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
      fi

      # pedir la hora de la cita
      echo -e "\n¿A que hora solicita el servicio?"
      read SERVICE_TIME

      # obtener customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # insertar la cita
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # volver al menu principal
      echo -e "\n\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $(echo $SERVICE_TIME | sed 's/ //g'), $(echo $CUSTOMER_NAME | sed 's/ //g')."
      EXIT
    fi
  fi	
}

EXIT() {
  echo -e "\nGracias por usar nuestro servicio.\n"
}

MAIN_MENU
