/// Business rule for the task feature.
///
/// A task title is valid when, after removing leading and trailing
/// whitespace, it still contains at least one character. Keeping this
/// rule in a plain function makes it trivial to unit test: it has no
/// widgets, no I/O, and no dependencies.
bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}
