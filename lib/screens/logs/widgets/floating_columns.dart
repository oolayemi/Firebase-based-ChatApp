import 'package:flutter/material.dart';
import 'package:placeholder/utils/unversal_variables.dart';

class FloatingColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: UniversalVariables.fabGradient,
          ),
          child: Icon(
            Icons.video_call_outlined,
            color: Colors.white,
            size: 25,
          ),
          padding: EdgeInsets.all(15),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: UniversalVariables.gradientColorEnd,
            ),
          ),
          child: Icon(
            Icons.add_call,
            color: UniversalVariables.gradientColorEnd,
            size: 25,
          ),
          padding: EdgeInsets.all(15),
        )
      ],
    );
  }
}
