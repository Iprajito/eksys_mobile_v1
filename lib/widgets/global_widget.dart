import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CircularLoading extends StatelessWidget {
  const CircularLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator(
      strokeWidth: 4.0,
      // backgroundColor: Color(0xFFC79000),
      // color: Color(0xFFFFC83A),
      backgroundColor: Color(0xFFe1e1e1),
      color: Color(0xFFFFFFFF),
    ));
  }
}

class MenuCategoryShimmer extends StatelessWidget {
  const MenuCategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFe1e1e1),
      highlightColor: const Color(0xFFFFFFFF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0xFFFFD464)),
              width: (screenWidth / 3) - 11,
              height: 50),
          const SizedBox(width: 5),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0xFFFFD464)),
              width: (screenWidth / 3) - 11,
              height: 50),
          const SizedBox(width: 5),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0xFFFFD464)),
              width: (screenWidth / 3) - 11,
              height: 50),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}

class ListMenuShimmer extends StatelessWidget {
  final int? total;
  final int? circular;
  final int? height;
  const ListMenuShimmer({Key? key, required this.total, this.circular, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double borderCircular = (circular != null) ? double.parse(circular.toString()) : 10.0;
    double _height = (height != null) ? double.parse(height.toString()) : 50;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFe1e1e1),
      highlightColor: const Color(0xFFFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 1; i <= num.parse(total.toString()); i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderCircular),
                      color: const Color(0xFFFFD464)),
                  width: screenWidth,
                  height: _height),
            ),
        ],
      ),
    );
  }
}

class SummaryShimmer extends StatelessWidget {
  const SummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Shimmer.fromColors(
      baseColor: const Color(0xFFe1e1e1),
      highlightColor: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: const Color(0xFFFFD464)),
            width: 40,
            // height: 16,
          ),
          const SizedBox(width: 6),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: const Color(0xFFFFD464)),
                width: screenWidth*0.28,
                height: 16,
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: const Color(0xFFFFD464)),
                width: screenWidth*0.28,
                height: 16,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // ambil angka saja
    final int value = int.parse(newValue.text.replaceAll('.', ''));

    // format ke ribuan
    final newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}