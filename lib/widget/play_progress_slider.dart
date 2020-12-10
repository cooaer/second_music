import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayProgressSlider extends StatefulWidget {
  final int position;
  final int duration;
  final ValueChanged<double> onChanged;

  PlayProgressSlider(this.position, this.duration, this.onChanged, {Key? key})
      : super(key: key);

  @override
  State createState() => _PlayProgressSliderState();
}

class _PlayProgressSliderState extends State<PlayProgressSlider> {
  bool _isSeeking = false;
  double _seekToPosition = 0;

  @override
  void initState() {
    super.initState();
    _isSeeking = false;
    _seekToPosition = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _isSeeking
          ? _seekToPosition
          : (widget.position >= 0 ? widget.position.toDouble() : 0),
      activeColor: Color(0x3fffffff),
      inactiveColor: Color(0x7fffffff),
      min: 0,
      max: widget.duration.toDouble(),
      onChangeStart: (value) {
        setState(() {
          _isSeeking = true;
          _seekToPosition = value;
        });
      },
      onChangeEnd: (value) {
        setState(() {
          _isSeeking = false;
          _seekToPosition = value;
        });
      },
      onChanged: (double value) {
        setState(() {
          _isSeeking = true;
          _seekToPosition = value;
        });
        widget.onChanged(value);
      },
    );
  }
}
