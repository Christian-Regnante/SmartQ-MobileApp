enum TicketStatus {
  waiting('waiting'),
  serving('serving'),
  done('done'),
  skipped('skipped'),
  cancelled('cancelled');

  final String value;
  const TicketStatus(this.value);

  static TicketStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'serving':
        return TicketStatus.serving;
      case 'done':
        return TicketStatus.done;
      case 'skipped':
        return TicketStatus.skipped;
      case 'cancelled':
        return TicketStatus.cancelled;
      case 'waiting':
      default:
        return TicketStatus.waiting;
    }
  }

  String toDisplayString() {
    switch (this) {
      case TicketStatus.waiting:
        return 'Waiting';
      case TicketStatus.serving:
        return 'Serving';
      case TicketStatus.done:
        return 'Completed';
      case TicketStatus.skipped:
        return 'Skipped';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }
}
