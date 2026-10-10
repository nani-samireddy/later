enum AttachmentOwner { thing, money }

class StoredAttachment {
  final int id;
  final String name, path, kind;
  const StoredAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.kind,
  });
}
