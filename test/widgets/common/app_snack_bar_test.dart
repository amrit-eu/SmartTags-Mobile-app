import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/common/app_snack_bar.dart';

void main() {
  test('builds transient feedback with the standard duration', () {
    final snackBar = buildAppSnackBar(message: 'Saved');

    expect((snackBar.content as Text).data, 'Saved');
    expect(snackBar.duration, appSnackBarDuration);
    expect(snackBar.persist, isNot(true));
    expect(
      snackBar.dismissDirection,
      isNot(DismissDirection.none),
    );
    expect(snackBar.action, isNull);
  });
  test('builds an optional action', () {
    var actionCalled = false;

    final snackBar = buildAppSnackBar(
      message: 'Could not complete action',
      actionLabel: 'Retry',
      onAction: () {
        actionCalled = true;
      },
    );

    expect(snackBar.action?.label, 'Retry');

    snackBar.action!.onPressed();

    expect(actionCalled, isTrue);
  });
}
