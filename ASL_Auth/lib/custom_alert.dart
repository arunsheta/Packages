import 'package:flutter/material.dart';
import 'alert_string.dart';
import 'app_exception.dart';

import 'custom_text.dart';

Future<bool> showAlert({
  @required BuildContext context,
  Function logOutFunction,
  String title = AlertMessageString.defaultErrorTitle,
  dynamic message = AlertMessageString.somethingWentWrong,
  Function onRightAction,
  Function onLeftAction,
  String leftBttnTitle = AlertMessageString.no,
  String rigthBttnTitle = AlertMessageString.yes,
  String singleBtnTitle = AlertMessageString.ok,
  bool signleBttnOnly = true,
  bool barrierDismissible = true,
}) {
  //Retry button...
  Widget retryButton(BuildContext ctx) => InkWell(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: CustomText(
            txtTitle: singleBtnTitle,
            style: Theme.of(ctx)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () {
          if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop(true);
          if (message is AppException &&
              message.type == ExceptionType.UnAuthorised &&
              logOutFunction != null) {
            logOutFunction();
          }

          if (onRightAction == null) return;
          onRightAction();
        },
      );

  //Left Button...
  Widget leftButton(BuildContext ctx) => InkWell(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: CustomText(
            txtTitle: leftBttnTitle,
            style: Theme.of(ctx)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () {
          Navigator.of(ctx).pop(false);
          if (onLeftAction == null) return;
          onLeftAction();
        },
      );

  //Right Bttn...
  Widget rightButton(BuildContext ctx) => InkWell(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: CustomText(
            txtTitle: rigthBttnTitle,
            style: Theme.of(ctx)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () {
          Navigator.of(ctx).pop(true);
          if (onRightAction == null) return;
          onRightAction();
        },
      );

  // SetUp the AlertDialog
  AlertDialog alert(BuildContext ctx) => AlertDialog(
        backgroundColor: Colors.white,
        actionsPadding: EdgeInsets.only(top: 10.0, right: 5.0),
        contentPadding: EdgeInsets.only(
          left: 25.0,
          right: 25.0,
        ),
        titlePadding: EdgeInsets.only(
          left: 30.0,
          right: 30.0,
          top: 20.0,
          bottom: 15.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        title: CustomText(
          txtTitle: message is AppException ? message.getTitle : title,
          align: TextAlign.center,
          style: Theme.of(ctx).textTheme.headline2.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: CustomText(
          align: TextAlign.center,
          txtTitle: message is AppException
              ? message.getMessage
              : (message?.toString() ?? AlertMessageString.somethingWentWrong),
          style: Theme.of(ctx).textTheme.bodyText1,
        ),
        actions: signleBttnOnly
            ? [retryButton(ctx)]
            : [leftButton(ctx), rightButton(ctx)],
      );

  // show the dialog
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: alert,
  );
}
