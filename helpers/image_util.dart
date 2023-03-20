

import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;


const double commonHeightFactor = 0.5;
const double commonWidthFactor = 0.95;
const double commonImageWidth = 512;
const double commonImageHeight = 512;


abstract class ImageUtil {


  static Future<ui.Size> fetchAppropriateSizeForImage(String bytes, BuildContext context, bool mounted, {double heightMultiplier = commonHeightFactor, double widthMultiplier = commonWidthFactor, double? maxHeight, double? maxWidth}) async {

    final ui.Codec codec = await ui.instantiateImageCodec(base64Decode(bytes));
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image uiImage = frame.image;

    if (!mounted) return const Size(commonImageWidth, commonHeightFactor);

    return maxHeight != null && maxWidth != null ? fetchAppropriateSizeFromMaxHeightAndMaxWidth(context, maxHeight: maxHeight, maxWidth: maxWidth, imgHeight: uiImage.height.toDouble(), imgWidth: uiImage.width.toDouble()) :fetchAppropriateSize(context, screenHeightFactor: heightMultiplier, screenWidthFactor: widthMultiplier, imgHeight: uiImage.height.toDouble(), imgWidth: uiImage.width.toDouble());
  }

  static ui.Size fetchAppropriateSize(BuildContext context, {double screenHeightFactor = commonHeightFactor, double screenWidthFactor = commonWidthFactor, double imgWidth = commonImageHeight, double imgHeight = commonImageHeight}){
    double devicePixelRation = MediaQuery.of(context).devicePixelRatio;
    imgHeight = imgHeight / devicePixelRation;
    imgWidth = imgWidth / devicePixelRation;
    double width = MediaQuery.of(context).size.width * screenWidthFactor;
    double height = MediaQuery.of(context).size.height * screenHeightFactor;
    double minimumFactor = min(height/imgHeight, width/imgWidth);
    return ui.Size(imgWidth * minimumFactor, imgHeight * minimumFactor);
  }

  static ui.Size fetchAppropriateSizeFromMaxHeightAndMaxWidth(BuildContext context, {double imgWidth = commonImageHeight, double imgHeight = commonImageHeight, required double maxHeight, required double maxWidth}){
    double devicePixelRation = MediaQuery.of(context).devicePixelRatio;
    imgHeight = imgHeight / devicePixelRation;
    imgWidth = imgWidth / devicePixelRation;
    double width = maxWidth;
    double height = maxHeight;
    double minimumFactor = min(height/imgHeight, width/imgWidth);
    return ui.Size(imgWidth * minimumFactor, imgHeight * minimumFactor);
  }

}