extends Control

signal closed

func _ready() -> void:
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	$VBoxContainer/MusicSlider.value_changed.connect(_on_music_volume_changed)
	$VBoxContainer/SfxSlider.value_changed.connect(_on_sfx_volume_changed)
	$VBoxContainer/MusicToggle.toggled.connect(_on_music_toggled)
	$VBoxContainer/SfxToggle.toggled.connect(_on_sfx_toggled)
	_load_settings()

func _load_settings() -> void:
	var music_vol = SaveManager.get_setting("music_volume", 0.8)
	var sfx_vol = SaveManager.get_setting("sfx_volume", 1.0)
	var music_on = SaveManager.get_setting("music_on", true)
	var sfx_on = SaveManager.get_setting("sfx_on", true)
	$VBoxContainer/MusicSlider.value = music_vol
	$VBoxContainer/SfxSlider.value = sfx_vol
	$VBoxContainer/MusicToggle.button_pressed = music_on
	$VBoxContainer/SfxToggle.button_pressed = sfx_on
	_apply_music(music_vol, music_on)
	_apply_sfx(sfx_vol, sfx_on)

func _on_music_volume_changed(value: float) -> void:
	SaveManager.set_setting("music_volume", value)
	_apply_music(value, $VBoxContainer/MusicToggle.button_pressed)

func _on_sfx_volume_changed(value: float) -> void:
	SaveManager.set_setting("sfx_volume", value)
	_apply_sfx(value, $VBoxContainer/SfxToggle.button_pressed)

func _on_music_toggled(pressed: bool) -> void:
	SaveManager.set_setting("music_on", pressed)
	_apply_music($VBoxContainer/MusicSlider.value, pressed)

func _on_sfx_toggled(pressed: bool) -> void:
	SaveManager.set_setting("sfx_on", pressed)
	_apply_sfx($VBoxContainer/SfxSlider.value, pressed)

func _apply_music(volume: float, enabled: bool) -> void:
	var db = linear_to_db(volume) if enabled else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _apply_sfx(volume: float, enabled: bool) -> void:
	var db = linear_to_db(volume) if enabled else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

func _on_close_pressed() -> void:
	closed.emit()
