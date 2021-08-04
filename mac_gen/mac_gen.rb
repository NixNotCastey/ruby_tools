# frozen_string_literal: true

#Generate MAC Address from Locally Administered  Range - Safe for VMs
puts [[format('%0.1X', rand(16)), [2, 6, 'A', 'E'].sample].join, (1..5).map { format('%0.2X', rand(256)) }].join(':')
