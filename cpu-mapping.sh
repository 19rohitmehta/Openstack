        #!/bin/bash
        lscpu=$(lscpu | grep "^CPU(s):"|awk '{print $2}')
        affinity=$(grep Aff /etc/systemd/system.conf  | awk -F"=" '{ print $2 }' | wc -w)
        if [ `sudo virsh list --all | grep -ic running` -ne 0 ]; then
                used=$(list=$(sudo virsh list --all | grep running | awk '{ print $1 }'); for i in $list; do sudo virsh dumpxml $i; done | grep "nova:vcpus" | sed 's/[<>]/ /g' |  awk '{ print $2 }' | paste -sd+ | bc)
                totalCpus=$(lscpu | grep "^CPU(s):"|awk '{print $2}')
                isolatedCpus=$(grep Aff /etc/systemd/system.conf |grep -v ^#  | awk -F"=" '{ print $2 }' | wc -w)
                vmname=`list=$(sudo virsh list --all | grep running | awk '{ print $1 }'); for i in $list; do  sudo virsh dumpxml $i; done | grep -e  "nova:name" -e "vcpupin" | sed 's/[<>]/ /g'  |  awk '{ print $2, $3 }' `
                echo "VM" $vmname "\n"
                usedCpus=`list=$(sudo virsh list --all | grep running | awk '{ print $1 }'); for i in $list; do sudo virsh dumpxml $i; done | grep "nova:vcpus" | sed 's/[<>]/ /g' |  awk '{ print $2 }' | paste -sd+ | bc`
                usednuma0=`list0=$(sudo virsh list --all | grep running | awk '{ print $1 }'); for i in $list0; do sudo virsh dumpxml $i; done | grep -e nodeset -e "nova:vcpus" |grep -v "page size"|grep -B1  "nodeset='0'" |grep nova:vcpu | sed 's/[<>]/ /g' |awk {'print $2'} |paste -sd+ | bc`
                usednuma1=`list1=$(sudo virsh list --all | grep running | awk '{ print $1 }'); for i in $list1; do sudo virsh dumpxml $i; done | grep -e nodeset -e "nova:vcpus" |grep -v "page size"|grep -B1  "nodeset='1'" |grep nova:vcpu | sed 's/[<>]/ /g' |awk {'print $2'} |paste -sd+ | bc`

                frees=$(echo "$totalCpus - $isolatedCpus - $usedCpus" | bc)
                #docker=$(docker ps |grep nova_compute |awk {'print $1'})
                #cpuAllocationRatio=$(sudo docker exec " $docker " cat /etc/nova/nova.conf|grep cpu_allocation_ratio|awk -F'=' '{ print $2 }')
                #usedalloc=$(echo "$cpuAllocationRatio * $usedCpus" | bc)
                #freealloc=$(echo "$cpuAllocationRatio * $totalCpus - $isolatedCpus - $cpuAllocationRatio * $usedCpus" | bc)
                echo "total:" $lscpu "; isol:" $affinity "; used:" $used "; free:" $frees  "; used-numa0:" $usednuma0 "; used-numa1:" $usednuma1
        else
                usedCpus=$(echo 0)
                used=$(echo 0)
                totalCpus=$(lscpu | grep "^CPU(s):"|awk '{print $2}')
                isolatedCpus=$(grep Aff /etc/systemd/system.conf  | awk -F"=" '{ print $2 }' | wc -w)
                frees=$(echo "$totalCpus - $isolatedCpus - $usedCpus" | bc)
                #docker=$(docker ps |grep nova_compute |awk {'print $1'})
                #cpuAllocationRatio=$(sudo docker exec " $docker " cat /etc/nova/nova.conf|grep cpu_allocation_ratio|awk -F'=' '{ print $2 }')
                #usedalloc=$(echo "$cpuAllocationRatio * $usedCpus" | bc)
                #freealloc=$(echo "$cpuAllocationRatio * $totalCpus - $isolatedCpus - $cpuAllocationRatio * $usedCpus" | bc)
                #echo "total:" $lscpu "; isol:" $affinity "; used:" $used "; free:" $frees
        fi