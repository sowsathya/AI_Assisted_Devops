#!/bin/bash


get_cpu_usage() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ps aux | awk 'NR>1 {sum+=$3} END {print sum}'
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        wmic os get TotalVisibleMemorySize,FreePhysicalMemory | tail -1 | awk '{printf "%.2f", (1-$2/$1)*100}'
    else
        echo "0"
    fi
}

get_memory_usage() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        free | grep Mem | awk '{printf "%.2f", ($3/$2)*100}'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.' | awk '{printf "%.2f", ($1/1024/1024)*100}'
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        wmic OS get TotalVisibleMemorySize,FreePhysicalMemory | tail -1 | awk '{printf "%.2f", (1-$2/$1)*100}'
    else
        echo "0"
    fi
}

get_disk_usage() {
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        df / | tail -1 | awk '{printf "%.2f", ($3/$2)*100}'
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        wmic logicaldisk get size,freespace where name="C:" | tail -1 | awk '{printf "%.2f", (1-$2/$1)*100}'
    else
        echo "0"
    fi
}

check_health() {
    local cpu=$(get_cpu_usage)
    local memory=$(get_memory_usage)
    local disk=$(get_disk_usage)

    cpu=${cpu%.*}
    memory=${memory%.*}
    disk=${disk%.*}

    echo "CPU Usage: ${cpu}%"
    echo "Memory Usage: ${memory}%"
    echo "Disk Usage: ${disk}%"
    echo ""

    if [ "$cpu" -lt 60 ] && [ "$memory" -lt 60 ] && [ "$disk" -lt 60 ]; then
        echo "Status: HEALTHY"
    else
        echo "Status: UNHEALTHY"
    fi
}

check_health
