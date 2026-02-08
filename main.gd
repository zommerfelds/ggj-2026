extends Control


func _ready() -> void:
	SignalBus.connect("change_screen", change_screen)
	get_tree().paused = !$GameUI.visible


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		SignalBus.change_screen.emit(SignalBus.Screen.GAME if $TitleScreen.visible else SignalBus.Screen.MENU)


func change_screen(screen: SignalBus.Screen) -> void:
	$GameUI.visible = screen == SignalBus.Screen.GAME
	$TitleScreen.visible = screen == SignalBus.Screen.MENU
	$SelectLevel.visible = screen == SignalBus.Screen.SELECT_LEVEL
	$Settings.visible = screen == SignalBus.Screen.SETTINGS
	$Credits.visible = screen == SignalBus.Screen.CREDITS

	get_tree().paused = screen != SignalBus.Screen.GAME
