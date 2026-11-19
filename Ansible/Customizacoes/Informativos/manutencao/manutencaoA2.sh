#!/bin/bash
sleep 5
# Obtém o dia da semana (1 = Segunda-feira, 7 = Domingo)
export DIA_DA_SEMANA=$(date +%u)

# Obtém a hora atual no formato HHMM (ex: 11:45 vira 1145)
export HORA_ATUAL=$(date +%H%M)

# Valida se é terça-feira (2) E se o horário é antes das 13:00 (1300)
if (( DIA_DA_SEMANA == 2 )) && (( 10#$HORA_ATUAL < 1300 )); then

    zenity --warning \
           --title="Manutenção Programada" \
           --text="Esse laboratório entrará em manutenção das 12:00hrs até as 13:00hrs\nSalve seus arquivos e trabalhos!" \
           --ok-label="Ok, entendi!"\
           --width=420
fi

