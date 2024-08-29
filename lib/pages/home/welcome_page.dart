import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _container(

          )
        ],
      )
    );
  }

  Widget _container() {
    return BlurryContainer(
      blur: 10,
      width: double.infinity,
      height: 150,
      elevation: 0,
      color: Colors.white.withOpacity(0.3), // Lichtere kleur met hogere opaciteit
      borderRadius: BorderRadius.circular(20.0),
      padding: const EdgeInsets.all(0),
      child: Text(''),
    );
  }
}
