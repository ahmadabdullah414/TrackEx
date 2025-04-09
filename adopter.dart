import 'package:hive/hive.dart';
import 'package:trackex/functions.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final typeId = 0; // Unique ID for the adapter

  @override
  Transaction read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final amount = reader.readDouble();
    final timestamp = reader.readInt(); // Read as timestamp (int)
    final isIncome = reader.readBool();
    final category = reader.readString();

    return Transaction(
      id: id,
      title: title,
      amount: amount,
      date: DateTime.fromMillisecondsSinceEpoch(timestamp), // Convert timestamp back to DateTime
      isIncome: isIncome,
      category: category,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.date.millisecondsSinceEpoch); // Convert DateTime to timestamp (int)
    writer.writeBool(obj.isIncome);
    writer.writeString(obj.category);
  }
}
