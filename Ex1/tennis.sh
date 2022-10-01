#!/bin/bash
#David Bogoslavsky
game_on=true
first_round=true
ball_location=0
points_1=50
points_2=50
guess_1=0
guess_2=0


welcome_message() {
  clear
  echo -e "========================================================"
  echo -e "==================I wanna play a game==================="
  echo -e "===What's the most you've ever lost in a tennis game?==="
  echo -e "========================================================"
  sleep 3
}

print_board() {
    echo -e " Player 1: ${points_1}         Player 2: ${points_2} "
    echo -e " --------------------------------- "
    echo -e " |       |       #       |       | "
    echo -e " |       |       #       |       | "
    #the middle row with the ball
    case $ball_location in
        "-3")
        echo -e "O|       |       #       |       | "
        ;;
        "-2")
        echo -e " |   O   |       #       |       | "
        ;;
        "-1")
        echo -e " |       |   O   #       |       | "
        ;;
        0)
        echo -e " |       |       O       |       | "
        ;;
        1)
        echo -e " |       |       #   O   |       | "
        ;;
        2)
        echo -e " |       |       #       |   O   | "
        ;;
        3)
        echo -e " |       |       #       |       |O "
        ;;
        *)
        echo -e "error in case"
        ;;
    esac
    echo -e " |       |       #       |       | "
    echo -e " |       |       #       |       | "
    echo -e " --------------------------------- "
    if [ $first_round = false ]; then
        echo -e " Player 1 played: ${guess_1}\n Player 2 played: ${guess_2}\n\n"
    fi

}

move(){
    p1=$1
    p2=$2
    # player 1 won
    if [ $(($p1 - $p2)) -gt 0 ]; then
        winner=-1
    #if player 2  won
    elif [ $(($p1 - $p2)) -lt 0 ]; then
        winner=1
    #a tie
    else
        winner=0
    fi
    #determin on what side of the field the ball is
    if [ $(($winner * $ball_location)) -gt 0 ]; then
    #winner's field -> transfer it
        ball_location=$((-1*$winner))
    elif [ $(($winner * $ball_location)) -lt 0 ]; then
    #loser's field -> advance it in his field
        ball_location=$(($ball_location - $winner))
    #in the first move we get the ball right in the middle. we have to throw it
    #to the loser's field
    elif [ $ball_location == 0 ]; then
        ball_location=$((-1*$winner))
    fi
    points_1=$(($points_1 - $guess_1))
    points_2=$(($points_2 - $guess_2))
    first_round=false
}

player_pick(){
    #enter first guess
    echo -e "PLAYER 1 PICK A NUMBER: "
    read -s p1pick
    #input check
    while :
     do
        if [[ $p1pick =~ ^[0-9]+$ ]] && [ $p1pick -le $points_1 ] && [ $p1pick -ge 0 ]; then
            break
        else
            echo -e "NOT A VALID MOVE !"
            echo -e "PLAYER 1 PICK A NUMBER: "
            read -s p1pick
        fi
    done
    #enter second guess
    echo -e "PLAYER 2 PICK A NUMBER: "
    read -s p2pick
    #input check
    while :
     do
        if [[ $p2pick =~ ^[0-9]+$ ]] && [ $p2pick -le $points_2 ] && [ $p2pick -ge 0 ]; then
            break
        else
            echo -e "NOT A VALID MOVE !"
            echo -e "PLAYER 2 PICK A NUMBER: "
            read -s p2pick
        fi
    done
    #update the last gusses
    guess_1=$p1pick
    guess_2=$p2pick
    #call to move
    move $p1pick $p2pick

}

check_winner(){
   winner=none
   if [ $ball_location == -3 ]; then
         winner=player_2

   elif [ $ball_location == 3 ]; then
   	 winner=player_1
   elif [ $points_1 == 0 ]; then
        if [ $points_2 == 0 ]; then
            if [ $ball_location -gt 0 ]; then
                winner=player_1
            elif [ $ball_location -lt 0 ]; then
                winner=player_2
            else
                winner=tie
            fi
        else
            winner=player_2
        fi
    elif [ $points_2 == 0 ]; then
        winner=player_1
    fi
    #we have a winner!
    if [ $winner != "none" ]; then
        game_on=false
        print_board
        if [ $winner == "player_1" ]; then
            echo -e "PLAYER 1 WINS!"
        elif [ $winner == "player_2" ]; then
            echo -e "PLAYER 2 WINS!"
        else
            echo -e "IT'S A DRAW!"
        fi
    fi
}

welcome_message
print_board
while $game_on
do
  player_pick
  check_winner
  if [ $game_on == true ]; then
  	print_board
  fi
done
