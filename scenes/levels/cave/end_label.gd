extends Label



func trigger():
	show()


func _on_apex_destroyed():
	setup_text()
	show()

func setup_text():
	var time : float = Data.time
	var minutes = "%0*d" % [2, int(time/60)]
	var seconds = "%0*d" % [2, int(time) % 60]
	var decimals = "%0*d" % [2, (time - int(time))* 100]
	get_node("Label").text = get_node("Label").text.format({
		"minutes": minutes,
		"seconds": seconds,
		"decimals": decimals,
		"ammo": Data.max_ammo - 4,
		"health": (Data.max_health - 100)/20,
	})
