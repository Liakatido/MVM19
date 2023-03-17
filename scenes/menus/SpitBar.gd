extends HBoxContainer

const Cell = preload("res://assets/ui/spitcell.tscn")

var cells : Array
var current_i : int

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		cells.append(child)
	Data.connect("max_ammo_changed", adjust_cells)
	Data.connect("ammo_changed", switch_ammo)
	switch_ammo()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Data.ammo != Data.max_ammo:
		cells[current_i].get_node("TextureProgressBar").value = (Data.ammo_ticker*100)/Data.ammo_cooldown

func switch_ammo():
	if Data.max_ammo == 0 or Data.ammo == Data.max_ammo:
		return
	current_i = Data.ammo
	# behind current_i should be filled
	for i in range(current_i):
		cells[i].get_node("TextureProgressBar").value = 100
	# after current_i should be empty
	if current_i != Data.max_ammo-1:
		for i in range(current_i + 1, len(cells)):
			cells[i].get_node("TextureProgressBar").value = 0

func fill_all():
	current_i = Data.ammo
	# behind current_i should be filled
	for i in range(current_i):
		cells[i].get_node("TextureProgressBar").value = 100

func adjust_cells():
	# add
	if Data.max_ammo > len(cells):
		var cell = Cell.instantiate()
		cell.value = 100
		cells.append(cell)
		add_child(cell)
		fill_all() # when increasing max ammo, all ammo is filled up
	# remove
	if Data.max_ammo < len(cells):
		var cell = cells.pop_back()
		remove_child(cell)
		switch_ammo()
