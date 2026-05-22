class Transaction {
  final String id;
  final String desc;
  final String date;
  final String dateLong;
  final String amount;
  final bool incoming;
  final String type;
  final String study;
  final String from;
  final String txid;
  final String status;

  const Transaction({
    required this.id,
    required this.desc,
    required this.date,
    required this.dateLong,
    required this.amount,
    required this.incoming,
    required this.type,
    required this.study,
    required this.from,
    required this.txid,
    required this.status,
  });
}

const demoTransactions = [
  Transaction(
    id: 't1',
    desc: 'Sleep Study — Karolinska',
    date: '3 May 2026',
    dateLong: '3 May 2026, 14:22',
    amount: '+250 pts',
    incoming: true,
    type: 'Received',
    study: 'Sleep Patterns Research',
    from: 'Karolinska Institutet',
    txid: 'TXN-8294-AC41',
    status: 'Completed',
  ),
  Transaction(
    id: 't2',
    desc: 'Redeemed — Partner Store',
    date: '28 Apr 2026',
    dateLong: '28 Apr 2026, 09:13',
    amount: '−100 pts',
    incoming: false,
    type: 'Redemption',
    study: '—',
    from: 'Partner Store',
    txid: 'TXN-8194-DD02',
    status: 'Completed',
  ),
  Transaction(
    id: 't3',
    desc: 'Survey — Stockholm Uni',
    date: '20 Apr 2026',
    dateLong: '20 Apr 2026, 16:48',
    amount: '+75 pts',
    incoming: true,
    type: 'Received',
    study: 'Mobility Survey',
    from: 'Stockholm University',
    txid: 'TXN-7991-BC18',
    status: 'Completed',
  ),
  Transaction(
    id: 't4',
    desc: 'Sent to Anna L.',
    date: '15 Apr 2026',
    dateLong: '15 Apr 2026, 11:02',
    amount: '−50 pts',
    incoming: false,
    type: 'Sent',
    study: '—',
    from: 'Anna Lindqvist',
    txid: 'TXN-7820-AA77',
    status: 'Completed',
  ),
  Transaction(
    id: 't5',
    desc: 'Diet Study — Uppsala Uni',
    date: '10 Apr 2026',
    dateLong: '10 Apr 2026, 08:30',
    amount: '+300 pts',
    incoming: true,
    type: 'Received',
    study: 'Mediterranean Diet Trial',
    from: 'Uppsala University',
    txid: 'TXN-7654-EF03',
    status: 'Completed',
  ),
];
