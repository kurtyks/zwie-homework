#!/bin/basE 


file_in="tickets_prd.csv"
file_out="export.txt"
baseURL="https://customizations.zowie.dev/ecommerce/tickets/"
# Functions 

# Get single tickt status by ticket id 
read_ticket_status () {
        local status
	local ticket_id=$(echo $1 | sed 's/[[:space:]]//g')
	local url="${baseURL}${ticket_id}"
	status=$(curl -s --location "$url" -H 'X-API-KEY: c895a35c365541c4ac22a61d13bc388d' | jq -r '.status')
	if [ -z "$status" ]; then
                status="ERROR"
	fi
	echo $status
}

#Main loop for export 
export_data () {
	tail -n +2 "$file_in" | while IFS=',' read -r ticket_id; do
	ticket_status=$(read_ticket_status "$ticket_id")
	append_to_fout "$ticket_id" "$ticket_status"
        done
}

# Append new row to export file 
append_to_fout() {
    local new_row="${1}|${2}"
    echo "$new_row" >> "$file_out"
}

# Check total row count ( -1 bc header)
total_row_count() {
    local row_count
    local file=$1
    row_count=$(wc -l < "$file")
    echo $((row_count - 1))
}


analyze_output () {
	echo 1
}

uniq_statuses () {
  cat "$file_out" | tail -n +2 | cut -d '|' -f2 | sort | uniq -c | while read count status; do
    echo "$status $count"
  done
}

echo 'ticketID|status' > $file_out
echo "Total rows to process $(total_row_count $file_in)"
export_data
uniq_statuses
