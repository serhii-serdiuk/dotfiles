ssh-exec-target() {
    ssh target "$@"
}

ssh-exec-thinkcentre() {
    ssh thinkcentre "$@"
}

# ssh-exec() {
#     ssh $1 "${@:2}"
# }


# netcat -z -v 192.168.5.208 1714-1764
# nmap -Pn -p 1716 192.168.5.201
# nmap -Pn -p 1716 <external_ip>

scan-network() {
    local option="default"
    local options=$(getopt -l "mac,all" -o "ma" -a -- "$@")
    eval set -- "$options"

    while true; do
        case $1 in
        -m|--mac|-a|--all)
            option=$1 ;;
        --)
            shift
            break ;;
        esac
        shift
    done

    local address_range=$1

    case $option in
    -m|--mac)
        echo "Looking for reachable hosts (show MAC addresses)..."
        sudo nmap -sn $address_range | replace-substring "Nmap scan report for|MAC Address:" "*" ;;
    -a|--all)
        echo "Looking for all hosts on the network..."
        nmap -sL $address_range | replace-substring "Nmap scan report for" "*" | delete-line "^* [0-9]" ;;
    *)
        echo "Looking for reachable hosts..."
        nmap -sn $address_range | replace-substring "Nmap scan report for" "*" ;;
    esac
}

# find_ip_by_mac() {
#     not needed in this function, just for referrense
#     sudo arp-scan --interface=eno1 --localnet
#     sudo arp-scan --interface=wlp9s0 --localnet

#     sudo arp-scan --destaddr=<mac_address> --localnet
#     get ip from arp-scan output
#     use nmap to get ip with hostname
#     nmap -sP <ip_address> | egrep --color=never "scan report"
# }

# sudo apt install traceroute
# traceroute <ip_address>
# nmcli connection
# route -n
#
# nmcli connection modify project\ network ipv4.route-metric 100
# nmcli connection modify target ipv4.route-metric 150
# nmcli connection show project\ network | grep ipv4.route-metric
# nmcli connection show target | grep ipv4.route-metric
# nmcli connection up target
# nmcli connection up project\ network
