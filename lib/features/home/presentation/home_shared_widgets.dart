part of 'home_screen.dart';

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color tint;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 190;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      );
      return Container(
        padding: EdgeInsets.all(compact ? 12 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: const Color(0xFF34725F)),
                  ),
                  const SizedBox(height: 10),
                  content,
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: const Color(0xFF34725F)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: content),
                ],
              ),
      );
    },
  );
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _ReminderCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF34725F)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _RecentCard extends StatelessWidget {
  final IconData icon;
  final String title, detail;
  const _RecentCard({
    required this.icon,
    required this.title,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 190,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF34725F)),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(detail, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title, action;
  final VoidCallback? onAction;
  const _SectionHeader({
    required this.title,
    required this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      InkWell(
        onTap: onAction,
        child: Text(
          action,
          style: const TextStyle(
            color: Color(0xFF34725F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _CaptureOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _CaptureOption({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF34725F), size: 27),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Pill({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18, color: const Color(0xFF34725F)),
    label: Text(label),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    backgroundColor: Colors.white,
    side: BorderSide.none,
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icon(icon, size: 42, color: const Color(0xFF34725F)),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(body, textAlign: TextAlign.center),
      ],
    ),
  );
}
