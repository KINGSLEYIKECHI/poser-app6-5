String numberToArabicWords(int number) {
  if (number == 0) return 'صفر';

  final units = [
    '',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة',
    'عشرة',
    'أحد عشر',
    'اثنا عشر',
    'ثلاثة عشر',
    'أربعة عشر',
    'خمسة عشر',
    'ستة عشر',
    'سبعة عشر',
    'ثمانية عشر',
    'تسعة عشر'
  ];

  final tens = ['', '', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'ستون', 'سبعون', 'ثمانون', 'تسعون'];

  final hundreds = ['', 'مئة', 'مئتان', 'ثلاثمئة', 'أربعمئة', 'خمسمئة', 'ستمئة', 'سبعمئة', 'ثمانمئة', 'تسعمئة'];

  final scales = ['', 'ألف', 'مليون', 'مليار', 'تريليون'];

  String convertTriplet(int n) {
    int h = n ~/ 100;
    int t = (n % 100) ~/ 10;
    int u = n % 10;
    String words = '';

    if (h > 0) words += hundreds[h] + ' ';
    if (n % 100 < 20 && n % 100 > 0) {
      words += units[n % 100] + ' ';
    } else {
      if (u > 0) words += units[u] + ' ';
      if (t > 1) words += tens[t] + ' ';
    }
    return words.trim();
  }

  List<String> parts = [];
  int scale = 0;

  while (number > 0) {
    int chunk = number % 1000;
    if (chunk != 0) {
      String chunkWords = convertTriplet(chunk);
      String scaleWord = scales[scale];
      if (scaleWord.isNotEmpty) chunkWords += ' ' + scaleWord;
      parts.insert(0, chunkWords.trim());
    }
    number = number ~/ 1000;
    scale++;
  }

  return parts.join(' و ');
}
