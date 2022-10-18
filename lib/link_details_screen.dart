import 'package:flutter/material.dart';

class LinkDetailsScreen extends StatelessWidget {
  final String postTitle;
  final String postTag;

  const LinkDetailsScreen(
      {Key? key, required this.postTitle, required this.postTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //This screen would display the details gotten from the link, like the query parameters

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post details',
          style: Theme.of(context).textTheme.headline3?.copyWith(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              postTitle,
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Tag: $postTag',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
