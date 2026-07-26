extends OmniLight3D

@export var toggle_time: float = 5
@export var glow_mesh: MeshInstance3D # <-- Assign your lightbulb mesh here in the Inspector!
@export var surface_index: int = 0    # Usually 0, unless your mesh has multiple materials

var time_passed: float = 0.0 
var glowing_material: StandardMaterial3D


func _ready() -> void:
	if glow_mesh != null:
		# Get the material currently on the mesh
		var mat = glow_mesh.get_active_material(surface_index)
		
		# Ensure it's a standard material, then duplicate it.
		# Duplicating prevents this script from accidentally blinking EVERY 
		# object in your game that happens to share this exact same material!
		if mat is StandardMaterial3D:
			glowing_material = mat.duplicate()
			glow_mesh.set_surface_override_material(surface_index, glowing_material)


func _process(delta: float) -> void:
	time_passed += delta
	
	if time_passed >= toggle_time:
		visible = not visible # Flips the OmniLight3D on/off
		time_passed = 0.0
		
		# Sync the material's glow to match the light's visibility
		if glowing_material != null:
			glowing_material.emission_enabled = visible
