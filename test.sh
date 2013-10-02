#!/bin/bash

MD5_CMD=""
testfile=$1
device=$2

function usage
{
	echo -e "Usage: $0 <testfile> <testdevice> [num]"
	echo -e "\ttestfile\tfile to test with"
	echo -e "\ttestdevice\tpath to device"
	echo -e "\tnum\t\t(optional) number of tests to run (default: 10)"
	exit 1
}

function find_md5
{
	tempfile="hello"
	echo $tempfile > hello82281qwqweeqww
	test1=`md5sum hello82281qwqweeqww 2> /dev/null | grep b1946ac92492d2347c6235b4d2611184`
	test2=`md5 -q hello82281qwqweeqww 2> /dev/null | grep b1946ac92492d2347c6235b4d2611184`
	rm hello82281qwqweeqww
	if [ "$test1" != "" ]; then
		MD5_CMD="md5sum"
	elif [ "$test2" != "" ]; then
		MD5_CMD="md5 -q"
	else
		echo "Couldn't find md5 command (tried md5, md5sum)"
		exit 1
	fi
}

get_md5 () {
	last_md5=`$MD5_CMD $* | cut -d\  -f1`
}

get_size () {
	last_size=`ls -al $* | awk '{print $5}'`
	last_size_human=`du -h $* | awk '{print $1}'`
}

if [ "$testfile" == "" ]; then
	usage
fi
if [ "$device" == "" ]; then
	usage
fi
if [ "$3" != "" ]; then
	TRIES=$3
else
	TRIES=10
fi

find_md5 #MD5_CMD now contains md5 or md5_sum

get_size $testfile
expected_size=$last_size
expected_size_human=$last_size_human
echo "Test file size: $expected_size_human ($expected_size)"

get_md5 $testfile
expected_md5=$last_md5
echo "Test file md5: $expected_md5"

join () {
			shift 2
			OLDIFS=$IFS
			IFS=""
	    tempname="$*"
			tempname=${tempname:0:32}
			IFS="$OLDIFS"
}
get_temp_name () {
	join `head -n 2 /dev/urandom | grep -aoE "[A-Za-z0-9]" | xargs echo "$*"`
}
echo "About perform $TRIES test copies"
tempfiles=()
rates=()
for (( i=1; i<=$TRIES; i++ )) do
	get_temp_name
	echo "Test $i (tmp filename: $device/$tempname)"
	tempfiles=( ${tempfiles[@]} $device/$tempname )
	t0=$SECONDS
	cp $testfile $device/$tempname
	t1=$SECONDS
	tdiff=$((t1-t0))
	warn=0
	if [ $tdiff -eq 0 ]; then
		tdiff=1
		warn=1
	fi
	if [ $warn -eq 1 ]; then
		echo "Warning: Tranfer too fast to calculate rate. Try a larger file?"
	else
		rate=$((expected_size/(tdiff*1024)))
		rates=( ${rates[@]} $rate )
		rate_mb=$((rate/1024))
		echo "Effective Transfer Rate in KB/s: $rate (~$rate_mb MB/s)"
	fi
	get_md5 $device/$tempname
	integr=$last_md5
	if [ "$integr" != "$expected_md5" ]; then
		echo "Drive integrity compromised! Expecting $device/$tempname to have md5 $expected_md5, but found with $integr"
		echo "The temp files have been left on the drive as evidence"
		exit 1
	fi
done

echo "Write tests completed successfully. Re-verifying files"
for (( i=0; i<${#tempfiles[*]}; i++ )) do
	get_md5 ${tempfiles[$i]}
	integr=$last_md5
	if [ "$integr" != "$expected_md5" ]; then
		echo "Drive integrity compromised! Expecting $device/$tempname to have md5 $expected_md5, but found with $integr"
		exit 1
	fi
done

echo "Data integrity looks ok. Files were verified after their initial copy and just now."
echo "*** ALL FILES VERIFIED SUCCESSFULLY ***"

echo "Removing temp files from drive..."

for (( i=0; i<${#tempfiles[*]}; i++ )) do
	echo "Removing ${tempfiles[$i]}"
	rm ${tempfiles[$i]}
done

if [ ${#rates[*]} -eq 0 ]; then
	echo "Transfers too fast, skipping average transfer rate calculation"
	exit
fi

echo "Calculating average transfer rate"
total_rate=0
for (( i=0; i<${#rates[*]}; i++ )) do
	total_rate=$(( $total_rate + ${rates[$i]} ))
done
total_rate=$(( $total_rate / ${#rates[*]} ))
total_rate_mb=$(( $total_rate / 1024 ))
echo "Average Transfer rate: $total_rate KB/s (~$total_rate_mb MB/s)"

