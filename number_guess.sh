#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

if ! psql -X --username=freecodecamp -lqt | cut -d '|' -f 1 | grep -qw number_guess; then
  createdb --username=freecodecamp number_guess
fi

psql -X --username=freecodecamp --dbname=number_guess -f "$(dirname "$0")/number_guess.sql" >/dev/null

echo "Enter your username:"
read -r USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

if [[ -z $USER_ID ]]; then
  psql -X --username=freecodecamp --dbname=number_guess -c "INSERT INTO users(username) VALUES('$USERNAME');" >/dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID;")
  GAMES_PLAYED=${GAMES_PLAYED:-0}
  BEST_GAME=${BEST_GAME:-0}
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=${NUMBER_GUESS_SECRET:-$((RANDOM % 1000 + 1))}
TRIES=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read -r GUESS
  ((TRIES += 1))

  if ! [[ "$GUESS" =~ ^-?[0-9]+$ ]] || (( GUESS < 0 || GUESS > 1000 )); then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

psql -X --username=freecodecamp --dbname=number_guess -c "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES);" >/dev/null

echo "You guessed it in $TRIES tries. The secret number was $((TRIES - 1)). Nice job!"
sleep 1

# Ensure database is ready before gameplay

# Display welcome information for returning players

# Main game loop for guessing the secret number

# Final score summary for completed games
