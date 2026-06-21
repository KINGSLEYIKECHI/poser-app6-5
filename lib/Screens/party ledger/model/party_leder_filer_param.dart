class PartyLedgerFilterParam {
  final String partyId;
  final String? duration;

  PartyLedgerFilterParam({
    required this.partyId,
    this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyLedgerFilterParam &&
          runtimeType == other.runtimeType &&
          partyId == other.partyId &&
          duration == other.duration;

  @override
  int get hashCode => partyId.hashCode ^ duration.hashCode;
}
