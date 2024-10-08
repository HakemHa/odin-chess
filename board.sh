#! /usr/bin/bash
printf "\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n\e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[40m       \e[47m       \e[0m\n"
printf "\n"
white_piece="\e[48;5;15;38;5;250m █         \e[0m"
black_piece="\e[48;5;16;38;5;235m █         \e[0m"
white_line=""
black_line=""
counter=1
while [ $counter -le 8 ]
do
    if [ $((counter%2)) -eq 0 ]
    then
        white_line+=$black_piece
        black_line+=$white_piece
    else
        white_line+=$white_piece
        black_line+=$black_piece
    fi
    ((counter++))
done
white_line+="\n"
black_line+="\n"
white_block=""
black_block=""
counter=1
while [ $counter -le 5 ]
do
    white_block+=$white_line
    black_block+=$black_line
    ((counter++))
done
board=""
counter=1
while [ $counter -le 8 ]
do
    if [ $((counter%2)) -eq 0 ]
    then
        board+=$black_block
    else
        board+=$white_block
    fi
    ((counter++))
done
printf "$board"