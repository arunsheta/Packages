part of bmi;

String formattedBMI(double bmi) {
  final formatter = NumberFormat('###.#');
  return formatter.format(bmi);
}
