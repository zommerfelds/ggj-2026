extends Control


func _ready() -> void:
	SignalBus.connect("change_screen", change_screen)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		SignalBus.change_screen.emit("game" if $TitleScreen.visible else "menu")


func change_screen(screen: String) -> void:
	$TitleScreen.visible = screen == "menu"
	$Settings.visible = screen == "settings"
	$GameUI.visible = screen == "game"
	$Credits.visible = screen == "credits"

	get_tree().paused = screen != "game"
