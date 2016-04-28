do

function run(msg, matches)
  return 'Smart-bot v1'.. VERSION .. [[ 
 
 Sudo: @aliebadi5
  Developer : @arashnomiri
  
  Channel : @avast_team
  
  Open git : https://github.com/Arashalone/avast-BOT-V6.3.git
  
 SMART BOT V1
  
  All rights reserved.
  __________________]]
end

return {
  description = "Shows bot version", 
  usage = "!version: Shows bot version",
  patterns = {
    "^!version$"
  }, 
  run = run 
}

end
