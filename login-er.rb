#!/usr/bin/ruby -w



require 'open-uri'


class String
def bg_red;         "\033[41m#{self}\033[0m" end
def bg_green;       "\033[42m#{self}\033[0m" end
end




file = 0
df_line = 0
mem_free = 0
mem_cached = 0
mem_buffered = 0
mem_total = 0
public_ip = 0
dns_ip = 0
tempvar1= 0	##naming

useful_files_array=Array.new()
mem_info_line = Array.new()
df_output=Array.new()
df_line_split=Array.new()
tempvar2=Array.new()	##naming



def search_for (search_string, files)
	for file in files do
		begin
			if IO.read(file).include?(search_string) then
				return 0
			end
		rescue Errno::ENOENT
			puts "The file %s doesn't exist anymore?!?!!?!?!?!?".bg_red % [file]
			return 2
		end
	end
	return 1
end

def print_from (search_string, files)
	for file in files do
		begin
			IO.foreach(file) {|blah| if blah.include?search_string then 
				puts blah
			end}
		rescue Errno::ENOENT
			puts "The file %s doesn't exist anymore???!!?!?!?!?".bg_red % [file]
			return 2
		end
	end
end


#
#temperature
###########
begin
	puts "\n__________________________________________________________\n\n"
	temperature=IO.read("/sys/class/thermal/thermal_zone0/temp")
rescue Errno::ENOENT
	puts "the sysfs temperature file doesn't exist !?!?!?!".bg_red
	puts "\n__________________________________________________________\n\n"
else
	if (temperature.to_f/1000 > 65) then
		puts "the cpu temperature is : %.3fC".bg_red % [temperature.to_f/1000]
	else
		puts "the cpu temperature is : %.3fC".bg_green % [temperature.to_f/1000]
	end

	puts "\n__________________________________________________________\n\n"
end
###########


#
#apache kai sys authentication logs
#########
useful_files_array=Dir.glob("/var/log/auth*")
useful_files_array+=Dir.glob("/var/log/apache2/error.log*")
useful_files_array=useful_files_array.select {|blah| blah !~ /(.*)gz/}

if (search_for("user", useful_files_array.select {
    |blah| blah =~ /\/var\/log\/apache2\/error(.*)/ }) == 0) then
	puts "apache authentication failures have been found :\n\n".bg_red
	print_from("user", useful_files_array.select {
	    |blah| blah =~ /\/var\/log\/apache2\/error(.*)/ })
else
	puts "there are no authentication failures in the apache logs".bg_green
end
puts "\n__________________________________________________________\n\n"

if (search_for("ailed", useful_files_array.select {
   |blah| blah =~ /\/var\/log\/auth(.*)/ }) == 0) then
	puts "system authentication failures have been found :".bg_red
	puts "\n"
	print_from("ailed", useful_files_array.select {
	    |blah| blah =~ /\/var\/log\/auth(.*)/ })
else
	puts "there are no system authentication failures".bg_green
end
puts "\n__________________________________________________________\n\n"
##########


 
#
#filesystem usage
#########
df_output=`df -h`
for df_line in df_output.split("\n") do
	df_line_split=df_line.split(' ')
	if df_line_split[4].delete('%').to_i > 60 then
		puts "filesystem : %s is %s utilized".bg_red % [df_line_split[0], df_line_split[4]]
	puts "\n__________________________________________________________\n\n"
	end
end 
##########



#
#uptime
#########
puts "the uptime is : %s" % `uptime`
puts "\n__________________________________________________________\n\n"
########



#
#memory utilization
########
IO.foreach("/proc/meminfo") {|blah|
mem_info_line=blah.split
				if blah.include?("MemTotal") then 
					mem_total=mem_info_line[1].to_i
				end
				if blah.include?("MemFree") then
					mem_free=mem_info_line[1].to_i
				end
				if blah.include?("Buffers") then
					mem_buffered=mem_info_line[1].to_i
				end
				if (blah.include?("Cached") ^ blah.include?("SwapCached"))
					mem_cached=mem_info_line[1].to_i
				end
				}

puts "the total memory is %iMB, out of which %iMB are free \n\t\t(cached : %iMB, buffers : %iMB, unused : %iMB)" % [mem_total/1024, (mem_free + mem_buffered + mem_cached)/1024, mem_cached/1024, mem_buffered/1024, mem_free/1024]
puts "\n__________________________________________________________\n\n"
########




#
# open ssh sessions
#########
tempvar2=`netstat -an`
if tempvar2.include?(":22 ") then
	puts "the active ssh sessions are : \n\n"
	for tempvar1 in tempvar2.split("\n") do
		if ((tempvar1.include?(":22")) && !(tempvar1.include?("LISTEN"))) then
			puts tempvar1
		end
	end
else
	puts "there are no active ssh sessions (!?!??!?!?!!?!!?!?)".bg_red
end
puts "\n__________________________________________________________\n\n"
#########



#
# public ip
########
public_ip = open('http://whatismyip.akamai.com').read
dns_ip=`nslookup system-v.no-ip.biz`
dns_ip=dns_ip.split()[-1]

if (dns_ip == public_ip) then
	puts "the public ip is : %s and the no-ip dns record is synchronized".bg_green % [public_ip]
	puts "\n__________________________________________________________\n\n"
else
	puts "the public ip is : %s while the dns record for system-v.no-ip.biz points at %s".bg_red % [public_ip, dns_ip]
	puts "\n__________________________________________________________\n\n"
end
########
