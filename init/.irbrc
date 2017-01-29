IRB.conf[:PROMPT][:HAKO] = {
  :PROMPT_I => "%N(%m):%03n:%i> ".bold,
  :PROMPT_S => "%N(%m):%03n:%i%l ".bold,
  :PROMPT_C => "%N(%m):%03n:%i* ".bold,
  :RETURN => "#{'=> '.bold}%s\n"
}
IRB.conf[:PROMPT_MODE] = :HAKO
IRB::Inspector.def_inspector(:display) do |val| if val.is_a? Exception then val.display.red else val.display end end
IRB.conf[:INSPECT_MODE] = :display
IRB.conf[:IRB_NAME] = $HAKO_SHELL_NAME
