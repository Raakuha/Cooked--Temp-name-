extends Node
class_name MusicManager

@export var music_player: AudioStreamPlayer
@export var tutorial_music_player: AudioStreamPlayer
func play_day_music() -> void:
	print("========================")
	print("[MusicManager] PLAY DAY MUSIC")
	print("[MusicManager] music_player = ", music_player)

	if music_player == null:
		push_warning("[MusicManager] AudioStreamPlayer belum dipasang.")
		return

	print("[MusicManager] stream = ", music_player.stream)
	print("[MusicManager] volume_db = ", music_player.volume_db)
	print("[MusicManager] playing sebelum = ", music_player.playing)

	if music_player.playing:
		print("[MusicManager] Musik sudah jalan, tidak restart.")
		return

	music_player.play()

	print("[MusicManager] playing sesudah = ", music_player.playing)
	print("========================")	

func stop_music() -> void:
	if music_player == null:
		return

	if music_player.playing:
		music_player.stop()
func play_tutorial_music() -> void:
	if tutorial_music_player == null:
		push_warning("[MusicManager] TutorialMusicPlayer belum dipasang.")
		return

	if music_player != null and music_player.playing:
		music_player.stop()

	if tutorial_music_player.playing:
		return

	tutorial_music_player.play()
func stop_tutorial_music() -> void:
	if tutorial_music_player != null:
		tutorial_music_player.stop()
