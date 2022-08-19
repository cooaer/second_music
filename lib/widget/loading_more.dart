import 'package:flutter/material.dart';
import 'package:second_music/res/res.dart';

class LoadingMore extends StatelessWidget {
  final bool loading;
  final bool lastError;
  final VoidCallback onPressed;

  LoadingMore(this.loading, this.lastError, this.onPressed, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 100,
      child: buildCenter(context),
    );
  }

  Widget buildCenter(BuildContext context) {
    if (!loading && lastError) {
      return SizedBox.expand(
        child: InkWell(
            onTap: onPressed,
            child: Text(
              stringsOf(context).loadErrorAndRetry,
              style: TextStyle(
                color: AppColors.textTitle,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            )),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(
            width: 20,
          ),
          Text(
            stringsOf(context).loading,
            style: TextStyle(
              color: AppColors.textTitle,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          )
        ],
      );
    }
  }
}
