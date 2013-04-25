# How to use:
# 1) Enable on channels you wish to use it on:
#		.chanset #example +idlekick
#
# 2) Configure how long users are allowed to idle (in minutes)
#		.chanset #example idlekick-time 15
#
# 3) You may configure the messages below.

# Warning message
set warningmsg "Warning! You will be kicked in 1 minute due to our anti-idle policy."

# Kick message
set kickmsg "Kicked due to inactivity - this channel has an anti-idle policy."

# How many minutes ban user for.
set bantime 5   

# ------------------------------------------------------------------------------------

setudef flag idlekick
setudef str idlekick-time

proc idlekick:tick {minute hour day month year} {
	foreach channel [channels] {
		if {[channel get $channel idlekick] == "1" && [botisop $channel]} {
			foreach iu [chanlist $channel] {
				if {![isbotnick $iu] && [onchan $iu $channel] && ![isop $iu $channel] 
					&& ![ishalfop $iu $channel] && ![isvoice $iu $channel]} {						
					if {[getchanidle $iu $channel] == [expr [channel get $channel idlekick-time] -1]} {
						idlekick:warn $channel $iu
					} 
				
					if {[getchanidle $iu $channel] >= [channel get $channel idlekick-time]} {
						idlekick:kick $channel $iu
					}
				}
			}
		}
	}
}

proc idlekick:warn {channel nick} {
	global warningmsg
	
	putlog "ANTIIDLE: Warning $nick on $channel due to idling"
	
	puthelp "PRIVMSG $channel :$nick: $warningmsg"
}

proc idlekick:kick {channel nick} {
	global kickmsg bantime
	
	putlog "ANTIIDLE: Banning $nick on $channel due to idling"
	
	set nickhost [lindex [split [getchanhost $nick] "@"] 1]
	putserv "MODE $channel +b *!*@$nickhost"
	putserv "KICK $channel $nick :$kickmsg"
	
	timer $bantime putserv "MODE $channel -b *!*@$nickhost"
}

bind time - "* * * * *" idlekick:tick