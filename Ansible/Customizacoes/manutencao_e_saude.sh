#!/bin/bash
#
# Script combinado: manutenção do sistema (update/upgrade/limpeza)
# + checagem de saúde de hardware (temperatura, SMART, erros de kernel)
#
# Uso no crontab (rodando como root):
# 30 12 * * 2 /home/administrador/manutencao_e_saude.sh

LOG_MANUTENCAO="/var/log/manutencao.log"
LOG_HARDWARE="/var/log/hardware_health.log"

# ----------------------------------------------------------------
# Checagem de privilégios: apt, smartctl e dmesg geralmente exigem root
# ----------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Erro: execute este script como root." >&2
    exit 1
fi

# ==================================================================
# PARTE 1: MANUTENÇÃO (update, upgrade, limpeza)
# ==================================================================
DATA_INICIO=$(date "+%Y-%m-%d %H:%M:%S")

{
echo "=========================================="
echo "Manutenção iniciada em: $DATA_INICIO"
} >> "$LOG_MANUTENCAO"

apt update -y >> "$LOG_MANUTENCAO" 2>&1
STATUS_UPDATE=$?

apt upgrade -y >> "$LOG_MANUTENCAO" 2>&1
STATUS_UPGRADE=$?

# Ajuste o caminho abaixo conforme o que realmente precisa ser limpo
rm -fr /home/al.* >> "$LOG_MANUTENCAO" 2>&1
STATUS_RM=$?

DATA_FIM=$(date "+%Y-%m-%d %H:%M:%S")

{
if [ $STATUS_UPDATE -eq 0 ] && [ $STATUS_UPGRADE -eq 0 ] && [ $STATUS_RM -eq 0 ]; then
    echo "Resultado: SUCESSO - Manutenção concluída em $DATA_FIM"
else
    echo "Resultado: FALHA - Manutenção concluída com erros em $DATA_FIM"
    echo "Status: apt update=$STATUS_UPDATE | apt upgrade=$STATUS_UPGRADE | rm=$STATUS_RM"
fi
echo "=========================================="
echo ""
} >> "$LOG_MANUTENCAO"

# ==================================================================
# PARTE 2: CHECAGEM DE SAÚDE DE HARDWARE
# ==================================================================
DATA_HW=$(date "+%Y-%m-%d %H:%M:%S")

{
echo "=========================================="
echo " Relatório de Integridade: $DATA_HW"
echo " Hospedeiro: $(hostname)"
echo "=========================================="

# 1. Temperatura do processador (exige lm-sensors)
if command -v sensors &> /dev/null; then
    echo -e "\n[Temperaturas do Sistema]"
    sensors | grep -E "(Package|Core|Composite)"
else
    echo -e "\n[Temperaturas do Sistema]"
    echo "sensors não encontrado. Instale lm-sensors."
fi

# 2. Integridade SMART de discos (SSDs / HDDs)
echo -e "\n[Saúde dos Discos - SMART]"
if command -v smartctl &> /dev/null; then
    for drive in $(lsblk -d -n -o NAME | grep -E '^sd|^nvme'); do
        HEALTH=$(smartctl -H /dev/$drive 2>/dev/null | grep -i "result")
        echo "Disco /dev/$drive: ${HEALTH:-não foi possível ler}"
    done
else
    echo "smartctl não encontrado. Instale smartmontools."
fi

# 3. Erros de memória / kernel (MCE - Machine Check Exceptions)
echo -e "\n[Log de Erros Críticos no Kernel]"
dmesg -T | grep -iE "(error|hardware error|mce|correctable)" | tail -n 10

echo "Análise de hardware concluída."
echo "=========================================="
echo ""
} >> "$LOG_HARDWARE"

sudo reboot now
