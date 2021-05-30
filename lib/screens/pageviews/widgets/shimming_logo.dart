import 'package:flutter/material.dart';
import 'package:placeholder/utils/unversal_variables.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      child: Shimmer.fromColors(
        child: Image.asset("assets/images/app_logo.png"),
        baseColor: UniversalVariables.blackColor,
        highlightColor: Colors.white,
      ),
    );
  }
}
