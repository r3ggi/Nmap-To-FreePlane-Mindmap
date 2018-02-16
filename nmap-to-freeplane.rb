require 'nmap/xml'

puts "+"*80
puts "|"+" "*12+"Nmap scan result to FreePlane mindmap simple converter"+" "*12+"|"
puts "|"+" "*26+"Created by: Wojciech Regula"+" "*25+"|"
puts "+"*80
puts

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def colorize(text, color_code) "#{color_code}#{text}\e[0m" end
end

def parse_nmap_file(array_of_hosts)
  begin
    Nmap::XML.new(ARGV[0].chomp) do |xml|
      xml.each_host do |host|
        array_of_hosts << host
      end
    end
  rescue => e
    puts "[!] Problem with parsing XML nmap file".red
    puts e
    exit(-1)
  end
  puts "[+] Nmap scan parsed successfully".green
end


def generate_node(host)
  node = "<node TEXT=\"#{host.ip.to_s}\" FOLDED=\"true\" ID=\"ID_#{Time.now.to_i.to_s + rand(100).to_s}\">\n"
  host.each_port do |port|
    node += "<node TEXT=\"#{port.number.to_s}\" FOLDED=\"true\" ID=\"ID_#{Time.now.to_i.to_s + rand(100).to_s}\">\n"
    node += "<node TEXT=\"State: #{port.state.to_s }\" FOLDED=\"true\" ID=\"ID_#{Time.now.to_i.to_s + rand(100).to_s}\">\n"
    node += "</node>"
    node += "<node TEXT=\"Protocol: #{port.protocol.to_s}\" FOLDED=\"true\" ID=\"ID_#{Time.now.to_i.to_s + rand(100).to_s}\">\n"
    node += "</node>"
    unless port.service.to_s.nil?
      node += "<node TEXT=\"Service: #{port.service.to_s}\" FOLDED=\"true\" ID=\"ID_#{Time.now.to_i.to_s + rand(100).to_s}\">\n"
      node += "</node>"
    end
    node += "</node>"
  end
  node += "</node>"
end

def generate_mindmap()

  array_of_hosts = []

  parse_nmap_file(array_of_hosts)

  top = <<-EOXML
  <map version="freeplane 1.6.0">
    <node TEXT="NMAP" FOLDED="false" ID="ID_325166948">
      <font SIZE="24"/>
      <node TEXT="hosts" POSITION="right" ID="ID_792112873">
  EOXML

  bottom = <<-EOXML
      </node>
    </node>
  </map>
  EOXML

  middle = ""

  array_of_hosts.each do |host|
    middle += generate_node(host)
  end
  mindmap = top + middle + bottom

  begin
    File.open("GeneratedMindmap.mm", "w+") do |file|
      file.write mindmap
    end
  rescue => e
    puts "[!] Error in saving file".red
    puts e
    exit(-2)
  end

  puts "[+] Mindmap succesfully generated: #{Dir.pwd}/GeneratedMindmap.mm".green
end

if ARGV.size < 1
  puts "Usage: \`ruby nmap-to-freeplane.rb PATH_TO_NMAP_SCAN_RESULT\`\n\n".red
else
  if File.exist? ARGV[0]
    generate_mindmap()
  else
    puts "[!] Provided file doesn't exist!".red
  end
end
