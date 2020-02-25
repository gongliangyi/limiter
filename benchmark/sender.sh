#! /usr/bin/expect

###############################################
#
#get relative date
#
###############################################



if [ -f "capture.cap" ];then
	rm capture.cap
fi
if [ -f "iperf_send.txt" ];then
	rm iperf_send.txt
fi
if [ -f "speed_data.txt" ];then
	rm speed_data.txt
fi
if [ -f "cpu.txt" ];then
	rm cpu.txt
fi

wondershaper -c -a ens3
wondershaper -a ens3 -u 10240


function iperf3(){
	
	timeout 31 iperf3 -c 144.202.27.162 -p 5001 -i 0.1 -l 1460 -t 30 -b 12m > iperf_send.txt
}

function testspeed(){
	timeout 35 /root/Measurement-Limiter/MeasureRate/speed ens3 "dst port 5001" 100
}

function latency(){
	timeout 35 tcpdump -i ens3 dst port 5001 -w send.cap > /dev/zero
}



(iperf3 &); (testspeed &); (timeout 35 bash ./cpu_overhead.sh >> cpu.txt &); (latency &)

sleep 45
echo "finished"


###############################################
#
#process relative date
#
###############################################

wget http://144.202.27.162/receive.cap

tshark -r send.cap -T json >send.json
tshark -r receive.cap -T json >receive.json

python3 ./pcap.py

if [ ! -f "tcp_Retr" ];then
	g++ -o tcp_Retr tcp_Retr.cpp
fi

./tcp_Retr

