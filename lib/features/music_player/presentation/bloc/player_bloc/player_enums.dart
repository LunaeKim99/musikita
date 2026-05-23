// ADDED: File baru untuk enum PlayerStateType dan RepeatModeState
// Sebelumnya ada di player_event.dart

enum PlayerStateType {
  idle,
  loading,
  playing,
  paused,
  completed,
  stopped,
}

enum RepeatModeState {
  off,
  one,
  all,
}
