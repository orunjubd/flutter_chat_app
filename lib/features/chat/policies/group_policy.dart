class GroupPolicy {
  const GroupPolicy({
    this.maxMembers = 256,
    this.onlyAdminsManage = true,
    this.defaultMemberCanSend = false, // your decision: default-deny
  });
  final int maxMembers;
  final bool onlyAdminsManage;
  final bool defaultMemberCanSend; // can send messages by default

  static const minMembersToCreate =
      3; // creator + 2 (use 2 if you want small groups)
  static const maxNameLength = 25;

  String? validateName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) return 'Group name is required.';
    if (name.length > maxNameLength) return 'Max $maxNameLength characters.';
    return null;
  }

  String? validateCreate(int selectedCount) {
    final total = selectedCount + 1;
    if (total < minMembersToCreate) {
      return 'Select at least ${minMembersToCreate - 1} people.';
    }
    if (total > maxMembers) return 'A group allows up to $maxMembers members.';
    return null;
  }

  bool canManageMembers({required bool isAdmin}) =>
      !onlyAdminsManage || isAdmin;

  String? validateAdd({required int currentCount, required int adding}) =>
      currentCount + adding > maxMembers
      ? 'A group allows up to $maxMembers members.'
      : null;
}
